import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';

import '../../../core/app_export.dart';
import '../../../core/language_provider.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Price card widget for displaying crop price information
class PriceCardWidget extends StatelessWidget {
  final Map<String, dynamic> cropData;
  final VoidCallback onTap;

  const PriceCardWidget({
    super.key,
    required this.cropData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';
    final change = cropData['change'] as double;
    final isPositive = change >= 0;

    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: EdgeInsets.all(3.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Crop name and change indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      !isHindi ? cropData['name'] : cropData['nameHindi'],
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (cropData['price'] != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 0.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: isPositive
                            ? Colors.green.withAlpha(26)
                            : Colors.red.withAlpha(26),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomIconWidget(
                            iconName: isPositive
                                ? 'trending_up'
                                : 'trending_down',
                            size: 16,
                            color: isPositive ? Colors.green : Colors.red,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            '${change.abs()}%',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isPositive ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              SizedBox(height: 1.h),

              // Price information
              (cropData['price'] != null)
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 0.5.h),
                      child: Text(
                        '₹${cropData['price']}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔥 BIG AVG PRICE
                        Text(
                          '₹${cropData['avgPrice'] ?? 0}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 0.5.h),

                        // 🔹 MIN MAX BELOW
                        if (cropData['minPrice'] != null &&
                            cropData['maxPrice'] != null &&
                            cropData['minPrice'] != 0 &&
                            cropData['maxPrice'] != 0)
                          Text(
                            '${!isHindi ? 'Min' : 'न्यूनतम'}: ₹${cropData['minPrice']}   '
                            '${!isHindi ? 'Max' : 'अधिकतम'}: ₹${cropData['maxPrice']}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withAlpha(153),
                            ),
                          ),
                      ],
                    ),
              SizedBox(height: 1.h),

              // Unit and last updated
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${!isHindi ? 'per' : 'प्रति'} ${cropData['unit']}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(153),
                    ),
                  ),
                  Text(
                    cropData['lastUpdated'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(153),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build price info column
  Widget _buildPriceInfo(
    String label,
    String value,
    ThemeData theme, {
    bool isHighlighted = false,
  }) {
    // 🔥 Hide completely if value is empty or null-like
    if (value.trim().isEmpty || value == '₹') {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(153),
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
            color: isHighlighted ? theme.colorScheme.primary : null,
          ),
        ),
      ],
    );
  }
}
