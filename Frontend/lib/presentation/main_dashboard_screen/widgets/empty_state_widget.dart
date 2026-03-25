import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';
import 'package:provider/provider.dart';
import '../../../core/language_provider.dart';

/// Empty state widget for modules without data
/// Shows helpful illustration with setup prompt
class EmptyStateWidget extends StatelessWidget {
  final String iconName;
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onActionTap;

  const EmptyStateWidget({
    super.key,
    required this.iconName,
    required this.title,
    required this.message,
    this.actionText,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';

    return Center(
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: iconName,
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
                size: 64,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              isHindi ? _hindiTitle(title) : title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              isHindi ? _hindiMessage(message) : message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.brightness == Brightness.light
                    ? const Color(0xFF757575)
                    : const Color(0xFFB0B0B0),
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onActionTap != null) ...[
              SizedBox(height: 3.h),
              ElevatedButton(onPressed: onActionTap, child: Text(isHindi ? _hindiAction(actionText!) : actionText!)),
            ],
          ],
        ),
      ),
    );
  }

  String _hindiTitle(String title) {
    switch (title) {
      case 'No Data Available':
        return 'डेटा उपलब्ध नहीं है';
      case 'No Weather Data':
        return 'मौसम डेटा उपलब्ध नहीं है';
      case 'No Crop Prices':
        return 'फसल भाव उपलब्ध नहीं हैं';
      case 'No Schemes Found':
        return 'कोई योजना नहीं मिली';
      default:
        return title;
    }
  }

  String _hindiMessage(String message) {
    switch (message) {
      case 'Please check back later or refresh':
        return 'कृपया बाद में पुनः प्रयास करें';
      case 'Weather data will appear here':
        return 'मौसम की जानकारी यहाँ दिखाई देगी';
      case 'Mandi prices will be shown here':
        return 'मंडी के भाव यहाँ दिखेंगे';
      case 'Government schemes will be listed here':
        return 'सरकारी योजनाएं यहाँ दिखाई जाएंगी';
      default:
        return message;
    }
  }

  String _hindiAction(String action) {
    switch (action) {
      case 'Refresh':
        return 'रीफ्रेश करें';
      case 'Retry':
        return 'दोबारा प्रयास करें';
      default:
        return action;
    }
  }
}
