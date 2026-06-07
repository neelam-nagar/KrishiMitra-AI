import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';

import '../../../core/app_export.dart';
import '../../../core/language_provider.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Product information widget displaying crop details
class ProductInfoWidget extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductInfoWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Crop name (bilingual)
          Text(
            lang == 'en'
                ? product['cropName'] as String
                : (product['cropNameHindi'] ?? product['cropName']) as String,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 18.sp,
            ),
          ),
          SizedBox(height: 2.h),

          // Price
          Row(
            children: [
              Text(
                '₹${product['pricePerUnit']}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 22.sp,
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                lang == 'en'
                    ? 'per ${product['unit']}'
                    : 'प्रति ${product['unit']}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Variety and Quantity
          Row(
            children: [
              Expanded(
                child: _InfoChip(
                  icon: 'category',
                  label: lang == 'en' ? 'Variety' : 'किस्म',
                  value: product['variety'] as String,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _InfoChip(
                  icon: 'inventory_2',
                  label: lang == 'en' ? 'Available' : 'उपलब्ध',
                  value: '${product['quantityAvailable']} ${product['unit']}',
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Harvest date and certification
          Row(
            children: [
              Expanded(
                child: _InfoChip(
                  icon: 'calendar_today',
                  label: lang == 'en' ? 'Harvest Date' : 'कटाई तिथि',
                  value: product['harvestDate'] as String,
                ),
              ),
              SizedBox(width: 2.w),
              if (product['isOrganic'] == true)
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.primary,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'verified',
                          color: theme.colorScheme.primary,
                          size: 16,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          lang == 'en' ? 'Organic' : 'जैविक',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 11.sp,
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

/// Info chip widget for displaying product details
class _InfoChip extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.brightness == Brightness.light
              ? const Color(0xFFE0E0E0)
              : const Color(0xFF424242),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: icon,
                color: theme.colorScheme.onSurfaceVariant,
                size: 14,
              ),
              SizedBox(width: 1.w),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}