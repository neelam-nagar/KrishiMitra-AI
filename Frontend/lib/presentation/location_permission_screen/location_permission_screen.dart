import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/language_provider.dart';
import '../../widgets/custom_bottom_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/location_header_widget.dart';
import './widgets/location_permission_button_widget.dart';
import './widgets/manual_location_selection_widget.dart';
import './widgets/privacy_notice_widget.dart';

/// Location Permission Screen for KrishiMitra AI
/// Enables precise agricultural data delivery through location access
/// with manual fallback options for farmers
class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  bool _isLoading = false;
  bool _showManualSelection = false;
  String? _detectedLocation;
  String? _errorMessage;
  LocationPermission? _permissionStatus;

  @override
  void initState() {
    super.initState();
    _checkLocationServiceStatus();
  }

  /// Check if location services are enabled
  Future<void> _checkLocationServiceStatus() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _errorMessage =
            'लोकेशन सेवा बंद है। कृपया सेटिंग में चालू करें।';
      });
    }
  }

  /// Request location permission and get current location
  Future<void> _requestLocationPermission() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'लोकेशन सेवा बंद है। कृपया सेटिंग में चालू करें।';
        });
        return;
      }

      // Request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoading = false;
            _permissionStatus = permission;
            _errorMessage =
                'लोकेशन अनुमति अस्वीकृत है। आप मैन्युअल चयन कर सकते हैं।';
            _showManualSelection = true;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
          _permissionStatus = permission;
          _errorMessage =
              'लोकेशन अनुमति स्थायी रूप से अस्वीकृत है। सेटिंग से अनुमति दें या मैन्युअल चयन करें।';
          _showManualSelection = true;
        });
        return;
      }

      // Get current position with timeout
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Get address from coordinates (mock implementation)
      String detectedLocation = await _getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _isLoading = false;
        _detectedLocation = detectedLocation;
        _permissionStatus = permission;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'लोकेशन प्राप्त नहीं हो सकी। कृपया मैन्युअल चयन करें।';
        _showManualSelection = true;
      });
    }
  }

  /// Mock method to get address from coordinates
  /// In production, this would use a geocoding API
  Future<String> _getAddressFromCoordinates(double lat, double lon) async {
    await Future.delayed(const Duration(seconds: 1));
    // Mock location based on coordinates
    return 'Jaipur, Rajasthan, India';
  }

  /// Handle location confirmation
  void _confirmLocation() {
    // Save location preference and navigate to dashboard
    Navigator.pushReplacementNamed(context, '/main-dashboard-screen');
  }

  /// Handle skip for now
  void _skipForNow() {
    // Show disclaimer and navigate to dashboard with default location
    _showSkipDialog();
  }

  /// Show skip confirmation dialog
  void _showSkipDialog() {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(!isHindi ? 'Skip Location Access?' : 'लोकेशन अनुमति छोड़ें?', style: theme.textTheme.titleLarge),
        content: Text(
          !isHindi
              ? 'Without location access, weather forecasts and mandi prices may not be accurate for your area. You can enable location later in settings.'
              : 'लोकेशन के बिना मौसम और मंडी भाव सटीक नहीं हो सकते। आप बाद में सेटिंग से अनुमति दे सकते हैं।',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              !isHindi ? 'Cancel' : 'रद्द करें',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/main-dashboard-screen');
            },
            child: Text(!isHindi ? 'Continue' : 'जारी रखें'),
          ),
        ],
      ),
    );
  }

  /// Handle manual location selection completion
  void _onManualLocationSelected(String state, String district, String tehsil) {
    // Save manual location and navigate to dashboard
    Navigator.pushReplacementNamed(context, '/main-dashboard-screen');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 2.h),

              // Location header with icon and explanation
              LocationHeaderWidget(),

              SizedBox(height: 4.h),

              // Show detected location if available
              if (_detectedLocation != null) ...[
                _buildDetectedLocationCard(theme, isHindi),
                SizedBox(height: 3.h),
              ],

              // Show error message if any
              if (_errorMessage != null) ...[
                _buildErrorCard(theme),
                SizedBox(height: 3.h),
              ],

              // Show loading indicator
              if (_isLoading) ...[
                _buildLoadingIndicator(theme, isHindi),
                SizedBox(height: 3.h),
              ],

              // Primary location permission button
              if (_detectedLocation == null && !_isLoading)
                LocationPermissionButtonWidget(
                  onPressed: _requestLocationPermission,
                ),

              // Confirm and change buttons for detected location
              if (_detectedLocation != null) ...[
                ElevatedButton(
                  onPressed: _confirmLocation,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 6.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    !isHindi ? 'Confirm Location' : 'लोकेशन पुष्टि करें',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _detectedLocation = null;
                      _showManualSelection = true;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 6.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    !isHindi ? 'Change Location' : 'लोकेशन बदलें',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],

              SizedBox(height: 3.h),

              // Divider with "OR" text
              Row(
                children: [
                  Expanded(child: Divider(color: theme.dividerColor)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3.w),
                    child: Text(
                      !isHindi ? 'OR' : 'या',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: theme.dividerColor)),
                ],
              ),

              SizedBox(height: 3.h),

              // Manual location selection section
              ManualLocationSelectionWidget(
                onLocationSelected: _onManualLocationSelected,
                isExpanded: _showManualSelection,
                onToggleExpanded: () {
                  setState(() {
                    _showManualSelection = !_showManualSelection;
                  });
                },
              ),

              SizedBox(height: 3.h),

              // Skip for now button
              if (_detectedLocation == null)
                TextButton(
                  onPressed: _skipForNow,
                  style: TextButton.styleFrom(
                    minimumSize: Size(double.infinity, 6.h),
                  ),
                  child: Text(
                    !isHindi ? 'Skip for Now' : 'अभी छोड़ें',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontSize: 14.sp,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),

              SizedBox(height: 3.h),

              // Privacy notice
              PrivacyNoticeWidget(),

              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentItem: CustomBottomBarItem.dashboard,
        onItemTapped: (item) {
          switch (item) {
            case CustomBottomBarItem.dashboard:
              Navigator.pushReplacementNamed(context, '/main-dashboard_screen');
              break;

            case CustomBottomBarItem.marketplace:
              Navigator.pushReplacementNamed(context, '/marketplace-screen');
              break;

            case CustomBottomBarItem.community:
              Navigator.pushReplacementNamed(context, '/community-chat');
              break;

            case CustomBottomBarItem.chatbot:
              Navigator.pushReplacementNamed(context, '/ai-chatbot-screen');
              break;

            case CustomBottomBarItem.profile:
              Navigator.pushReplacementNamed(context, AppRoutes.profile);
              break;
          }
        },
      )
    );
  }

  /// Build detected location card
  Widget _buildDetectedLocationCard(ThemeData theme, bool isHindi) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: 'check_circle',
              color: theme.colorScheme.onPrimary,
              size: 20,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  !isHindi ? 'Location Detected' : 'लोकेशन मिली',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  _detectedLocation!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build error card
  Widget _buildErrorCard(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'error_outline',
            color: theme.colorScheme.error,
            size: 20,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              _errorMessage!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build loading indicator
  Widget _buildLoadingIndicator(ThemeData theme, bool isHindi) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor, width: 1),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              !isHindi ? 'Getting your location...' : 'लोकेशन प्राप्त की जा रही है...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
