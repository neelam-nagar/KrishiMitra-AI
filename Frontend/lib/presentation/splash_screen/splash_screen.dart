import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_export.dart';
import '../../core/language_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isInitializing = true;
  bool _showRetry = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack)),
    );
    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      setState(() { _isInitializing = true; _showRetry = false; });

      await Future.wait([
        _loadUserPreferences(),
        _fetchInitialData(),
        Future.delayed(const Duration(seconds: 3)),
      ]).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw Exception('Initialization timeout'),
      );

      if (mounted) _navigateToNextScreen();
    } catch (_) {
      if (mounted) setState(() { _isInitializing = false; _showRetry = true; });
    }
  }

  Future<void> _loadUserPreferences() async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  Future<void> _fetchInitialData() async {
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  // FIX: use real Firebase Auth instead of hardcoded booleans
  void _navigateToNextScreen() async {
    final isAuthenticated = FirebaseAuth.instance.currentUser != null;

    final prefs = await SharedPreferences.getInstance();
    final setupDone = prefs.getBool('profile_setup_done') ?? false;
    final targetRoute = isAuthenticated
        ? (setupDone ? AppRoutes.mainDashboard : AppRoutes.profileSetup)
        : AppRoutes.mobileLogin;

    Navigator.pushReplacementNamed(context, targetRoute);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.colorScheme.primary, theme.colorScheme.primaryContainer],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) => Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(scale: _scaleAnimation.value, child: child),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: CustomIconWidget(
                            iconName: 'agriculture', size: 64, color: theme.colorScheme.onPrimary),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'KrishiMitra AI',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      lang == 'en' ? 'Your Smart Farming Companion' : 'आपका स्मार्ट खेती साथी',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              if (_isInitializing)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 32, height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      lang == 'en' ? 'Initializing services...' : 'सेवाएँ प्रारंभ हो रही हैं...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                )
              else if (_showRetry)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                        iconName: 'error_outline', size: 48,
                        color: theme.colorScheme.onPrimary.withValues(alpha: 0.8)),
                    const SizedBox(height: 16),
                    Text(
                      lang == 'en' ? 'Connection timeout' : 'कनेक्शन समय समाप्त',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onPrimary, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      lang == 'en' ? 'Please check your internet connection' : 'कृपया अपना इंटरनेट कनेक्शन जांचें',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimary.withValues(alpha: 0.8)),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _initializeApp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.onPrimary,
                        foregroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomIconWidget(iconName: 'refresh', size: 20, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(lang == 'en' ? 'Retry' : 'पुनः प्रयास करें',
                            style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}