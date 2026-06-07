import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/notification_card_widget.dart';
import '../../presentation/main_shell/main_shell_screen.dart';
import 'package:provider/provider.dart';
import '../../core/language_provider.dart';
/// Notifications Screen displaying all agricultural alerts and updates
/// Features category filtering, swipe-to-dismiss, and chronological ordering
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _categoryTabController;
  String _selectedCategory = 'All';
  List<Map<String, dynamic>> _notifications = [];

  final List<String> _categories = [
    'All',
    'Schemes',
    'Prices',
    'Weather',
    'Messages',
  ];

  @override
  void initState() {
    super.initState();
    _categoryTabController = TabController(
      length: _categories.length,
      vsync: this,
    );
    _loadDummyNotifications();
  }

  @override
  void dispose() {
    _categoryTabController.dispose();
    super.dispose();
  }

  void _loadDummyNotifications() {
    setState(() {
      _notifications = [
        {
          'id': '1',
          'title': 'New Scheme: PM-KISAN',
          'description':
              'Direct income support to farmers. Check eligibility and apply now.',
          'category': 'Schemes',
          'priority': 'high',
          'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
          'isUnread': true,
        },
        {
          'id': '2',
          'title': 'Wheat Price Alert',
          'description':
              'Mandi rates increased by 5% in your region. Current price: ₹2,250/quintal',
          'category': 'Prices',
          'priority': 'normal',
          'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
          'isUnread': true,
        },
        {
          'id': '3',
          'title': 'Weather Warning',
          'description':
              'Heavy rainfall expected in next 48 hours. Take necessary precautions.',
          'category': 'Weather',
          'priority': 'high',
          'timestamp': DateTime.now().subtract(const Duration(hours: 8)),
          'isUnread': true,
        },
        {
          'id': '4',
          'title': 'New Buyer Message',
          'description':
              'A buyer is interested in your maize crop. Check marketplace messages.',
          'category': 'Messages',
          'priority': 'normal',
          'timestamp': DateTime.now().subtract(const Duration(days: 1)),
          'isUnread': false,
        },
        {
          'id': '5',
          'title': 'Subsidy Update',
          'description':
              'Fertilizer subsidy application deadline extended till 31st Dec.',
          'category': 'Schemes',
          'priority': 'normal',
          'timestamp': DateTime.now().subtract(const Duration(days: 2)),
          'isUnread': false,
        },
        {
          'id': '6',
          'title': 'Cotton Price Drop',
          'description':
              'Cotton prices decreased by 3%. Consider holding inventory.',
          'category': 'Prices',
          'priority': 'normal',
          'timestamp': DateTime.now().subtract(const Duration(days: 3)),
          'isUnread': false,
        },
        {
          'id': '7',
          'title': 'Sunny Weather Ahead',
          'description':
              'Clear skies expected for next 5 days. Ideal for harvesting.',
          'category': 'Weather',
          'priority': 'normal',
          'timestamp': DateTime.now().subtract(const Duration(days: 4)),
          'isUnread': false,
        },
        {
          'id': '8',
          'title': 'Order Confirmed',
          'description':
              'Your order for organic fertilizer has been confirmed.',
          'category': 'Messages',
          'priority': 'normal',
          'timestamp': DateTime.now().subtract(const Duration(days: 5)),
          'isUnread': false,
        },
      ];
    });
  }

  List<Map<String, dynamic>> _getFilteredNotifications() {
    if (_selectedCategory == 'All') {
      return _notifications;
    }
    return _notifications
        .where((n) => n['category'] == _selectedCategory)
        .toList();
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    setState(() {
      notification['isUnread'] = false;
    });
    HapticFeedback.lightImpact();

    final lang = context.read<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification['title'] as String),
        content: Text(notification['description'] as String),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isHindi ? 'बंद करें' : 'Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isHindi
                      ? 'यह आपको संबंधित अनुभाग में ले जाएगा'
                      : 'This will navigate to relevant section'),
                ),
              );
            },
            child: Text(isHindi ? 'विवरण देखें' : 'View Details'),
          ),
        ],
      ),
    );
  }

  void _handleDismissNotification(Map<String, dynamic> notification) {
    final lang = context.read<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';

    setState(() {
      _notifications.remove(notification);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isHindi ? 'सूचना हटाई गई' : 'Notification dismissed'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _notifications.add(notification);
              _notifications.sort(
                (a, b) => (b['timestamp'] as DateTime).compareTo(
                  a['timestamp'] as DateTime,
                ),
              );
            });
          },
        ),
      ),
    );
  }

  void _handleClearAll() {
    final lang = context.read<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';

    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isHindi ? 'सभी सूचनाएं हटाएं' : 'Clear All Notifications'),
        content: Text(isHindi
            ? 'क्या आप वाकई सभी सूचनाएं हटाना चाहते हैं? यह क्रिया वापस नहीं होगी।'
            : 'Are you sure you want to clear all notifications? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isHindi ? 'रद्द करें' : 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _notifications.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isHindi ? 'सभी सूचनाएं हटा दी गईं' : 'All notifications cleared')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFE53935),
            ),
            child: Text(isHindi ? 'सभी हटाएं' : 'Clear All'),
          ),
        ],
      ),
    );
  }

  void _handleMarkAllRead() {
    final lang = context.read<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';

    setState(() {
      for (var notification in _notifications) {
        notification['isUnread'] = false;
      }
    });
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isHindi ? 'सभी सूचनाएं पढ़ी हुई चिन्हित की गईं' : 'All notifications marked as read')),
    );
  }

  String _getCategoryLabel(String category, bool isHindi) {
    if (!isHindi) return category;
    switch (category) {
      case 'All':
        return 'सभी';
      case 'Schemes':
        return 'योजनाएं';
      case 'Prices':
        return 'भाव';
      case 'Weather':
        return 'मौसम';
      case 'Messages':
        return 'संदेश';
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';

    final filteredNotifications = _getFilteredNotifications();
    final unreadCount = filteredNotifications
        .where((n) => n['isUnread'] == true)
        .length;

    return MainShellScreen(
      currentItem: CustomBottomBarItem.dashboard,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: CustomIconWidget(
              iconName: 'arrow_back',
              color: theme.brightness == Brightness.light
                  ? const Color(0xFF424242)
                  : const Color(0xFFE0E0E0),
              size: 24,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isHindi ? 'सूचनाएं' : 'Notifications',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (unreadCount > 0)
                Text(
                  isHindi ? '$unreadCount अपठित' : '$unreadCount unread',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.brightness == Brightness.light
                        ? const Color(0xFF757575)
                        : const Color(0xFFB0B0B0),
                  ),
                ),
            ],
          ),
          actions: [
            if (_notifications.isNotEmpty) ...[
              IconButton(
                icon: CustomIconWidget(
                  iconName: 'done_all',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                onPressed: _handleMarkAllRead,
                tooltip: isHindi ? 'सभी को पढ़ा हुआ चिन्हित करें' : 'Mark all as read',
              ),
              IconButton(
                icon: CustomIconWidget(
                  iconName: 'delete_sweep',
                  color: const Color(0xFFE53935),
                  size: 24,
                ),
                onPressed: _handleClearAll,
                tooltip: isHindi ? 'सभी हटाएं' : 'Clear all',
              ),
            ],
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(6.h),
            child: Container(
              height: 6.h,
              color: theme.colorScheme.surface,
              child: TabBar(
                controller: _categoryTabController,
                isScrollable: true,
                indicatorColor: theme.colorScheme.primary,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.brightness == Brightness.light
                    ? const Color(0xFF757575)
                    : const Color(0xFFB0B0B0),
                labelStyle: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: theme.textTheme.titleSmall,
                onTap: (index) {
                  setState(() {
                    _selectedCategory = _categories[index];
                  });
                  HapticFeedback.selectionClick();
                },
                tabs: _categories.map((category) {
                  final categoryCount = category == 'All'
                      ? _notifications.length
                      : _notifications
                            .where((n) => n['category'] == category)
                            .length;
                  return Tab(text: '${_getCategoryLabel(category, isHindi)} ($categoryCount)');
                }).toList(),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: filteredNotifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'notifications_off',
                        color: theme.brightness == Brightness.light
                            ? const Color(0xFFBDBDBD)
                            : const Color(0xFF616161),
                        size: 64,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        isHindi ? 'कोई सूचना नहीं' : 'No notifications',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Text(
                          _selectedCategory == 'All'
                              ? (isHindi
                                  ? 'इस समय कोई सूचना उपलब्ध नहीं है'
                                  : 'You have no notifications at the moment')
                              : (isHindi
                                  ? 'कोई ${_getCategoryLabel(_selectedCategory, true)} सूचना नहीं'
                                  : 'No ${_selectedCategory.toLowerCase()} notifications'),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.brightness == Brightness.light
                                ? const Color(0xFF757575)
                                : const Color(0xFFB0B0B0),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    HapticFeedback.mediumImpact();
                    await Future.delayed(const Duration(seconds: 1));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isHindi ? 'सूचनाएं रिफ्रेश की गईं' : 'Notifications refreshed')),
                    );
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.all(4.w),
                    itemCount: filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final notification = filteredNotifications[index];
                      return NotificationCardWidget(
                        notification: notification,
                        onTap: () => _handleNotificationTap(notification),
                        onDismiss: () => _handleDismissNotification(notification),
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }
}
