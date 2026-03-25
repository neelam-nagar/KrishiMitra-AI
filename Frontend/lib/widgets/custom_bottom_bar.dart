import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/language_provider.dart';
import '../routes/app_routes.dart';
import '../../widgets/custom_bottom_bar.dart';
/// Navigation item configuration for the bottom navigation bar
enum CustomBottomBarItem {
  dashboard,
  marketplace,
  profile,
  community,
  chatbot,
}
/// Custom bottom navigation bar widget for agricultural application
/// Implements bottom-heavy interaction design with large touch targets
/// Follows the hub-and-spoke navigation model with dashboard as central hub
class CustomBottomBar extends StatelessWidget {
  /// Current selected navigation item
  final CustomBottomBarItem currentItem;

  /// Callback when navigation item is tapped
  final ValueChanged<CustomBottomBarItem> onItemTapped;

  /// Whether to show labels (default: true)
  final bool showLabels;

  /// Custom elevation (default: 8.0 for bottom sheets)
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
            color: Colors.black.withValues(alpha: 0.15),
            offset: const Offset(0, -2),
            blurRadius: elevation,
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 72, // Minimum 56dp + padding for thumb reach
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                item: CustomBottomBarItem.dashboard,
                icon: Icons.dashboard_outlined,
                selectedIcon: Icons.dashboard,
                label: lang == 'en' ? 'Dashboard' : 'डैशबोर्ड',
              ),
              _buildNavItem(
                context: context,
                item: CustomBottomBarItem.marketplace,
                icon: Icons.store_outlined,
                selectedIcon: Icons.store,
                label: lang == 'en' ? 'Market' : 'मार्केट',
              ),

              // CENTER PROFILE BUTTON
              _buildCenterProfileButton(context),
              _buildNavItem(
                context: context,
                item: CustomBottomBarItem.community,
                icon: Icons.forum_outlined,
                selectedIcon: Icons.forum,
                label: lang == 'en' ? 'Community' : 'समुदाय',
              ),
              _buildNavItem(
                context: context,
                item: CustomBottomBarItem.chatbot,
                icon: Icons.smart_toy_outlined,
                selectedIcon: Icons.smart_toy,
                label: lang == 'en' ? 'AI' : 'एआई',
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds individual navigation item with proper touch targets
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

    final itemColor = isSelected
    ? Colors.white
    : Colors.white70;

    return Expanded(
      child: InkWell(
        onTap: () {
          // Haptic feedback for touch response
          // HapticFeedback.lightImpact(); // Uncomment if haptic feedback is needed

          // Navigate based on selected item
          _handleNavigation(context, item);

          // Notify parent of selection change
          onItemTapped(item);
        },
        splashColor: colorScheme.primary.withValues(alpha: 0.1),
        highlightColor: colorScheme.primary.withValues(alpha: 0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with 26dp size for clear visibility
              Icon(
                isSelected ? selectedIcon : icon,
                size: 26,
                color: itemColor,
              ),

              if (showLabels) ...[
                const SizedBox(height: 4),
                // Label with appropriate typography
                Text(
                  label,
                  style: theme.bottomNavigationBarTheme.selectedLabelStyle
                      ?.copyWith(
                        color: itemColor,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
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
        onTap: () {
          _handleNavigation(context, CustomBottomBarItem.profile);
          onItemTapped(CustomBottomBarItem.profile);
        },
        child: Container(
          alignment: Alignment.center,
          child: Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.person,
              size: 30,
              color: isSelected ? Colors.green.shade700 : Colors.green,
            ),
          ),
        ),
      ),
    );
  }

  /// Handles navigation based on selected item
  /// Maps navigation items to their respective routes
  void _handleNavigation(BuildContext context, CustomBottomBarItem item) {
    String route;

    switch (item) {
      case CustomBottomBarItem.dashboard:
        route = AppRoutes.mainDashboard;
        break;

      case CustomBottomBarItem.marketplace:
        route = AppRoutes.marketplace;
        break;

      case CustomBottomBarItem.community:
        route = AppRoutes.communityChat;
        break;

      case CustomBottomBarItem.chatbot:
        route = AppRoutes.aiChatbot;
        break;

      case CustomBottomBarItem.profile:
        route = AppRoutes.profile;
        break;
    }

    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.pushReplacementNamed(context, route);
    }
  }
}

/// Extension to get navigation item from route name
extension CustomBottomBarItemExtension on CustomBottomBarItem {
  static CustomBottomBarItem fromRoute(String? routeName) {
    switch (routeName) {
      case '/main-dashboard_screen':
        return CustomBottomBarItem.dashboard;
      case '/marketplace-screen':
        return CustomBottomBarItem.marketplace;
      case '/community-chat':
        return CustomBottomBarItem.community;
      case '/ai-chatbot-screen':
        return CustomBottomBarItem.chatbot;
      case '/profile-screen':
        return CustomBottomBarItem.profile;
      default:
        return CustomBottomBarItem.dashboard;
    }
  }
}
