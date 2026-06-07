import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';
import '../../../core/language_provider.dart';


/// Header widget displaying masked mobile number with change option
class MobileNumberHeaderWidget extends StatelessWidget {
  final String mobileNumber;
  final VoidCallback onChangeNumber;

  const MobileNumberHeaderWidget({
    super.key,
    required this.mobileNumber,
    required this.onChangeNumber,
  });

  String _maskMobileNumber(String number) {
    if (number.length < 10) return number;
    final lastFour = number.substring(number.length - 5);
    return '+91 XXXXX $lastFour';
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Text(
          lang == 'en' ? 'OTP Verification' : 'OTP सत्यापन',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 2.h),
        Text(
          lang == 'en' ? 'Enter the 6-digit code sent to' : 'आपके मोबाइल नंबर पर भेजा गया 6 अंकों का कोड दर्ज करें',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 1.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _maskMobileNumber(mobileNumber),
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 2.w),
            InkWell(
              onTap: onChangeNumber,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                child: Text(
                  lang == 'en' ? 'Change' : 'बदलें',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
