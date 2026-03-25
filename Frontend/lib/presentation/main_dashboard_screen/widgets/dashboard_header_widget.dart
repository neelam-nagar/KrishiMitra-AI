import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';
import '../../../core/language_provider.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';
import './notification_badge_widget.dart';

/// Dashboard header widget with location and language toggle
/// Sticky header that remains visible during scroll
class DashboardHeaderWidget extends StatelessWidget {
  final String currentLocation;
  final VoidCallback onLocationTap;
  final int unreadNotificationCount;
  final VoidCallback onNotificationTap;

  const DashboardHeaderWidget({
    super.key,
    required this.currentLocation,
    required this.onLocationTap,
    required this.unreadNotificationCount,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                onLocationTap();
              },
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'location_on',
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            lang == 'hi' ? 'स्थान' : 'Location',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            currentLocation,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 1.w),
                    CustomIconWidget(
                      iconName: 'keyboard_arrow_down',
                      color: Colors.white70,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              NotificationBadgeWidget(
                unreadCount: unreadNotificationCount,
                iconColor: Colors.white,
                onTap: () {
                  HapticFeedback.lightImpact();
                  onNotificationTap();
                },
              ),
              SizedBox(width: 2.w),
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();

                  final provider = context.read<LanguageProvider>();
                  provider.changeLanguage(
                    provider.currentLanguage == 'en' ? 'hi' : 'en',
                  );
                },
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: Colors.white54,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'language',
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        lang == 'en' ? 'English' : 'हिंदी',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
