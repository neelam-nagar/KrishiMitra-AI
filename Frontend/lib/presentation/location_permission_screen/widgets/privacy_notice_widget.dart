import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';
import '../../../../core/language_provider.dart';

import '../../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Privacy notice widget for location permission screen
/// Explains data usage and provides link to privacy policy
class PrivacyNoticeWidget extends StatelessWidget {
  const PrivacyNoticeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'privacy_tip',
                color: theme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                !isHindi ? 'Privacy Notice' : 'गोपनीयता सूचना',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            !isHindi
                ? 'Your location data is used only to provide accurate weather forecasts, local mandi prices, and region-specific farming guidance. We do not share your location with third parties.'
                : 'आपकी लोकेशन जानकारी का उपयोग केवल सटीक मौसम पूर्वानुमान, स्थानीय मंडी भाव और क्षेत्र-विशिष्ट कृषि मार्गदर्शन प्रदान करने के लिए किया जाता है। हम आपकी लोकेशन किसी तीसरे पक्ष के साथ साझा नहीं करते हैं।',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          SizedBox(height: 1.h),
          InkWell(
            onTap: () {
              // Navigate to privacy policy screen
              // In production, this would open a detailed privacy policy
            },
            child: Text(
              !isHindi ? 'Read our Privacy Policy' : 'हमारी गोपनीयता नीति पढ़ें',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
