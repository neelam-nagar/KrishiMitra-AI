import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';
import '../../../core/language_provider.dart';

/// Guide topic card widget for displaying farming guide topics
class GuideTopicCardWidget extends StatelessWidget {
  final Map<String, dynamic> guideData;
  final VoidCallback onTap;

  const GuideTopicCardWidget({
    super.key,
    required this.guideData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Colors.green.shade100,
            Colors.green.shade50,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade200,
          child: Icon(Icons.eco, color: Colors.green.shade800),
        ),
        title: Text(
          lang == 'en'
              ? (guideData['title'] ?? 'No Title')
              : (guideData['titleHindi'] ?? guideData['title'] ?? 'No Title'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.green.shade900,
          ),
        ),
        subtitle: Text(
          lang == 'en'
              ? (guideData['description'] ?? '')
              : (guideData['descriptionHindi'] ?? guideData['description'] ?? ''),
          style: theme.textTheme.bodySmall,
        ),
        trailing: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.green.shade700,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
        ),
        onTap: onTap,
      ),
    );
  }
}
