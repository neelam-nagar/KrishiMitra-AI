import 'package:provider/provider.dart';
import '../../../../core/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Primary button widget for requesting location permission
/// Full-width, thumb-reachable button with clear call-to-action
class LocationPermissionButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;

  const LocationPermissionButtonWidget({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 6.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'my_location',
            color: theme.colorScheme.onPrimary,
            size: 20,
          ),
          SizedBox(width: 2.w),
          Text(
            !isHindi ? 'Allow Location Access' : 'लोकेशन की अनुमति दें',
            style: theme.textTheme.labelLarge?.copyWith(
              fontSize: 14.sp,
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
