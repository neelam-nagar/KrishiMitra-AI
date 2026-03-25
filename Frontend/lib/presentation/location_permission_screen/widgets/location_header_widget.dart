import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:provider/provider.dart';
import '../../../../core/language_provider.dart';

import '../../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Header widget for location permission screen
/// Shows location icon, illustration, and explanation text
class LocationHeaderWidget extends StatelessWidget {
  const LocationHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';

    return Column(
      children: [
        // Location icon with agriculture theme
        Container(
          width: 25.w,
          height: 25.w,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: 'location_on',
              color: theme.colorScheme.primary,
              size: 60,
            ),
          ),
        ),

        SizedBox(height: 3.h),

        // Header title
        Text(
          !isHindi ? 'Enable Location Access' : 'लोकेशन की अनुमति दें',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 2.h),

        // Explanation text
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Text(
            !isHindi
              ? 'We need your location to provide accurate weather forecasts, local mandi prices, and region-specific farming guidance for your area.'
              : 'सटीक मौसम पूर्वानुमान, स्थानीय मंडी भाव और क्षेत्र-विशिष्ट कृषि मार्गदर्शन देने के लिए हमें आपकी लोकेशन की आवश्यकता है।',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        SizedBox(height: 3.h),

        // Benefits list
        _buildBenefitsList(theme, isHindi),
      ],
    );
  }

  /// Build benefits list
  Widget _buildBenefitsList(ThemeData theme, bool isHindi) {
    final benefits = [
      {
        'icon': 'wb_sunny',
        'title': !isHindi ? 'Accurate Weather' : 'सटीक मौसम जानकारी',
        'description': !isHindi ? 'Get precise weather forecasts for your location' : 'आपके क्षेत्र के अनुसार सटीक मौसम पूर्वानुमान पाएं',
      },
      {
        'icon': 'store',
        'title': !isHindi ? 'Local Mandi Prices' : 'स्थानीय मंडी भाव',
        'description': !isHindi ? 'View real-time crop prices from nearby mandis' : 'नजदीकी मंडियों के वास्तविक समय के भाव देखें',
      },
      {
        'icon': 'agriculture',
        'title': !isHindi ? 'Regional Guidance' : 'क्षेत्रीय मार्गदर्शन',
        'description': !isHindi ? 'Receive farming tips specific to your area' : 'अपने क्षेत्र के अनुसार खेती की सलाह पाएं',
      },
    ];

    return Column(
      children: benefits.map((benefit) {
        return Padding(
          padding: EdgeInsets.only(bottom: 2.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: benefit['icon'] as String,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      benefit['title'] as String,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      benefit['description'] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
