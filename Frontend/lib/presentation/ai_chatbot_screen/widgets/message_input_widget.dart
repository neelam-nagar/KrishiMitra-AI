import 'package:provider/provider.dart';
import '../../../core/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Message input widget with text, voice, and image capabilities
/// Provides multiple input methods for farmer convenience
class MessageInputWidget extends StatefulWidget {
  final Function(String) onSendMessage;
  final VoidCallback onImagePick;
  final VoidCallback onVoiceRecord;

  const MessageInputWidget({
    super.key,
    required this.onSendMessage,
    required this.onImagePick,
    required this.onVoiceRecord,
  });

  @override
  State<MessageInputWidget> createState() => _MessageInputWidgetState();
}

class _MessageInputWidgetState extends State<MessageInputWidget> {
  final TextEditingController _messageController = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      setState(() {
        _hasText = _messageController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _handleSend() {
    if (_hasText) {
      final message = _messageController.text.trim();
      widget.onSendMessage(message);
      _messageController.clear();
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';

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
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Image picker button
            IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                widget.onImagePick();
              },
              icon: CustomIconWidget(
                iconName: 'image',
                color: theme.colorScheme.primary,
                size: 24.sp,
              ),
              tooltip: isHindi ? 'तस्वीर जोड़ें' : 'Add image',
            ),
            SizedBox(width: 2.w),
            // Text input field
            Expanded(
              child: Container(
                constraints: BoxConstraints(minHeight: 6.h, maxHeight: 15.h),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.light
                      ? const Color(0xFFF5F5F5)
                      : const Color(0xFF2D2D2D),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
                  decoration: InputDecoration(
                    hintText: isHindi ? 'अपना सवाल लिखें...' : 'Type your question...',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.6,
                      ),
                      fontSize: 14.sp,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.5.h,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 2.w),
            // Send or voice button
            _hasText
                ? IconButton(
                    onPressed: _handleSend,
                    icon: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: CustomIconWidget(
                        iconName: 'send',
                        color: theme.colorScheme.onPrimary,
                        size: 20.sp,
                      ),
                    ),
                    tooltip: isHindi ? 'संदेश भेजें' : 'Send message',
                  )
                : IconButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      widget.onVoiceRecord();
                    },
                    icon: CustomIconWidget(
                      iconName: 'mic',
                      color: theme.colorScheme.primary,
                      size: 24.sp,
                    ),
                    tooltip: isHindi ? 'आवाज़ संदेश' : 'Voice message',
                  ),
          ],
        ),
      ),
    );
  }
}
