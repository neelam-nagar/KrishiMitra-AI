import 'package:provider/provider.dart';
import '../../../core/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Quick action buttons for common chatbot queries
/// Provides single-tap access to frequently asked topics
class QuickActionButtonsWidget extends StatelessWidget {
  final Function(String) onActionTap;

  const QuickActionButtonsWidget({
    super.key,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';

    final List<Map<String, String>> quickActions = isHindi
        ? [
            {
              'icon': 'wb_sunny',
              'label': 'मौसम',
              'query': 'आज का मौसम बताइए',
            },
            {
              'icon': 'currency_rupee',
              'label': 'भाव',
              'query': 'फसल के भाव बताइए',
            },
            {
              'icon': 'account_balance',
              'label': 'योजनाएँ',
              'query': 'सरकारी योजनाएँ',
            },
            {
              'icon': 'eco',
              'label': 'जैविक',
              'query': 'जैविक खेती की जानकारी',
            },
            {
              'icon': 'shopping_bag',
              'label': 'बाज़ार',
              'query': 'मार्केट की मदद',
            },
          ]
        : [
            {
              'icon': 'wb_sunny',
              'label': 'Weather',
              'query': 'Show me today\'s weather',
            },
            {
              'icon': 'currency_rupee',
              'label': 'Prices',
              'query': 'Show crop prices',
            },
            {
              'icon': 'account_balance',
              'label': 'Schemes',
              'query': 'Government schemes',
            },
            {
              'icon': 'eco',
              'label': 'Organic',
              'query': 'Organic farming tips',
            },
            {
              'icon': 'shopping_bag',
              'label': 'Market',
              'query': 'Marketplace help',
            },
          ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.brightness == Brightness.light
                ? const Color(0xFFE0E0E0)
                : const Color(0xFF424242),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isHindi ? 'त्वरित विकल्प' : 'Quick Actions',
            style: theme.textTheme.labelLarge?.copyWith(
              fontSize: 12.sp,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: quickActions.map((action) {
                return Padding(
                  padding: EdgeInsets.only(right: 2.w),
                  child: _buildActionChip(theme, action),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(ThemeData theme, Map<String, String> action) {
    return InkWell(
      onTap: () => onActionTap(action['query']!),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: action['icon']!,
              color: theme.colorScheme.primary,
              size: 16.sp,
            ),
            SizedBox(width: 2.w),
            Text(
              action['label']!,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
