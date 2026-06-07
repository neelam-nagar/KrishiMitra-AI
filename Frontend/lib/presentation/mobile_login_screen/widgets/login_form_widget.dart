import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import 'package:provider/provider.dart';
import '../../../core/language_provider.dart';

/// Login form widget containing phone input and send OTP button
/// Handles validation, formatting, and OTP generation
class LoginFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController phoneController;
  final PhoneNumber phoneNumber;
  final bool isLoading;
  final String? errorMessage;
  final ValueChanged<PhoneNumber> onPhoneNumberChanged;
  final VoidCallback onSendOTP;

  const LoginFormWidget({
    super.key,
    required this.formKey,
    required this.phoneController,
    required this.phoneNumber,
    required this.isLoading,
    required this.errorMessage,
    required this.onPhoneNumberChanged,
    required this.onSendOTP,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            isHindi ? 'मोबाइल नंबर से लॉगिन करें' : 'Login with Mobile Number',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 1.h),

          // Section description
          Text(
            isHindi
                ? 'अपना 10 अंकों का मोबाइल नंबर दर्ज करें'
                : 'Enter your 10-digit mobile number',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          SizedBox(height: 3.h),

          // Phone number input field
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: errorMessage != null
                    ? theme.colorScheme.error
                    : theme.colorScheme.outline,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: InternationalPhoneNumberInput(
              onInputChanged: onPhoneNumberChanged,
              onInputValidated: (bool value) {},
              selectorConfig: const SelectorConfig(
                selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                useBottomSheetSafeArea: true,
                setSelectorButtonAsPrefixIcon: true,
                leadingPadding: 16,
              ),
              ignoreBlank: false,
              selectorTextStyle: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              initialValue: phoneNumber,
              textFieldController: phoneController,
              formatInput: false,
              keyboardType: TextInputType.number,
              inputDecoration: InputDecoration(
                hintText: isHindi ? '10 अंकों का नंबर' : '10-digit number',
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.6,
                  ),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 2.h,
                ),
                prefixIcon: Padding(
                  padding: EdgeInsets.only(left: 4.w, right: 2.w),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomImageWidget(
                        imageUrl: 'https://flagcdn.com/w40/in.png',
                        width: 8.w,
                        height: 6.w,
                        fit: BoxFit.cover,
                        semanticLabel: 'Indian flag icon',
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        '+91',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Container(
                        width: 1,
                        height: 4.h,
                        color: theme.colorScheme.outline,
                      ),
                    ],
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return isHindi
                      ? 'कृपया मोबाइल नंबर दर्ज करें'
                      : 'Please enter mobile number';
                }
                if (value.length != 10) {
                  return isHindi
                      ? 'कृपया 10 अंकों का नंबर दर्ज करें'
                      : 'Please enter 10-digit number';
                }
                return null;
              },
              inputBorder: InputBorder.none,
              countries: const ['IN'],
              locale: isHindi ? 'hi' : 'en',
            ),
          ),

          // Error message
          if (errorMessage != null) ...[
            SizedBox(height: 1.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'error_outline',
                  color: theme.colorScheme.error,
                  size: 4.w,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    errorMessage!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ],

          SizedBox(height: 4.h),

          // Send OTP button
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton(
              onPressed: isLoading ? null : onSendOTP,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: theme.colorScheme.primary.withValues(
                  alpha: 0.5,
                ),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 5.w,
                      height: 5.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Text(
                      isHindi ? 'OTP भेजें' : 'Send OTP',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),

          SizedBox(height: 2.h),

          // Help text
          Center(
            child: Text(
              isHindi
                  ? 'आपके मोबाइल नंबर पर OTP भेजा जाएगा'
                  : 'An OTP will be sent to your mobile number',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
