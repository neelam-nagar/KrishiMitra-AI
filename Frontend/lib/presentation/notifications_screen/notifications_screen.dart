import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/language_provider.dart';
import '../../core/location_provider.dart';
import '../../services/notification_service.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../main_shell/main_shell_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'All';
  bool _isRefreshing = false;

  final List<Map<String, dynamic>> _categories = [
    {'key': 'All',     'label': 'सभी',       'icon': Icons.notifications_rounded},
    {'key': 'Weather', 'label': 'मौसम',      'icon': Icons.cloud_rounded},
    {'key': 'Prices',  'label': 'मंडी भाव',  'icon': Icons.trending_up_rounded},
    {'key': 'Schemes', 'label': 'योजनाएं',  'icon': Icons.description_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() => _selectedCategory = _categories[_tabController.index]['key']);
      }
    });
    _refreshNotifications();
  }

  Future<void> _refreshNotifications() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    final location = context.read<LocationProvider>();
    await NotificationService.instance.refreshNotifications(location);
    if (mounted) setState(() => _isRefreshing = false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final theme = Theme.of(context);

    return MainShellScreen(
      currentItem: CustomBottomBarItem.dashboard, // FIX: notifications नहीं है enum में, dashboard use karo
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FBF8),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1B5E20),
          elevation: 0,
          title: Text(
            lang == 'en' ? 'Notifications' : 'सूचनाएं',
            style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
          ),
          actions: [
            if (_isRefreshing)
              const Padding(
                padding: EdgeInsets.all(14),
                child: SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
              )
            else
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                onPressed: _refreshNotifications,
                tooltip: 'Refresh',
              ),
            IconButton(
              icon: const Icon(Icons.done_all_rounded, color: Colors.white),
              onPressed: () async {
                await NotificationService.instance.markAllRead();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(lang == 'en' ? 'All marked as read' : 'सभी पढ़ी गईं'),
                      backgroundColor: const Color(0xFF2E7D32),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: _categories.map((c) => Tab(
              child: Row(children: [
                Icon(c['icon'] as IconData, size: 16),
                const SizedBox(width: 6),
                Text(c['label'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ]),
            )).toList(),
          ),
        ),
        body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: NotificationService.instance.notificationsStream(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)));
            }

            final all = snap.data ?? [];
            final filtered = _selectedCategory == 'All'
                ? all
                : all.where((n) => n['type'] == _selectedCategory).toList();

            if (filtered.isEmpty) {
              return _buildEmptyState(lang, _selectedCategory);
            }

            return RefreshIndicator(
              onRefresh: _refreshNotifications,
              color: const Color(0xFF2E7D32),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _buildNotificationCard(filtered[i], lang),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> n, String lang) {
    final isRead = n['read'] as bool? ?? false;
    final color = Color(n['color'] as int? ?? 0xFF2E7D32);
    final priority = n['priority'] as String? ?? 'low';
    final ts = n['timestamp'];
    final time = ts is DateTime ? _formatTime(ts) : '';

    return Dismissible(
      key: Key(n['id']?.toString() ?? n['title']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 26),
      ),
      onDismissed: (_) {
        if (n['id'] != null) {
          NotificationService.instance.deleteNotification(n['id']);
        }
      },
      child: GestureDetector(
        onTap: () {
          if (n['id'] != null && !isRead) {
            NotificationService.instance.markRead(n['id']);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isRead ? Colors.white : color.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isRead ? Colors.grey.shade100 : color.withValues(alpha: 0.25),
              width: isRead ? 1 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isRead ? 0.03 : 0.07),
                blurRadius: isRead ? 8 : 14,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_iconFor(n['icon'] as String? ?? ''), color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(n['title'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isRead ? FontWeight.w600 : FontWeight.w800,
                      color: const Color(0xFF1A1A1A),
                    ))),
                if (priority == 'high')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: const Text('ज़रूरी',
                        style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
              ]),
              const SizedBox(height: 6),
              Text(n['message'] ?? '',
                  style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600, height: 1.4)),
              const SizedBox(height: 8),
              Row(children: [
                Icon(Icons.access_time_rounded, size: 12, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(time, style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_categoryLabel(n['type'] as String? ?? ''),
                      style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
                ),
                if (!isRead) ...[
                  const SizedBox(width: 8),
                  Container(width: 8, height: 8,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                ],
              ]),
            ])),
          ]),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String lang, String category) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        padding: const EdgeInsets.all(28),
        decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
        child: const Icon(Icons.notifications_none_rounded, size: 52, color: Color(0xFF2E7D32)),
      ),
      const SizedBox(height: 20),
      Text(
        lang == 'en' ? 'No notifications yet' : 'अभी कोई सूचना नहीं',
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1B5E20)),
      ),
      const SizedBox(height: 8),
      Text(
        lang == 'en' ? 'Weather alerts and updates will appear here' : 'मौसम अलर्ट और अपडेट यहाँ दिखेंगे',
        style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 24),
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        onPressed: _refreshNotifications,
        icon: const Icon(Icons.refresh_rounded, color: Colors.white),
        label: Text(lang == 'en' ? 'Check Now' : 'अभी जांचें',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    ]));
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'अभी';
    if (diff.inMinutes < 60) return '${diff.inMinutes} मिनट पहले';
    if (diff.inHours < 24) return '${diff.inHours} घंटे पहले';
    if (diff.inDays == 1) return 'कल';
    return '${diff.inDays} दिन पहले';
  }

  String _categoryLabel(String type) {
    switch (type) {
      case 'Weather': return 'मौसम';
      case 'Prices': return 'मंडी';
      case 'Schemes': return 'योजना';
      default: return type;
    }
  }

  IconData _iconFor(String name) {
    switch (name) {
      case 'thermostat': return Icons.thermostat_rounded;
      case 'wb_sunny': return Icons.wb_sunny_rounded;
      case 'water_drop': return Icons.water_drop_rounded;
      case 'air': return Icons.air_rounded;
      case 'opacity': return Icons.opacity_rounded;
      case 'trending_up': return Icons.trending_up_rounded;
      case 'description': return Icons.description_rounded;
      default: return Icons.notifications_rounded;
    }
  }
}