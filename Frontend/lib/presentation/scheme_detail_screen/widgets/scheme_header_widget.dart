import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import 'package:provider/provider.dart';
import '../../../core/language_provider.dart';

/// Widget displaying scheme header with title and agency logo
class SchemeHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> schemeData;

  const SchemeHeaderWidget({super.key, required this.schemeData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left icon / logo
          Container(
            width: 15.w,
            height: 15.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(
                alpha: 0.1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: schemeData["agencyLogo"] != null &&
                    schemeData["agencyLogo"].toString().isNotEmpty
                ? CustomImageWidget(
                    imageUrl: schemeData["agencyLogo"].toString(),
                    width: 15.w,
                    height: 15.w,
                    fit: BoxFit.contain,
                    semanticLabel:
                        schemeData["agencyLogoLabel"]?.toString() ??
                            "Agency logo",
                  )
                : Icon(
                    Icons.account_balance,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
          ),
          SizedBox(width: 3.w),

          // Title only (no small icon, no deadline, no agency line)
          Expanded(
            child: Text(
              lang == 'en'
                  ? (schemeData["title"]?.toString() ?? "Scheme")
                  : (schemeData["titleHindi"]?.toString() ??
                      schemeData["title"]?.toString() ??
                      "योजना"),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 18.sp,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
