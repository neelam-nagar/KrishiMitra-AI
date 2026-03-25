import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import '../../../core/app_export.dart';
import '../../../core/language_provider.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Step-by-step application process widget
class ApplicationProcessWidget extends StatelessWidget {
  final List<Map<String, dynamic>> steps;
  final String? officialWebsite;

  const ApplicationProcessWidget({
    super.key,
    required this.steps,
    this.officialWebsite,
  });

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(steps.length, (index) {
          final step = steps[index];
          final isLastStep = index == steps.length - 1;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        "${index + 1}",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (!isLastStep)
                    Container(
                      width: 2,
                      height: 8.h,
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                ],
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(bottom: isLastStep ? 0 : 2.h),
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang == 'en'
                          ? step["title"] as String
                          : (step["titleHindi"] ?? step["title"]) as String,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (step["description"] != null) ...[
                        SizedBox(height: 1.h),
                        Text(
                          lang == 'en'
                            ? step["description"] as String
                            : (step["descriptionHindi"] ?? step["description"]) as String,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
        if (officialWebsite != null) ...[
          SizedBox(height: 2.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _launchURL(officialWebsite!),
              icon: CustomIconWidget(
                iconName: 'open_in_new',
                size: 20,
                color: theme.colorScheme.onPrimary,
              ),
              label: Text(
                lang == 'en'
                  ? 'Visit Official Website'
                  : 'आधिकारिक वेबसाइट देखें',
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
