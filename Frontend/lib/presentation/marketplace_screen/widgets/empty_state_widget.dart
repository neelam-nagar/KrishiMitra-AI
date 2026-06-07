import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:provider/provider.dart';
import '../../../core/language_provider.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Empty state widget for marketplace
/// Shows helpful onboarding for first-time users with category suggestions
class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? submessage;
  final VoidCallback? onActionTapped;
  final String? actionLabel;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.submessage,
    this.onActionTapped,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';

    return Center(
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'shopping_bag_outlined',
              color: theme.brightness == Brightness.light
                  ? const Color(0xFFBDBDBD)
                  : const Color(0xFF6B6B6B),
              size: 80,
            ),
            SizedBox(height: 3.h),
            Text(
              isHindi ? _hindiMessage(message) : message,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (submessage != null) ...[
              SizedBox(height: 1.h),
              Text(
                isHindi ? _hindiSubMessage(submessage!) : submessage!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.brightness == Brightness.light
                      ? const Color(0xFF757575)
                      : const Color(0xFFB0B0B0),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onActionTapped != null && actionLabel != null) ...[
              SizedBox(height: 3.h),
              SizedBox(
                width: 60.w,
                height: 6.h,
                child: ElevatedButton(
                  onPressed: onActionTapped,
                  child: Text(
                    isHindi ? _hindiAction(actionLabel!) : actionLabel!,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _hindiMessage(String message) {
    switch (message) {
      case 'No products found':
        return 'कोई उत्पाद नहीं मिला';
      case 'No listings yet':
        return 'अभी कोई सूची नहीं है';
      case 'No messages':
        return 'कोई संदेश नहीं';
      default:
        return message;
    }
  }

  String _hindiSubMessage(String message) {
    switch (message) {
      case 'Try adjusting your filters or search query':
        return 'फ़िल्टर या खोज बदलकर पुनः प्रयास करें';
      case 'Start selling your crops by posting your first product':
        return 'अपनी पहली फसल जोड़कर बिक्री शुरू करें';
      case 'Your conversations with buyers and sellers will appear here':
        return 'खरीदारों और विक्रेताओं के संदेश यहाँ दिखेंगे';
      default:
        return message;
    }
  }

  String _hindiAction(String action) {
    switch (action) {
      case 'Clear Filters':
        return 'फ़िल्टर हटाएं';
      case 'Post Product':
        return 'फसल जोड़ें';
      default:
        return action;
    }
  }
}
