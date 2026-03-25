import 'package:flutter/material.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../core/app_export.dart';

class MainShellScreen extends StatelessWidget {
  final Widget child;
  final CustomBottomBarItem currentItem;

  const MainShellScreen({
    super.key,
    required this.child,
    required this.currentItem,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: CustomBottomBar(
        currentItem: currentItem,
        onItemTapped: (item) {
          if (item == currentItem) return;
          switch (item) {
            case CustomBottomBarItem.dashboard:
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.mainDashboard,
                (route) => false,
              );
              break;

            case CustomBottomBarItem.marketplace:
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.marketplace,
                (route) => false,
              );
              break;

            case CustomBottomBarItem.community:
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.communityChat,
                (route) => false,
              );
              break;

            case CustomBottomBarItem.chatbot:
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.aiChatbot,
                (route) => false,
              );
              break;

            case CustomBottomBarItem.profile:
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.profile,
                (route) => false,
              );
              break;
          }
        },
      ),
    );
  }
}
