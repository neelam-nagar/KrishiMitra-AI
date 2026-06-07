import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:provider/provider.dart';
import '../../../core/language_provider.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Price comparison widget showing market rates
class PriceComparisonWidget extends StatelessWidget {
  final Map<String, dynamic> priceData;

  const PriceComparisonWidget({super.key, required this.priceData});

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
            lang == 'en' ? 'Market Price Comparison' : 'बाजार मूल्य तुलना',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 2.h),

          // Current product price
          _PriceRow(
            label: lang == 'en' ? 'This Product' : 'यह उत्पाद',
            price: priceData['currentPrice'] as double,
            trend: priceData['trend'] as String,
            isHighlight: true,
          ),
          SizedBox(height: 1.h),

          // Market average
          _PriceRow(
            label: lang == 'en' ? 'Market Average' : 'बाजार औसत',
            price: priceData['marketAverage'] as double,
            trend: null,
            isHighlight: false,
          ),
          SizedBox(height: 1.h),

          // Mandi price
          _PriceRow(
            label: lang == 'en' ? 'Mandi Price' : 'मंडी मूल्य',
            price: priceData['mandiPrice'] as double,
            trend: null,
            isHighlight: false,
          ),
          SizedBox(height: 2.h),

          // Price trend indicator
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: _getTrendColor(
                priceData['trend'] as String,
                theme,
              ).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: _getTrendIcon(priceData['trend'] as String),
                  color: _getTrendColor(priceData['trend'] as String, theme),
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    _getTrendMessage(priceData['trend'] as String, lang),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getTrendColor(
                        priceData['trend'] as String,
                        theme,
                      ),
                      fontSize: 11.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTrendColor(String trend, ThemeData theme) {
    switch (trend.toLowerCase()) {
      case 'up':
        return const Color(0xFFD32F2F);
      case 'down':
        return const Color(0xFF388E3C);
      default:
        return theme.colorScheme.onSurfaceVariant;
    }
  }

  String _getTrendIcon(String trend) {
    switch (trend.toLowerCase()) {
      case 'up':
        return 'trending_up';
      case 'down':
        return 'trending_down';
      default:
        return 'trending_flat';
    }
  }

  String _getTrendMessage(String trend, String lang) {
    switch (trend.toLowerCase()) {
      case 'up':
        return lang == 'en'
            ? 'Price is higher than market average'
            : 'मूल्य बाजार औसत से अधिक है';
      case 'down':
        return lang == 'en'
            ? 'Great deal! Price is below market average'
            : 'अच्छा सौदा! मूल्य बाजार औसत से कम है';
      default:
        return lang == 'en'
            ? 'Price is at market average'
            : 'मूल्य बाजार औसत के बराबर है';
    }
  }
}

/// Price row widget
class _PriceRow extends StatelessWidget {
  final String label;
  final double price;
  final String? trend;
  final bool isHighlight;

  const _PriceRow({
    required this.label,
    required this.price,
    this.trend,
    required this.isHighlight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.brightness == Brightness.light
                ? const Color(0xFFE0E0E0)
                : const Color(0xFF424242),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w400,
              fontSize: 12.sp,
            ),
          ),
          Row(
            children: [
              Text(
                '₹${price.toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isHighlight ? theme.colorScheme.primary : null,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
              if (trend != null) ...[
                SizedBox(width: 2.w),
                CustomIconWidget(
                  iconName: trend == 'up' ? 'arrow_upward' : 'arrow_downward',
                  color: trend == 'up'
                      ? const Color(0xFFD32F2F)
                      : const Color(0xFF388E3C),
                  size: 16,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
