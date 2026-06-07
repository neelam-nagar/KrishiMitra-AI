import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:provider/provider.dart';
import '../../../core/language_provider.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Product description widget with farming details
class ProductDescriptionWidget extends StatelessWidget {
  final Map<String, dynamic> description;

  const ProductDescriptionWidget({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.brightness == Brightness.light
              ? const Color(0xFFE0E0E0)
              : const Color(0xFF424242),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lang == 'en' ? 'Product Description' : 'उत्पाद विवरण',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 2.h),

          // Farming methods
          _DescriptionSection(
            icon: 'agriculture',
            title: lang == 'en' ? 'Farming Methods' : 'खेती की विधियाँ',
            content: description['farmingMethods'] as String,
          ),
          SizedBox(height: 2.h),

          // Storage conditions
          _DescriptionSection(
            icon: 'warehouse',
            title: lang == 'en' ? 'Storage Conditions' : 'भंडारण की स्थिति',
            content: description['storageConditions'] as String,
          ),
          SizedBox(height: 2.h),

          // Availability timeline
          _DescriptionSection(
            icon: 'schedule',
            title: lang == 'en' ? 'Availability Timeline' : 'उपलब्धता समय',
            content: description['availabilityTimeline'] as String,
          ),
        ],
      ),
    );
  }
}

/// Description section widget
class _DescriptionSection extends StatelessWidget {
  final String icon;
  final String title;
  final String content;

  const _DescriptionSection({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: theme.colorScheme.primary,
              size: 18,
            ),
            SizedBox(width: 2.w),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Text(
          content,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 12.sp,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
