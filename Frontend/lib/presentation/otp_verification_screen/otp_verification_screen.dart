// OTP screen is replaced by Google Sign-In.
// This file is kept to avoid broken route references.
// The login flow now goes directly from login → dashboard via Google Sign-In.

import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Auto-redirect to login if somehow this screen is reached
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, AppRoutes.mobileLogin);
    });
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
