import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';

import '../../core/language_provider.dart';
import '../../core/auth/auth_service.dart';
import '../../core/app_export.dart';
import './widgets/mobile_number_header_widget.dart';
import './widgets/otp_input_widget.dart';
import './widgets/resend_timer_widget.dart';

/// OTP Verification Screen.
///
/// Expects route arguments:
///   {
///     'verificationId': String,   — from Firebase codeSent callback
///     'phoneNumber':    String,   — E.164, shown in the header
///   }
///
/// On success → navigates to main dashboard.
/// On failure → shows the Firebase error message inline (no account lockout
///              needed here — Firebase enforces rate-limiting server-side).
class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();

  late String _verificationId;
  late String _phoneNumber;

  bool _isLoading = false;
  bool _isOtpComplete = false;
  String _errorMessage = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Read arguments passed from MobileLoginScreen
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _verificationId = args?['verificationId'] as String? ?? '';
    _phoneNumber = args?['phoneNumber'] as String? ?? '';
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // OTP field callbacks
  // ---------------------------------------------------------------------------

  void _handleOtpCompleted(String otp) {
    setState(() {
      _isOtpComplete = true;
      _errorMessage = '';
    });
  }

  // ---------------------------------------------------------------------------
  // Verify
  // ---------------------------------------------------------------------------

  Future<void> _verifyOtp() async {
    if (!_isOtpComplete || _isLoading) return;
    if (_verificationId.isEmpty) {
      setState(() => _errorMessage = 'Session expired. Please go back and try again.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final error = await AuthService.instance.verifyOtp(
      verificationId: _verificationId,
      smsCode: _otpController.text.trim(),
    );

    if (!mounted) return;

    if (error == null) {
      // Success — Firebase currentUser is now set.
      // Navigate to dashboard, clearing the entire back-stack so the user
      // cannot press Back to return to the login flow.
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.mainDashboard,
        (route) => false,
      );
    } else {
      setState(() {
        _isLoading = false;
        _isOtpComplete = false;
        _errorMessage = _localise(error);
      });
      _otpController.clear();
      HapticFeedback.mediumImpact();
    }
  }

  // ---------------------------------------------------------------------------
  // Resend
  // ---------------------------------------------------------------------------

  Future<void> _handleResendOtp() async {
    if (_isLoading || _phoneNumber.isEmpty) return;

    setState(() {
      _errorMessage = '';
      _otpController.clear();
      _isOtpComplete = false;
    });

    await AuthService.instance.sendOtp(
      phoneNumber: _phoneNumber,
      onCodeSent: (String newVerificationId) {
        if (!mounted) return;
        setState(() => _verificationId = newVerificationId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_localise('OTP resent successfully')),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
        HapticFeedback.lightImpact();
      },
      onError: (String message) {
        if (!mounted) return;
        setState(() => _errorMessage = _localise(message));
      },
    );
  }

  // ---------------------------------------------------------------------------
  // i18n helper (Phase 2 will replace this with proper ARB localisation)
  // ---------------------------------------------------------------------------

  String _localise(String englishMessage) {
    final lang = context.read<LanguageProvider>().currentLanguage;
    if (lang != 'hi') return englishMessage;

    const Map<String, String> _hi = {
      'OTP resent successfully': 'OTP दोबारा भेजा गया',
      'Session expired. Please go back and try again.':
          'सत्र समाप्त हो गया। कृपया वापस जाएं और पुनः प्रयास करें।',
      'The OTP you entered is incorrect.': 'दर्ज किया गया OTP गलत है।',
      'The OTP has expired. Please request a new one.':
          'OTP की अवधि समाप्त हो गई। कृपया नया OTP मंगाएं।',
      'Too many attempts. Please wait a few minutes.':
          'बहुत अधिक प्रयास हो गए। कृपया कुछ मिनट प्रतीक्षा करें।',
      'Verification failed. Please try again.':
          'सत्यापन विफल। कृपया पुनः प्रयास करें।',
    };
    return _hi[englishMessage] ?? englishMessage;
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final isHindi = lang == 'hi';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: CustomIconWidget(
              iconName: 'arrow_back', color: colorScheme.onSurface, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: Center(
              child: InkWell(
                onTap: () {
                  final p = context.read<LanguageProvider>();
                  p.changeLanguage(p.currentLanguage == 'en' ? 'hi' : 'en');
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                          iconName: 'language',
                          color: colorScheme.primary,
                          size: 20),
                      SizedBox(width: 1.w),
                      Text(
                        isHindi ? 'हिंदी' : 'EN',
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

              MobileNumberHeaderWidget(
                mobileNumber: _phoneNumber,
                onChangeNumber: () => Navigator.pop(context),
              ),

              SizedBox(height: 6.h),

              OtpInputWidget(
                controller: _otpController,
                onCompleted: _handleOtpCompleted,
                isEnabled: !_isLoading,
              ),

              SizedBox(height: 3.h),

              // Error banner
              if (_errorMessage.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 4.w, vertical: 1.5.h),
                  decoration: BoxDecoration(
                    color: colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: colorScheme.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                          iconName: 'error_outline',
                          color: colorScheme.error,
                          size: 20),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: colorScheme.error),
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 4.h),

              ResendTimerWidget(
                onResend: _handleResendOtp,
                isEnabled: !_isLoading,
              ),

              SizedBox(height: 6.h),

              // Verify button
              SizedBox(
                width: double.infinity,
                height: 6.h,
                child: ElevatedButton(
                  onPressed:
                      _isOtpComplete && !_isLoading ? _verifyOtp : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    disabledBackgroundColor:
                        colorScheme.onSurfaceVariant.withValues(alpha: 0.12),
                    disabledForegroundColor:
                        colorScheme.onSurfaceVariant.withValues(alpha: 0.38),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 2.5.h,
                          width: 2.5.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.onPrimary),
                          ),
                        )
                      : Text(
                          isHindi ? 'OTP सत्यापित करें' : 'Verify OTP',
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
                  color:
                      colorScheme.primaryContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                        iconName: 'lock_outline',
                        color: colorScheme.primary,
                        size: 20),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        isHindi
                            ? 'आपका OTP 10 मिनट तक मान्य है। इसे किसी के साथ साझा न करें।'
                            : 'Your OTP is valid for 10 minutes. Do not share it with anyone.',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant),
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