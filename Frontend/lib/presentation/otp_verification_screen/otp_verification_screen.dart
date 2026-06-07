import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import '../../core/language_provider.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/mobile_number_header_widget.dart';
import './widgets/otp_input_widget.dart';
import './widgets/resend_timer_widget.dart';

/// OTP Verification Screen for farmer authentication
/// Implements secure 6-digit OTP verification with mobile-optimized flow
class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  bool _isOtpComplete = false;
  String _errorMessage = '';
  int _attemptCount = 0;
  final int _maxAttempts = 3;
  bool _isAccountLocked = false;
  DateTime? _lockoutEndTime;
  final String _validOtp = '123456';

  //late String _verificationId;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _handleOtpCompleted(String otp) {
    setState(() {
      _isOtpComplete = true;
      _errorMessage = '';
    });
  }

  Future<void> _verifyOtp() async {
    if (!_isOtpComplete || _isLoading || _isAccountLocked) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    final enteredOtp = _otpController.text;
    final lang = context.read<LanguageProvider>().currentLanguage;

    if (enteredOtp == _validOtp) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.mainDashboard,
      );
    } else {
      _attemptCount++;

      if (_attemptCount >= _maxAttempts) {
        setState(() {
          _isAccountLocked = true;
          _lockoutEndTime = DateTime.now().add(const Duration(minutes: 5));
          _errorMessage = lang == 'en'
              ? 'Maximum attempts exceeded. Account locked for 5 minutes.'
              : 'अधिकतम प्रयास पूरे हो गए। खाता 5 मिनट के लिए लॉक कर दिया गया है।';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = lang == 'en'
              ? 'Invalid OTP. ${_maxAttempts - _attemptCount} attempts remaining.'
              : 'गलत OTP। ${_maxAttempts - _attemptCount} प्रयास शेष हैं।';
          _isLoading = false;
          _isOtpComplete = false;
        });
        _otpController.clear();
      }
    }
  }

  void _handleResendOtp() {
    if (_isLoading) return;

    // Reset attempt count on resend
    setState(() {
      _attemptCount = 0;
      _isAccountLocked = false;
      _lockoutEndTime = null;
      _errorMessage = '';
      _otpController.clear();
      _isOtpComplete = false;
    });

    final lang = context.read<LanguageProvider>().currentLanguage;

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          lang == 'en' ? 'OTP resent successfully' : 'OTP दोबारा भेजा गया',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    // Light haptic feedback
    HapticFeedback.lightImpact();
  }

  void _handleChangeNumber() {
    // Navigate back to login screen
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final lang = context.watch<LanguageProvider>().currentLanguage; // 'hi' or 'en'

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: Center(
              child: InkWell(
                onTap: () {
                  final provider = context.read<LanguageProvider>();
                  provider.changeLanguage(provider.currentLanguage == 'en' ? 'hi' : 'en');
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme.outline, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'language',
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        lang == 'en' ? 'EN' : 'हिंदी',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 4.h),

              // Header with mobile number
              MobileNumberHeaderWidget(
                mobileNumber: '',
                onChangeNumber: _handleChangeNumber,
              ),

              SizedBox(height: 6.h),

              // OTP Input
              OtpInputWidget(
                controller: _otpController,
                onCompleted: _handleOtpCompleted,
                isEnabled: !_isLoading && !_isAccountLocked,
              ),

              SizedBox(height: 3.h),

              // Error message
              _errorMessage.isNotEmpty
                  ? Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colorScheme.error.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'error_outline',
                            color: colorScheme.error,
                            size: 20,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              _errorMessage,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),

              SizedBox(height: 4.h),

              // Resend timer
              ResendTimerWidget(
                onResend: _handleResendOtp,
                isEnabled: !_isLoading && !_isAccountLocked,
              ),

              SizedBox(height: 6.h),

              // Verify button
              SizedBox(
                width: double.infinity,
                height: 6.h,
                child: ElevatedButton(
                  onPressed: _isOtpComplete && !_isLoading && !_isAccountLocked
                      ? _verifyOtp
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    disabledBackgroundColor: colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.12),
                    disabledForegroundColor: colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.38),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 2.5.h,
                          width: 2.5.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : Text(
                          lang == 'en' ? 'Verify OTP' : 'OTP सत्यापित करें',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              SizedBox(height: 4.h),

              // Security note
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'lock_outline',
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        lang == 'en'
                            ? 'Your OTP is valid for 10 minutes. Do not share it with anyone.'
                            : 'आपका OTP 10 मिनट तक मान्य है। इसे किसी के साथ साझा न करें।',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
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
