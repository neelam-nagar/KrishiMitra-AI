import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';
import 'package:provider/provider.dart';
import '../../../core/language_provider.dart';

/// Language toggle widget for switching between Hindi and English
/// Positioned in top-right corner with immediate UI translation
class LanguageToggleWidget extends StatelessWidget {
  const LanguageToggleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline, width: 1),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final provider = context.read<LanguageProvider>();
            provider.changeLanguage(
              provider.currentLanguage == 'hi' ? 'en' : 'hi',
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'language',
                  color: theme.colorScheme.primary,
                  size: 5.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  context.watch<LanguageProvider>().currentLanguage == 'hi'
                      ? 'हिंदी'
                      : 'English',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 1.w),
                CustomIconWidget(
                  iconName: 'swap_horiz',
                  color: theme.colorScheme.primary,
                  size: 4.w,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
