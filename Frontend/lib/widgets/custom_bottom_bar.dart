import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/language_provider.dart';
import '../routes/app_routes.dart';
// FIX: removed self-import '../../widgets/custom_bottom_bar.dart'

enum CustomBottomBarItem { dashboard, marketplace, profile, community, chatbot }

class CustomBottomBar extends StatelessWidget {
  final CustomBottomBarItem currentItem;
  final ValueChanged<CustomBottomBarItem> onItemTapped;
  final bool showLabels;
  final double elevation;

  const CustomBottomBar({
    super.key,
    required this.currentItem,
    required this.onItemTapped,
    this.showLabels = true,
    this.elevation = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final lang = context.watch<LanguageProvider>().currentLanguage;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primary,
        boxShadow: [
          BoxShadow(
            // FIX: withOpacity → withValues
            color: Colors.black.withValues(alpha: 0.15),
            offset: const Offset(0, -2),
            blurRadius: elevation,
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 72,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context: context, item: CustomBottomBarItem.dashboard,
                  icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard,
                  label: lang == 'en' ? 'Dashboard' : 'डैशबोर्ड'),
              _buildNavItem(context: context, item: CustomBottomBarItem.marketplace,
                  icon: Icons.store_outlined, selectedIcon: Icons.store,
                  label: lang == 'en' ? 'Market' : 'मार्केट'),
              _buildCenterProfileButton(context),
              _buildNavItem(context: context, item: CustomBottomBarItem.community,
                  icon: Icons.forum_outlined, selectedIcon: Icons.forum,
                  label: lang == 'en' ? 'Community' : 'समुदाय'),
              _buildNavItem(context: context, item: CustomBottomBarItem.chatbot,
                  icon: Icons.smart_toy_outlined, selectedIcon: Icons.smart_toy,
                  label: lang == 'en' ? 'AI' : 'एआई'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required CustomBottomBarItem item,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = currentItem == item;
    final itemColor = isSelected ? Colors.white : Colors.white70;

    return Expanded(
      child: InkWell(
        onTap: () { _handleNavigation(context, item); onItemTapped(item); },
        splashColor: colorScheme.primary.withValues(alpha: 0.1),
        highlightColor: colorScheme.primary.withValues(alpha: 0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isSelected ? selectedIcon : icon, size: 26, color: itemColor),
              if (showLabels) ...[
                const SizedBox(height: 4),
                Text(
                  label,
                  style: theme.bottomNavigationBarTheme.selectedLabelStyle?.copyWith(
                    color: itemColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterProfileButton(BuildContext context) {
    final isSelected = currentItem == CustomBottomBarItem.profile;

    return Expanded(
      child: GestureDetector(
        onTap: () { _handleNavigation(context, CustomBottomBarItem.profile); onItemTapped(CustomBottomBarItem.profile); },
        child: Container(
          alignment: Alignment.center,
          child: Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                // FIX: withOpacity → withValues
                BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 4)),
              ],
            ),
            child: Icon(Icons.person, size: 30,
                color: isSelected ? Colors.green.shade700 : Colors.green),
          ),
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context, CustomBottomBarItem item) {
    final routes = {
      CustomBottomBarItem.dashboard: AppRoutes.mainDashboard,
      CustomBottomBarItem.marketplace: AppRoutes.marketplace,
      CustomBottomBarItem.community: AppRoutes.communityChat,
      CustomBottomBarItem.chatbot: AppRoutes.aiChatbot,
      CustomBottomBarItem.profile: AppRoutes.profile,
    };
    final route = routes[item]!;
    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.pushReplacementNamed(context, route);
    }
  }
}

extension CustomBottomBarItemExtension on CustomBottomBarItem {
  static CustomBottomBarItem fromRoute(String? routeName) {
    switch (routeName) {
      case '/main-dashboard_screen': return CustomBottomBarItem.dashboard;
      case '/marketplace-screen': return CustomBottomBarItem.marketplace;
      case '/community-chat': return CustomBottomBarItem.community;
      case '/ai-chatbot-screen': return CustomBottomBarItem.chatbot;
      case '/profile-screen': return CustomBottomBarItem.profile;
      default: return CustomBottomBarItem.dashboard;
    }
  }
}