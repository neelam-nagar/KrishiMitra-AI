import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/language_provider.dart';
import '../../widgets/custom_bottom_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sizer/sizer.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import '../../../core/app_export.dart';
import './widgets/location_header_widget.dart';
import './widgets/location_permission_button_widget.dart';
import './widgets/manual_location_selection_widget.dart';
import './widgets/privacy_notice_widget.dart';

/// Location Permission Screen for KrishiMitra AI
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
  // FIX: removed unused _permissionStatus field

  @override
  void initState() {
    super.initState();
    _checkLocationServiceStatus();
    _requestLocationPermission();
  }

  Future<void> _checkLocationServiceStatus() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled && mounted) {
      setState(() {
        _errorMessage = 'लोकेशन सेवा बंद है। कृपया सेटिंग में चालू करें।';
      });
    }
  }

  Future<void> _requestLocationPermission() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'लोकेशन सेवा बंद है। कृपया सेटिंग में चालू करें।';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'लोकेशन अनुमति अस्वीकृत है। आप मैन्युअल चयन कर सकते हैं।';
            _showManualSelection = true;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'लोकेशन अनुमति स्थायी रूप से अस्वीकृत है। सेटिंग से अनुमति दें या मैन्युअल चयन करें।';
          _showManualSelection = true;
        });
        return;
      }

      // FIX: use LocationSettings instead of deprecated desiredAccuracy + timeLimit
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final locationData = await _getAddressFromCoordinates(
          position.latitude, position.longitude);

      final district = locationData['district'] ?? '';
      final tehsil = locationData['tehsil'] ?? '';
      final village = locationData['village'] ?? '';

      await _fetchWeather(district, tehsil, village);

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _detectedLocation = '$village, $tehsil, $district';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'लोकेशन प्राप्त नहीं हो सकी। कृपया मैन्युअल चयन करें।';
        _showManualSelection = true;
      });
    }
  }

  Future<Map<String, String>> _getAddressFromCoordinates(
      double lat, double lon) async {
    final placemarks = await placemarkFromCoordinates(lat, lon);
    final place = placemarks[0];
    return {
      'district': place.subAdministrativeArea ?? '',
      'tehsil': place.locality ?? '',
      'village': place.subLocality ?? '',
    };
  }

  Future<void> _fetchWeather(
      String district, String tehsil, String village) async {
    final url = Uri.parse(
      'https://krishimitra-ai-4-vaxn.onrender.com/weather'
      '?district=$district&tehsil=$tehsil&village=$village',
    );
    try {
      await http.get(url);
    } catch (_) {
      // Non-fatal: weather fetch failure should not block location confirmation
    }
  }

  void _confirmLocation() {
    Navigator.pushReplacementNamed(context, AppRoutes.mainDashboard);
  }

  void _skipForNow() => _showSkipDialog();

  void _showSkipDialog() {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          !isHindi ? 'Skip Location Access?' : 'लोकेशन अनुमति छोड़ें?',
          style: theme.textTheme.titleLarge,
        ),
        content: Text(
          !isHindi
              ? 'Without location access, weather forecasts and mandi prices may not be accurate for your area.'
              : 'लोकेशन के बिना मौसम और मंडी भाव सटीक नहीं हो सकते।',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(!isHindi ? 'Cancel' : 'रद्द करें'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, AppRoutes.mainDashboard);
            },
            child: Text(!isHindi ? 'Continue' : 'जारी रखें'),
          ),
        ],
      ),
    );
  }

  void _onManualLocationSelected(String state, String district, String tehsil) {
    Navigator.pushReplacementNamed(context, AppRoutes.mainDashboard);
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
              LocationHeaderWidget(),
              SizedBox(height: 4.h),

              if (_detectedLocation != null) ...[
                _buildDetectedLocationCard(theme, isHindi),
                SizedBox(height: 3.h),
              ],

              if (_errorMessage != null) ...[
                _buildErrorCard(theme),
                SizedBox(height: 3.h),
              ],

              if (_isLoading) ...[
                _buildLoadingIndicator(theme, isHindi),
                SizedBox(height: 3.h),
              ],

              if (_detectedLocation == null &&
                  !_isLoading &&
                  _errorMessage != null)
                LocationPermissionButtonWidget(
                  onPressed: _requestLocationPermission,
                ),

              if (_detectedLocation != null) ...[
                ElevatedButton(
                  onPressed: _confirmLocation,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 6.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    !isHindi ? 'Confirm Location' : 'लोकेशन पुष्टि करें',
                    style:
                        theme.textTheme.labelLarge?.copyWith(fontSize: 14.sp),
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
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    !isHindi ? 'Change Location' : 'लोकेशन बदलें',
                    style:
                        theme.textTheme.labelLarge?.copyWith(fontSize: 14.sp),
                  ),
                ),
              ],

              SizedBox(height: 3.h),
              Row(
                children: [
                  Expanded(child: Divider(color: theme.dividerColor)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3.w),
                    child: Text(!isHindi ? 'OR' : 'या',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                  ),
                  Expanded(child: Divider(color: theme.dividerColor)),
                ],
              ),
              SizedBox(height: 3.h),

              ManualLocationSelectionWidget(
                onLocationSelected: _onManualLocationSelected,
                isExpanded: _showManualSelection,
                onToggleExpanded: () => setState(
                    () => _showManualSelection = !_showManualSelection),
              ),

              SizedBox(height: 3.h),

              if (_detectedLocation == null)
                TextButton(
                  onPressed: _skipForNow,
                  style: TextButton.styleFrom(
                      minimumSize: Size(double.infinity, 6.h)),
                  child: Text(
                    !isHindi ? 'Skip for Now' : 'अभी छोड़ें',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontSize: 14.sp,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),

              SizedBox(height: 3.h),
              const PrivacyNoticeWidget(),
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
              Navigator.pushReplacementNamed(context, AppRoutes.mainDashboard);
            case CustomBottomBarItem.marketplace:
              Navigator.pushReplacementNamed(context, AppRoutes.marketplace);
            case CustomBottomBarItem.community:
              Navigator.pushReplacementNamed(context, AppRoutes.communityChat);
            case CustomBottomBarItem.chatbot:
              Navigator.pushReplacementNamed(context, AppRoutes.aiChatbot);
            case CustomBottomBarItem.profile:
              Navigator.pushReplacementNamed(context, AppRoutes.profile);
          }
        },
      ),
    );
  }

  Widget _buildDetectedLocationCard(ThemeData theme, bool isHindi) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
                color: theme.colorScheme.primary, shape: BoxShape.circle),
            child: CustomIconWidget(
                iconName: 'check_circle',
                color: theme.colorScheme.onPrimary,
                size: 20),
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
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 0.5.h),
                Text(_detectedLocation!,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSurface)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: theme.colorScheme.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CustomIconWidget(
              iconName: 'error_outline',
              color: theme.colorScheme.error,
              size: 20),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(_errorMessage!,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(ThemeData theme, bool isHindi) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              !isHindi
                  ? 'Getting your location...'
                  : 'लोकेशन प्राप्त की जा रही है...',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}