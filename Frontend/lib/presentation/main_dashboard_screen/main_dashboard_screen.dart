import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/language_provider.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import '../../core/location_provider.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/dashboard_header_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/module_card_widget.dart';
import './widgets/weather_preview_card.dart';
import '../main_shell/main_shell_screen.dart';

import 'package:flutter/foundation.dart';
import '../weather_module_screen/widgets/location_selector_bottom_sheet.dart' as location_sheet;

/// Main Dashboard screen for KrishiMitra AI
/// Central hub providing farmers quick access to all agricultural modules
class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}
class _MainDashboardState extends State<MainDashboard>
    with SingleTickerProviderStateMixin {
      String get lang => context.watch<LanguageProvider>().currentLanguage;
  late TabController _tabController;
  bool _isRefreshing = false;
  DateTime _lastUpdated = DateTime.now();
  int _unreadNotificationCount = 3;
  bool _locationCheckedOnce = false;
  Map<String, dynamic>? _weatherData;

  // Mock module data
  final List<Map<String, dynamic>> _moduleData = [
    {
      'iconName': 'wb_sunny',
      'title': 'Weather',
      'subtitle': '',
      'route': '/weather-detail-screen',
    },
    {
      'iconName': 'trending_up',
      'title': 'Crop Prices',
      'subtitle': 'Latest Mandi Rates',
      'route': '/crop-price-screen',
    },
    {
  'iconName': 'account_balance',
  'title': 'Govt Schemes' ,
  'subtitle': 'View all schemes',
  'route': AppRoutes.schemesList,
},
    {
      'iconName': 'eco',
      'title': 'Organic Farming',
      'subtitle': 'Regional Guide',
      'route': '/organic-farming-screen',
    },
    {
      'iconName': 'shopping_bag',
      'title': 'Marketplace',
      'subtitle': 'Buy & Sell Crops',
      'route': '/marketplace-screen',
    },
    {
      'iconName': 'chat_bubble',
      'title': 'AI Assistant',
      'subtitle': 'KrishiMitra AI',
      'route': '/ai-chatbot-screen',
    },
    {
  'iconName': 'payments',
  'title': 'Compensation',
  'subtitle': 'Crop loss & relief',
  'route': AppRoutes.compensationHome,
},
{
  'iconName': 'assignment',
  'title': 'Land Record',
  'subtitle': 'Bhulekh / Apna Khata',
  'route': AppRoutes.landRecord,
},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locationProvider = context.read<LocationProvider>();

      // listen for location change
      locationProvider.addListener(_onLocationChanged);

      // If no location is selected, ask user how to proceed
      if (!locationProvider.hasLocation) {
        _showLocationDialog(); // 👈 show popup: Auto or Manual
      } else {
        _loadDashboardWeather();
      }
    });
  }
  Future<void> _checkLocationPermission() async {
    await _detectLocation();
  }

  Future<void> _detectLocation() async {
    // Dashboard must not block or error. Try auto-detect; if not possible, open manual.
    try {
      // If web or any failure → manual selector
      if (kIsWeb) {
        _handleLocationTap();
        return;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _handleLocationTap();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _handleLocationTap();
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _handleLocationTap();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final district =
            (place.locality ?? place.subAdministrativeArea ?? '').trim();
        if (district.isNotEmpty) {
          context.read<LocationProvider>().updateLocation(
                district: district,
                tehsil: '',
                village: '',
                latitude: position.latitude,
                longitude: position.longitude,
              );
          await _loadDashboardWeather();
          return;
        }
      }

      _handleLocationTap();
    } catch (_) {
      _handleLocationTap();
    }
  }
  @override
  void dispose() {
    context.read<LocationProvider>().removeListener(_onLocationChanged);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    HapticFeedback.mediumImpact();

    // Simulate data refresh
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
      _lastUpdated = DateTime.now();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            lang == 'en'
                ? 'Dashboard updated at ${_formatTime(_lastUpdated)}'
                : 'डैशबोर्ड अपडेट हुआ: ${_formatTime(_lastUpdated)}',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }



  void _handleLocationTap() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return location_sheet.LocationSelectorBottomSheet();
      },
    ).then((_) {
      _loadDashboardWeather();
    });
  }

  Future<void> _loadDashboardWeather() async {
    final location = context.read<LocationProvider>();

    // Prefer precise coordinates if available
    String url;
    if (location.latitude != null && location.longitude != null) {
      url =
          "http://127.0.0.1:5001/weather"
          "?lat=${location.latitude}"
          "&lon=${location.longitude}";
    } else if (location.district != null &&
        location.tehsil != null &&
        location.village != null) {
      url =
          "http://127.0.0.1:5001/weather"
          "?district=${location.district}"
          "&tehsil=${location.tehsil}"
          "&village=${location.village}";
    } else {
      // Not enough data yet
      return;
    }

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (!mounted) return;

      setState(() {
        _weatherData = {
          'temperature': data["current"]["temperature"],
          'condition': data["current"]["condition"] ?? 'Clear',
          'humidity': data["current"]["humidity"],
          'windSpeed': data["current"]["wind"],
        };
        _lastUpdated = DateTime.now();
      });
    } catch (e) {
      debugPrint("Dashboard weather error: $e");
    }
  }

  void _handleModuleTap(String route) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, route);
  }

  void _handleModuleLongPress(String title) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quick Actions'),
        content: Text('Add $title to favorites?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$title added to favorites')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, AppRoutes.notifications).then((_) {
      setState(() {
        _unreadNotificationCount = 0;
      });
    });
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // Helper: Returns display location string based on current language
  String _getDisplayLocation(String enLocation) {
    if (lang == 'en') return enLocation;

    const locationMap = {
      'Ajmer, Rajasthan': 'अजमेर, राजस्थान',
      'Alwar, Rajasthan': 'अलवर, राजस्थान',
      'Anupgarh, Rajasthan': 'अनूपगढ़, राजस्थान',
      'Balotra, Rajasthan': 'बालोतरा, राजस्थान',
      'Banswara, Rajasthan': 'बांसवाड़ा, राजस्थान',
      'Baran, Rajasthan': 'बारां, राजस्थान',
      'Barmer, Rajasthan': 'बाड़मेर, राजस्थान',
      'Beawar, Rajasthan': 'ब्यावर, राजस्थान',
      'Bharatpur, Rajasthan': 'भरतपुर, राजस्थान',
      'Bhilwara, Rajasthan': 'भीलवाड़ा, राजस्थान',
      'Bikaner, Rajasthan': 'बीकानेर, राजस्थान',
      'Bundi, Rajasthan': 'बूंदी, राजस्थान',
      'Chittorgarh, Rajasthan': 'चित्तौड़गढ़, राजस्थान',
      'Churu, Rajasthan': 'चूरू, राजस्थान',
      'Dausa, Rajasthan': 'दौसा, राजस्थान',
      'Deeg, Rajasthan': 'डीग, राजस्थान',
      'Dholpur, Rajasthan': 'धौलपुर, राजस्थान',
      'Didwana-Kuchaman, Rajasthan': 'डीडवाना-कुचामन, राजस्थान',
      'Dungarpur, Rajasthan': 'डूंगरपुर, राजस्थान',
      'Gangapur City, Rajasthan': 'गंगापुर सिटी, राजस्थान',
      'Hanumangarh, Rajasthan': 'हनुमानगढ़, राजस्थान',
      'Jaipur, Rajasthan': 'जयपुर, राजस्थान',
      'Jaipur Rural, Rajasthan': 'जयपुर ग्रामीण, राजस्थान',
      'Jaisalmer, Rajasthan': 'जैसलमेर, राजस्थान',
      'Jalore, Rajasthan': 'जालोर, राजस्थान',
      'Jhalawar, Rajasthan': 'झालावाड़, राजस्थान',
      'Jhunjhunu, Rajasthan': 'झुंझुनूं, राजस्थान',
      'Jodhpur, Rajasthan': 'जोधपुर, राजस्थान',
      'Jodhpur Rural, Rajasthan': 'जोधपुर ग्रामीण, राजस्थान',
      'Karauli, Rajasthan': 'करौली, राजस्थान',
      'Kekri, Rajasthan': 'केकड़ी, राजस्थान',
      'Khairthal-Tijara, Rajasthan': 'खैरथल-तिजारा, राजस्थान',
      'Kota, Rajasthan': 'कोटा, राजस्थान',
      'Kotputli-Behror, Rajasthan': 'कोटपूतली-बहरोड़, राजस्थान',
      'Nagaur, Rajasthan': 'नागौर, राजस्थान',
      'Neem Ka Thana, Rajasthan': 'नीम का थाना, राजस्थान',
      'Pali, Rajasthan': 'पाली, राजस्थान',
      'Pratapgarh, Rajasthan': 'प्रतापगढ़, राजस्थान',
      'Rajsamand, Rajasthan': 'राजसमंद, राजस्थान',
      'Salumbar, Rajasthan': 'सलूम्बर, राजस्थान',
      'Sanchore, Rajasthan': 'सांचौर, राजस्थान',
      'Sawai Madhopur, Rajasthan': 'सवाई माधोपुर, राजस्थान',
      'Shahpura, Rajasthan': 'शाहपुरा, राजस्थान',
      'Sikar, Rajasthan': 'सीकर, राजस्थान',
      'Sirohi, Rajasthan': 'सिरोही, राजस्थान',
      'Sri Ganganagar, Rajasthan': 'श्रीगंगानगर, राजस्थान',
      'Tonk, Rajasthan': 'टोंक, राजस्थान',
      'Udaipur, Rajasthan': 'उदयपुर, राजस्थान',
    };

    return locationMap[enLocation] ?? enLocation;
  }
void _showLocationDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text(lang == 'en' ? 'Location Access' : 'लोकेशन अनुमति'),
      content: Text(
        lang == 'en'
            ? 'Allow location to get accurate weather & mandi prices.\n\nYou can also skip and select manually.'
            : 'सही मौसम और मंडी भाव के लिए लोकेशन की अनुमति दें।\n\nआप मैन्युअली भी चुन सकते हैं।',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            _handleLocationTap(); // manual location selector
          },
          child: Text(lang == 'en' ? 'Select Manually' : 'मैन्युअली चुनें'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            await _detectLocation(); // 👈 trigger permission + GPS
          },
          child: Text(lang == 'en' ? 'Allow' : 'अनुमति दें'),
        ),
      ],
    ),
  );
}
  Widget _buildDashboardContent() {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final locationProvider = context.watch<LocationProvider>();
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                Container(
                  color: const Color(0xFF4E7D3A), // same as bottom bar green
                  child: DashboardHeaderWidget(
                    currentLocation: _getDisplayLocation(locationProvider.fullLocation),
                    onLocationTap: _handleLocationTap,
                    unreadNotificationCount: _unreadNotificationCount,
                    onNotificationTap: _handleNotificationTap,
                  ),
                ),
                SizedBox(height: 2.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: WeatherPreviewCard(
                    weatherData: _weatherData == null
                        ? {
                            'temperature': '--',
                            'condition': lang == 'en' ? 'Fetching...' : 'लोड हो रहा है...',
                            'humidity': '--',
                            'windSpeed': '--',
                            'location': _getDisplayLocation(locationProvider.fullLocation),
                          }
                        : {
                            ..._weatherData!,
                            'location': _getDisplayLocation(locationProvider.fullLocation),
                          },
                    onTap: () => _handleModuleTap('/weather-detail-screen'),
                  ),
                ),
                SizedBox(height: 3.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        lang == 'en' ? 'Quick Access' : 'त्वरित एक्सेस',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white, // 👈 IMPORTANT
                          shadows: const [
                            Shadow(
                              blurRadius: 4,
                              color: Colors.black45,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        lang == 'en'
                            ? 'Last updated: ${_formatTime(_lastUpdated)}'
                            : 'अंतिम अपडेट: ${_formatTime(_lastUpdated)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          shadows: const [
                            Shadow(
                              blurRadius: 3,
                              color: Colors.black45,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
              ],
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 3.w,
                mainAxisSpacing: 1.6.h,
                childAspectRatio: 1.05,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final module = _moduleData[index];
                return ModuleCardWidget(
                  iconName: module['iconName'] as String,
                  title: module['title'] as String,
                  subtitle: module['title'] == 'Weather' && _weatherData != null
                      ? '${_weatherData!['temperature']}°C, ${_weatherData!['condition']}'
                      : module['subtitle'] as String,
                  onTap: () => _handleModuleTap(module['route'] as String),
                  onLongPress: () =>
                      _handleModuleLongPress(module['title'] as String),
                );
              }, childCount: _moduleData.length),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 10.h)),
        ],
      ),
    );
  }
 @override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final locationProvider = context.watch<LocationProvider>();

  return MainShellScreen(
    currentItem: CustomBottomBarItem.dashboard,
    child: Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // ✅ Clean full background image (no opacity)
          Positioned.fill(
            child: Image.asset(
              'assets/images/farm_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // ✅ Soft gradient overlay for readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.25),
                    Colors.transparent,
                    Colors.black.withOpacity(0.25),
                  ],
                ),
              ),
            ),
          ),
          // ✅ Main content (clean cards on top)
          SafeArea(
            child: _isRefreshing
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          lang == 'en'
                              ? 'Updating dashboard...'
                              : 'डैशबोर्ड अपडेट हो रहा है...',
                        ),
                      ],
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildDashboardContent(),
                      EmptyStateWidget(
                        iconName: 'shopping_bag',
                        title: lang == 'en' ? 'Marketplace' : 'बाजार',
                        message: lang == 'en'
                            ? 'Browse and list agricultural products'
                            : 'कृषि उत्पाद देखें और बेचें',
                        actionText:
                            lang == 'en' ? 'Explore Marketplace' : 'बाजार देखें',
                        onActionTap: () =>
                            _handleModuleTap('/marketplace-screen'),
                      ),
                      EmptyStateWidget(
                        iconName: 'chat_bubble',
                        title: lang == 'en' ? 'AI Assistant' : 'कृषि सहायक',
                        message: lang == 'en'
                            ? 'Get instant farming guidance from KrishiMitra AI'
                            : 'कृषि मित्र AI से तुरंत सलाह पाएं',
                        actionText:
                            lang == 'en' ? 'Start Chat' : 'चैट शुरू करें',
                        onActionTap: () =>
                            _handleModuleTap('/ai-chatbot-screen'),
                      ),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? SizedBox(
              height: 48,
              width: 48,
              child: FloatingActionButton(
                onPressed: () => _handleModuleTap('/ai-chatbot-screen'),
                backgroundColor: const Color(0xFF5A8F45),
                elevation: 4,
                shape: const CircleBorder(),
                child: const Icon(
                  Icons.support_agent_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            )
          : null,
    ),
  );
}
  void _onLocationChanged() {
    if (!mounted) return;
    _loadDashboardWeather();
  }
}