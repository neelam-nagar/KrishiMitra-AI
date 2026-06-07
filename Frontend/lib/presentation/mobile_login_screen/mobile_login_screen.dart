import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';
import '../../core/language_provider.dart';
import '../../core/app_export.dart';
import '../../core/auth/auth_service.dart';
// FIX: removed unnecessary custom_icon_widget import (already in app_export)
import './widgets/language_toggle_widget.dart';
import './widgets/login_form_widget.dart';

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

  Future<void> _loadSavedPhoneNumber() async {
    // TODO: restore last used phone number from SharedPreferences
  }

  Future<void> _sendOTP() async {
    final lang = context.read<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';

    final rawNumber =
        _phoneNumber.phoneNumber?.replaceAll(RegExp(r'\D'), '') ?? '';
    if (rawNumber.length < 10) {
      setState(() {
        _errorMessage = isHindi
            ? 'कृपया सही मोबाइल नंबर दर्ज करें'
            : 'Please enter a valid mobile number';
      });
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() { _isLoading = true; _errorMessage = null; });

    await AuthService.instance.sendOtp(
      phoneNumber: _phoneNumber.phoneNumber ?? '',
      onCodeSent: (verificationId) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        Navigator.pushNamed(
          context,
          AppRoutes.otpVerification,
          arguments: {
            'verificationId': verificationId,
            'phoneNumber': _phoneNumber.phoneNumber ?? '',
          },
        );
      },
      onError: (message) {
        if (!mounted) return;
        setState(() { _isLoading = false; _errorMessage = message; });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';
    final size = MediaQuery.of(context).size;

    // FIX: WillPopScope → PopScope (WillPopScope is deprecated since Flutter 3.12)
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: SafeArea(
          child: Stack(
            children: [
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
                          Align(
                            alignment: Alignment.centerRight,
                            child: const LanguageToggleWidget(),
                          ),
                          SizedBox(height: 4.h),
                          _buildAppBranding(theme, isHindi),
                          SizedBox(height: 6.h),
                          LoginFormWidget(
                            formKey: _formKey,
                            phoneController: _phoneController,
                            phoneNumber: _phoneNumber,
                            isLoading: _isLoading,
                            errorMessage: _errorMessage,
                            onPhoneNumberChanged: (PhoneNumber number) {
                              setState(() { _phoneNumber = number; _errorMessage = null; });
                            },
                            onSendOTP: _sendOTP,
                          ),
                          const Spacer(),
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

  Widget _buildAppBranding(ThemeData theme, bool isHindi) {
    return Column(
      children: [
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
            child: Icon(Icons.agriculture, color: theme.colorScheme.onPrimary, size: 15.w),
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          isHindi ? 'कृषि मित्र AI' : 'KrishiMitra AI',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 1.h),
        Text(
          isHindi ? 'आपका डिजिटल कृषि साथी' : 'Your Digital Farming Companion',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFooter(ThemeData theme, bool isHindi) {
    return Column(
      children: [
        Text(
          isHindi
              ? 'लॉगिन करके, आप हमारी सेवा की शर्तों से सहमत हैं'
              : 'By logging in, you agree to our Terms of Service',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 0.5.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  minimumSize: Size(12.w, 5.h)),
              child: Text(isHindi ? 'नियम और शर्तें' : 'Terms',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
            ),
            Text(' • ', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  minimumSize: Size(12.w, 5.h)),
              child: Text(isHindi ? 'गोपनीयता नीति' : 'Privacy',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ],
    );
  }
}