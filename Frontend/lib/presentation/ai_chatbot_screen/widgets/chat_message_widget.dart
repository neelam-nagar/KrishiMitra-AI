import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';

import '../../../core/app_export.dart';
import '../../../core/language_provider.dart';

/// Individual chat message bubble widget
/// Displays user and AI messages with appropriate styling and alignment
class ChatMessageWidget extends StatelessWidget {
  final Map<String, dynamic> message;
  final VoidCallback? onActionTap;

  const ChatMessageWidget({super.key, required this.message, this.onActionTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';
    final isUser = message['isUser'] as bool;
    final messageText = message['text'] as String;
    final hasImage = message['image'] != null;
    final hasAction = message['action'] != null;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _buildAvatar(theme, isUser: false),
            SizedBox(width: 2.w),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: 75.w),
                  padding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 1.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: isUser
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    border: isUser
                        ? null
                        : Border.all(
                            color: theme.brightness == Brightness.light
                                ? const Color(0xFFE0E0E0)
                                : const Color(0xFF424242),
                          ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasImage) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CustomImageWidget(
                            imageUrl: message['image'] as String,
                            width: 60.w,
                            height: 25.h,
                            fit: BoxFit.cover,
                            semanticLabel:
                                message['imageSemanticLabel'] as String? ??
                                (isHindi ? 'चैट में फसल की तस्वीर' : 'Crop image shared in chat'),
                          ),
                        ),
                        SizedBox(height: 1.h),
                      ],
                      Text(
                        messageText,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isUser
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasAction) ...[
                  SizedBox(height: 1.h),
                  _buildActionButton(
                    theme,
                    message['action'] as Map<String, dynamic>,
                    isHindi,
                  ),
                ],
                SizedBox(height: 0.5.h),
                Text(
                  isHindi ? 'अभी' : message['time'] as String,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 9.sp,
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            SizedBox(width: 2.w),
            _buildAvatar(theme, isUser: true),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme, {required bool isUser}) {
    return Container(
      width: 10.w,
      height: 10.w,
      decoration: BoxDecoration(
        color: isUser
            ? theme.colorScheme.primary.withValues(alpha: 0.2)
            : theme.colorScheme.secondary.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: CustomIconWidget(
          iconName: isUser ? 'person' : 'smart_toy',
          color: isUser
              ? theme.colorScheme.primary
              : theme.colorScheme.secondary,
          size: 20.sp,
        ),
      ),
    );
  }

  Widget _buildActionButton(ThemeData theme, Map<String, dynamic> action, bool isHindi) {
    return InkWell(
      onTap: onActionTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.primary),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: action['icon'] as String,
              color: theme.colorScheme.primary,
              size: 18.sp,
            ),
            SizedBox(width: 2.w),
            Text(
              isHindi
                  ? (action['label_hi'] as String? ?? action['label'] as String)
                  : action['label'] as String,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
