import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:sizer/sizer.dart';


/// OTP input widget with 6-digit individual boxes
/// Implements auto-focus progression and paste support
class OtpInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onCompleted;
  final bool isEnabled;

  const OtpInputWidget({
    super.key,
    required this.controller,
    required this.onCompleted,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final defaultPinTheme = PinTheme(
      width: 12.w,
      height: 6.h,
      textStyle: theme.textTheme.headlineSmall?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline, width: 1.5),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(color: colorScheme.primary, width: 2),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: colorScheme.primaryContainer.withValues(alpha: 0.1),
        border: Border.all(color: colorScheme.primary, width: 1.5),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(color: colorScheme.error, width: 2),
      ),
    );

    return Pinput(
      controller: controller,
      length: 6,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      submittedPinTheme: submittedPinTheme,
      errorPinTheme: errorPinTheme,
      enabled: isEnabled,
      autofocus: true,
      keyboardType: TextInputType.number,
      onCompleted: onCompleted,
      hapticFeedbackType: HapticFeedbackType.lightImpact,
      cursor: Container(width: 2, height: 3.h, color: colorScheme.primary),
    );
  }
}
