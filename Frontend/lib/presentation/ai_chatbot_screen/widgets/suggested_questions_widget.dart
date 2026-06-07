import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';
import 'package:provider/provider.dart';
import '../../../core/language_provider.dart';

/// Suggested questions widget for conversation guidance
/// Appears during conversation lulls to help farmers
class SuggestedQuestionsWidget extends StatelessWidget {
  final void Function(String) onQuestionTap;

  const SuggestedQuestionsWidget({
    super.key,
    required this.onQuestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final bool isEnglish = lang == 'en';

    final List<Map<String, String>> suggestions = isEnglish
        ? [
            {
              'icon': 'wb_sunny',
              'question': 'What is the weather forecast for next week?',
            },
            {
              'icon': 'currency_rupee',
              'question': 'Show me today\'s mandi prices for wheat',
            },
            {
              'icon': 'account_balance',
              'question': 'What government schemes are available for farmers?',
            },
            {'icon': 'eco', 'question': 'How can I start organic farming?'},
            {
              'icon': 'water_drop',
              'question': 'What are the best water management practices?',
            },
          ]
        : [
            {
              'icon': 'wb_sunny',
              'question': 'अगले हफ्ते का मौसम कैसा रहेगा?',
            },
            {
              'icon': 'currency_rupee',
              'question': 'आज गेहूं के मंडी भाव बताइए',
            },
            {
              'icon': 'account_balance',
              'question': 'किसानों के लिए कौन‑कौन सी सरकारी योजनाएँ हैं?',
            },
            {'icon': 'eco', 'question': 'जैविक खेती कैसे शुरू करें?'},
            {
              'icon': 'water_drop',
              'question': 'पानी प्रबंधन की सबसे अच्छी विधियाँ क्या हैं?',
            },
          ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'lightbulb',
                color: theme.colorScheme.secondary,
                size: 20.sp,
              ),
              SizedBox(width: 2.w),
              Text(
                isEnglish ? 'Suggested Questions' : 'सुझाए गए प्रश्न',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          ...suggestions.map((suggestion) {
            return Padding(
              padding: EdgeInsets.only(bottom: 1.h),
              child: InkWell(
                onTap: () => onQuestionTap(suggestion['question']!),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.brightness == Brightness.light
                          ? const Color(0xFFE0E0E0)
                          : const Color(0xFF424242),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomIconWidget(
                          iconName: suggestion['icon']!,
                          color: theme.colorScheme.primary,
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          suggestion['question']!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 11.5.sp,
                          ),
                        ),
                      ),
                      CustomIconWidget(
                        iconName: 'arrow_forward',
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 16.sp,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
