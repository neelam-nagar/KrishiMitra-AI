import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import 'package:provider/provider.dart';
import '../../../core/language_provider.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Individual notification card with category-specific styling
/// Displays notification details with swipe-to-dismiss functionality
class NotificationCardWidget extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const NotificationCardWidget({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  Color _getCategoryColor(BuildContext context, String category) {
    switch (category.toLowerCase()) {
      case 'schemes':
        return const Color(0xFF1976D2);
      case 'prices':
        return const Color(0xFF388E3C);
      case 'weather':
        return const Color(0xFFF57C00);
      case 'messages':
        return const Color(0xFF7B1FA2);
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'schemes':
        return 'account_balance';
      case 'prices':
        return 'trending_up';
      case 'weather':
        return 'wb_sunny';
      case 'messages':
        return 'chat_bubble';
      default:
        return 'notifications';
    }
  }

  String _formatTimestamp(DateTime timestamp, bool isHindi) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return isHindi
          ? '${difference.inMinutes} मिनट पहले'
          : '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return isHindi
          ? '${difference.inHours} घंटे पहले'
          : '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return isHindi
          ? '${difference.inDays} दिन पहले'
          : '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';
    final isUnread = notification['isUnread'] as bool? ?? false;
    final category = notification['category'] as String;
    final categoryColor = _getCategoryColor(context, category);

    return Dismissible(
      key: Key(notification['id'].toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        onDismiss();
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 4.w),
        decoration: BoxDecoration(
          color: const Color(0xFFE53935),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: CustomIconWidget(
          iconName: 'delete',
          color: Colors.white,
          size: 24,
        ),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          margin: EdgeInsets.only(bottom: 1.5.h),
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: isUnread
                ? categoryColor.withValues(alpha: 0.05)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: isUnread
                  ? categoryColor.withValues(alpha: 0.3)
                  : theme.brightness == Brightness.light
                  ? const Color(0xFFE0E0E0)
                  : const Color(0xFF424242),
              width: isUnread ? 2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 100.0.h,
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
              SizedBox(width: 3.w),
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: CustomIconWidget(
                  iconName: _getCategoryIcon(category),
                  color: categoryColor,
                  size: 24,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'] as String,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: isUnread
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE53935),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      notification['description'] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.brightness == Brightness.light
                            ? const Color(0xFF757575)
                            : const Color(0xFFB0B0B0),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatTimestamp(
                            notification['timestamp'] as DateTime,
                            isHindi,
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 9.sp,
                            color: categoryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (notification['priority'] == 'high')
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 1.5.w,
                              vertical: 0.3.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFE53935,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Text(
                              isHindi ? 'महत्वपूर्ण' : 'Important',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 9.sp,
                                color: const Color(0xFFE53935),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}