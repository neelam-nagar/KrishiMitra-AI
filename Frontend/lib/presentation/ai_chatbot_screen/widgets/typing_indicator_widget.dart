import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/language_provider.dart';
import 'package:provider/provider.dart';

/// Typing indicator animation for AI processing
/// Shows agriculture-themed loading animation
class TypingIndicatorWidget extends StatefulWidget {
  const TypingIndicatorWidget({super.key});

  @override
  State<TypingIndicatorWidget> createState() => _TypingIndicatorWidgetState();
}

class _TypingIndicatorWidgetState extends State<TypingIndicatorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.smart_toy,
                color: theme.colorScheme.secondary,
                size: 16.sp,
              ),
            ),
          ),
          SizedBox(width: 2.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.brightness == Brightness.light
                    ? const Color(0xFFE0E0E0)
                    : const Color(0xFF424242),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang == 'hi' ? 'कृषि मित्र सोच रहा है…' : 'KrishiMitra is thinking…',
                  style: theme.textTheme.bodySmall,
                ),
                SizedBox(height: 0.8.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    return AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        final delay = index * 0.2;
                        final value = (_controller.value - delay).clamp(0.0, 1.0);
                        final scale = (1.0 - (value * 2 - 1).abs()) * 0.5 + 0.5;

                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 1.w),
                            width: 1.5.w,
                            height: 1.5.w,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}