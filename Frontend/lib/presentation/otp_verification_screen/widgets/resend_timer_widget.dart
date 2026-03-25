import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';
import '../../../core/language_provider.dart';


/// Timer widget with resend OTP functionality
class ResendTimerWidget extends StatefulWidget {
  final VoidCallback onResend;
  final bool isEnabled;

  const ResendTimerWidget({
    super.key,
    required this.onResend,
    this.isEnabled = true,
  });

  @override
  State<ResendTimerWidget> createState() => _ResendTimerWidgetState();
}

class _ResendTimerWidgetState extends State<ResendTimerWidget> {
  int _secondsRemaining = 60;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _canResend = false;
    _secondsRemaining = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _handleResend() {
    if (_canResend && widget.isEnabled) {
      widget.onResend();
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _canResend ? (lang == 'en' ? "Didn't receive code?" : "कोड प्राप्त नहीं हुआ?") : (lang == 'en' ? 'Resend code in' : 'कोड पुनः भेजें'),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(width: 1.w),
        _canResend
            ? InkWell(
                onTap: _handleResend,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.5.h,
                  ),
                  child: Text(
                    lang == 'en' ? 'Resend OTP' : 'OTP पुनः भेजें',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: widget.isEnabled
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            : Text(
                '${_secondsRemaining}s',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ],
    );
  }
}
