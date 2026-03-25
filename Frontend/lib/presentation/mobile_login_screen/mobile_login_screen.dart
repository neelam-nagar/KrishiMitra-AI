import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:sizer/sizer.dart';

import 'package:provider/provider.dart';
import '../../core/language_provider.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/language_toggle_widget.dart';
import './widgets/login_form_widget.dart';

//import 'package:firebase_auth/firebase_auth.dart';

/// Mobile Login Screen for KrishiMitra AI
/// Enables secure farmer authentication using mobile number and OTP verification
/// Optimized for rural users with simple, accessible interface
class MobileLoginScreen extends StatefulWidget {
  const MobileLoginScreen({super.key});

  @override
  State<MobileLoginScreen> createState() => _MobileLoginScreenState();
}

class _MobileLoginScreenState extends State<MobileLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'IN', phoneNumber: '');
  bool _isLoading = false;
  String? _errorMessage;

 // final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadSavedPhoneNumber();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  /// Load last used mobile number from secure storage
  Future<void> _loadSavedPhoneNumber() async {
    // In production, load from SharedPreferences
    // For now, keeping empty for first-time users
  }

  /// Save mobile number to secure storage
  Future<void> _savePhoneNumber(String phoneNumber) async {
    // In production, save to SharedPreferences
    // await SharedPreferences.getInstance().then((prefs) => prefs.setString('last_phone', phoneNumber));
  }

  /// Validate and send OTP
  Future<void> _sendOTP() async {
    final lang = context.read<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';

    if (_phoneNumber.phoneNumber == null ||
        _phoneNumber.phoneNumber!.replaceAll(RegExp(r'\D'), '').length < 10) {
      setState(() {
        _errorMessage = isHindi
            ? 'कृपया सही मोबाइल नंबर दर्ज करें'
            : 'Please enter a valid mobile number';
      });
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // 🔁 FAKE OTP delay (hard‑coded flow)
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      Navigator.pushNamed(
        context,
        '/otp-verification-screen',
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  /// Handle back button press
  Future<bool> _onWillPop() async {
    // Exit app if coming from splash
    SystemNavigator.pop();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: SafeArea(
          child: Stack(
            children: [
              // Background gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.1),
                      theme.colorScheme.surface,
                    ],
                  ),
                ),
              ),

              // Main content
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: size.height - MediaQuery.of(context).padding.top,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: Column(
                        children: [
                          SizedBox(height: 2.h),

                          // Language toggle
                          Align(
                            alignment: Alignment.centerRight,
                            child: const LanguageToggleWidget(),
                          ),

                          SizedBox(height: 4.h),

                          // App logo and branding
                          _buildAppBranding(theme, isHindi),

                          SizedBox(height: 6.h),

                          // Login form
                          LoginFormWidget(
                            formKey: _formKey,
                            phoneController: _phoneController,
                            phoneNumber: _phoneNumber,
                            isLoading: _isLoading,
                            errorMessage: _errorMessage,

                            onPhoneNumberChanged: (PhoneNumber number) {
                              setState(() {
                                _phoneNumber = number;
                                _errorMessage = null;
                              });
                            },
                            onSendOTP: _sendOTP,
                          ),

                          const Spacer(),

                          // Footer text
                          _buildFooter(theme, isHindi),

                          SizedBox(height: 3.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build app branding section with logo and tagline
  Widget _buildAppBranding(ThemeData theme, bool isHindi) {
    return Column(
      children: [
        // Agriculture-themed logo
        Container(
          width: 30.w,
          height: 30.w,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: 'agriculture',
              color: theme.colorScheme.onPrimary,
              size: 15.w,
            ),
          ),
        ),

        SizedBox(height: 3.h),

        // App name
        Text(
          isHindi ? 'कृषि मित्र AI' : 'KrishiMitra AI',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),

        SizedBox(height: 1.h),

        // Tagline
        Text(
          isHindi ? 'आपका डिजिटल कृषि साथी' : 'Your Digital Farming Companion',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Build footer with terms and privacy policy
  Widget _buildFooter(ThemeData theme, bool isHindi) {
    return Column(
      children: [
        Text(
          isHindi
              ? 'लॉगिन करके, आप हमारी सेवा की शर्तों से सहमत हैं'
              : 'By logging in, you agree to our Terms of Service',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 0.5.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                // Navigate to terms screen
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                minimumSize: Size(12.w, 5.h),
              ),
              child: Text(
                isHindi ? 'नियम और शर्तें' : 'Terms',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              ' • ',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to privacy policy screen
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                minimumSize: Size(12.w, 5.h),
              ),
              child: Text(
                isHindi ? 'गोपनीयता नीति' : 'Privacy',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
