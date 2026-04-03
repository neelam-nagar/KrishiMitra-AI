import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/language_provider.dart';
import '../../core/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/current_weather_card_widget.dart';
import './widgets/hourly_forecast_widget.dart';
import './widgets/seven_day_forecast_widget.dart';
import './widgets/weather_alerts_widget.dart';
import 'widgets/location_selector_bottom_sheet.dart';
/// Weather Module Screen - Provides comprehensive agricultural weather information
/// with location-based forecasts optimized for farming decisions
class WeatherModuleScreen extends StatefulWidget {
  const WeatherModuleScreen({super.key});

  @override
  State<WeatherModuleScreen> createState() => _WeatherModuleScreenState();
}

class _WeatherModuleScreenState extends State<WeatherModuleScreen> {
  bool _isLoading = false;
  bool _hasError = false;
  DateTime _lastUpdated = DateTime.now();

  // Hierarchical location selection state
  String? _selectedDistrict;
  String? _selectedTehsil;
  String? _selectedVillage;
  List<String> _districts = [];
  List<String> _tehsils = [];
  List<String> _villages = [];

  // Current weather data (populated from API)
  Map<String, dynamic> _currentWeather = {
    "temperature": 28,
    "condition": "Partly Cloudy",
    "conditionIcon": "partly_sunny",
    "humidity": 65,
    "rainfall": 0,
    "windSpeed": 12,
    "feelsLike": 30,
    "uvIndex": 6,
    "visibility": 10,
  };

  // 7-day forecast data (populated from API)
  List<Map<String, dynamic>> _sevenDayForecast = [
    {
      "date": DateTime.now(),
      "day": "Today",
      "weatherIcon": "wb_sunny",
      "condition": "Sunny",
      "highTemp": 32,
      "lowTemp": 22,
      "rainfallProbability": 10,
      "humidity": 60,
    },
    {
      "date": DateTime.now().add(const Duration(days: 1)),
      "day": "Tomorrow",
      "weatherIcon": "cloud",
      "condition": "Cloudy",
      "highTemp": 30,
      "lowTemp": 21,
      "rainfallProbability": 30,
      "humidity": 70,
    },
    {
      "date": DateTime.now().add(const Duration(days: 2)),
      "day": DateFormat(
        'EEEE',
      ).format(DateTime.now().add(const Duration(days: 2))),
      "weatherIcon": "umbrella",
      "condition": "Rainy",
      "highTemp": 27,
      "lowTemp": 20,
      "rainfallProbability": 80,
      "humidity": 85,
    },
    {
      "date": DateTime.now().add(const Duration(days: 3)),
      "day": DateFormat(
        'EEEE',
      ).format(DateTime.now().add(const Duration(days: 3))),
      "weatherIcon": "wb_sunny",
      "condition": "Sunny",
      "highTemp": 31,
      "lowTemp": 22,
      "rainfallProbability": 5,
      "humidity": 55,
    },
    {
      "date": DateTime.now().add(const Duration(days: 4)),
      "day": DateFormat(
        'EEEE',
      ).format(DateTime.now().add(const Duration(days: 4))),
      "weatherIcon": "cloud",
      "condition": "Partly Cloudy",
      "highTemp": 29,
      "lowTemp": 21,
      "rainfallProbability": 20,
      "humidity": 65,
    },
    {
      "date": DateTime.now().add(const Duration(days: 5)),
      "day": DateFormat(
        'EEEE',
      ).format(DateTime.now().add(const Duration(days: 5))),
      "weatherIcon": "cloud",
      "condition": "Cloudy",
      "highTemp": 28,
      "lowTemp": 20,
      "rainfallProbability": 40,
      "humidity": 75,
    },
    {
      "date": DateTime.now().add(const Duration(days: 6)),
      "day": DateFormat(
        'EEEE',
      ).format(DateTime.now().add(const Duration(days: 6))),
      "weatherIcon": "wb_sunny",
      "condition": "Sunny",
      "highTemp": 33,
      "lowTemp": 23,
      "rainfallProbability": 0,
      "humidity": 50,
    },
  ];

  // Mock weather alerts data
  final List<Map<String, dynamic>> _weatherAlerts = [
    {
      "severity": "high",
      "title": "Heat Wave Warning",
      "description":
          "High temperatures expected for the next 3 days. Ensure adequate irrigation for crops and avoid working during peak afternoon hours.",
      "validUntil": DateTime.now().add(const Duration(days: 3)),
      "isExpanded": false,
    },
    {
      "severity": "medium",
      "title": "Wind Advisory",
      "description":
          "Strong winds expected tomorrow evening. Secure loose farming equipment and protect young plants.",
      "validUntil": DateTime.now().add(const Duration(days: 1)),
      "isExpanded": false,
    },
  ];

  // Hourly forecast data (populated from API)
  List<Map<String, dynamic>> _hourlyForecast = [];

  @override
  void initState() {
    super.initState();
    _loadDistricts();
    _loadWeatherData();
  }

  Future<void> _loadDistricts() async {
    final res = await http.get(Uri.parse("https://krishimitra-ai-3-65a1.onrender.com/locations/districts"));
    _districts = List<String>.from(json.decode(res.body));
  }

  Future<void> _loadTehsils(String district) async {
    final res = await http.get(
      Uri.parse("https://krishimitra-ai-3-65a1.onrender.com/locations/tehsils?district=$district"),
    );
    _tehsils = List<String>.from(json.decode(res.body));
  }

  Future<void> _loadVillages(String district, String tehsil) async {
    final res = await http.get(
      Uri.parse("https://krishimitra-ai-3-65a1.onrender.com/locations/villages?district=$district&tehsil=$tehsil"),
    );
    _villages = List<String>.from(json.decode(res.body));
  }

  /// Loads weather data from Python Flask API
  Future<void> _loadWeatherData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final locationProvider = context.read<LocationProvider>();
      final district = locationProvider.district;
      final tehsil = locationProvider.tehsil;
      final village = locationProvider.village;
final url =
    "https://krishimitra-ai-3-65a1.onrender.com/weather"
    "?district=$district&tehsil=$tehsil&village=$village";

      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      _currentWeather = {
        "temperature": data["current"]["temperature"],
        "condition": "Clear",
        "conditionIcon": "wb_sunny",
        "humidity": data["current"]["humidity"],
        "rainfall": data["current"]["rain"],
        "windSpeed": data["current"]["wind"],
        "feelsLike": data["current"]["temperature"],
        "uvIndex": 0,
        "visibility": 10,
      };

      _sevenDayForecast = List<Map<String, dynamic>>.from(
        data["forecast"].map((day) {
          return {
            "date": DateTime.parse(day["date"]),
            "day": DateFormat('EEEE').format(DateTime.parse(day["date"])),
            "weatherIcon": "wb_sunny",
            "condition": day["condition"],
            "highTemp": day["highTemp"],
            "lowTemp": day["lowTemp"],
            "rainfallProbability": day["rainfallProbability"],
            "humidity": day["humidity"],
          };
        }),
      );

      _hourlyForecast = List<Map<String, dynamic>>.from(
        data["hourly"].map((h) {
          final rawTime = h["time"].toString().split("T")[1];
          final hour = int.parse(rawTime.split(":")[0]);
          final minute = rawTime.split(":")[1];

          final formattedTime = hour == 0
              ? "12:$minute AM"
              : hour < 12
                  ? "$hour:$minute AM"
                  : hour == 12
                      ? "12:$minute PM"
                      : "${hour - 12}:$minute PM";
          return {
            "time": formattedTime,
            "temperature": h["temperature"],
            "precipitation": h["rain"],
            "icon": h["rain"] > 0 ? "cloud" : "wb_sunny",
          };
        }),
      );

      setState(() {
        _lastUpdated = DateTime.now();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  /// Handles pull-to-refresh
  Future<void> _handleRefresh() async {
    await _loadWeatherData();
  }

  /// Handles location change (hierarchical selector)
  void _handleLocationChange() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            List<String> districts = _districts;
            List<String> tehsils = _tehsils;
            List<String> villages = _villages;

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select Location',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),

                  // District
                  DropdownButtonFormField<String>(
                    decoration:
                        const InputDecoration(labelText: 'District'),
                    value: _selectedDistrict,
                    items: districts
                        .map((d) =>
                            DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (value) async {
                      setModalState(() {
                        _selectedDistrict = value;
                        _selectedTehsil = null;
                        _selectedVillage = null;
                        _tehsils = [];
                        _villages = [];
                      });
                      await _loadTehsils(value!);
                      setModalState(() {});
                    },
                  ),
                  const SizedBox(height: 12),

                  // Tehsil
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Tehsil'),
                    value: _selectedTehsil,
                    items: tehsils
                        .map((t) =>
                            DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: _selectedDistrict == null
                        ? null
                        : (value) async {
                            setModalState(() {
                              _selectedTehsil = value;
                              _selectedVillage = null;
                              _villages = [];
                            });
                            await _loadVillages(_selectedDistrict!, value!);
                            setModalState(() {});
                          },
                  ),
                  const SizedBox(height: 12),

                  // Village
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Village'),
                    value: _selectedVillage,
                    items: villages
                        .map((v) =>
                            DropdownMenuItem(value: v, child: Text(v)))
                        .toList(),
                    onChanged: _selectedTehsil == null
                        ? null
                        : (value) {
                            setModalState(() {
                              _selectedVillage = value;
                            });
                          },
                  ),
                  const SizedBox(height: 24),

                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedVillage == null
                          ? null
                          : () {
                              context.read<LocationProvider>().updateLocation(
                                district: _selectedDistrict!,
                                tehsil: _selectedTehsil!,
                                village: _selectedVillage!,
                              );
                              Navigator.pop(context);
                              _loadWeatherData();
                            },
                      child: const Text('Apply Location'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Handles share functionality
  void _handleShare() {
    // In a real app, this would use share_plus package
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Weather information shared successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        variant: CustomAppBarVariant.standard,
        title: lang == 'en' ? 'Weather Forecast' : 'मौसम पूर्वानुमान',
        showBackButton: true,
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'share',
              color: theme.colorScheme.onPrimary,
              size: 24,
            ),
            onPressed: _handleShare,
            tooltip: lang == 'en' ? 'Share Weather' : 'मौसम साझा करें',
          ),
          IconButton(
            icon: CustomIconWidget(
              iconName: 'location_on',
              color: theme.colorScheme.onPrimary,
              size: 24,
            ),
            onPressed: _handleLocationChange,
            tooltip: lang == 'en' ? 'Change Location' : 'स्थान बदलें',
          ),
        ],
      ),
      body: SafeArea(
        child: _hasError
            ? _buildErrorState(theme)
            : RefreshIndicator(
                onRefresh: _handleRefresh,
                color: theme.colorScheme.primary,
                child: _isLoading
                    ? _buildLoadingState(theme)
                    : _buildWeatherContent(theme),
              ),
      ),
    );
  }

  /// Builds loading state with skeleton screens
  Widget _buildLoadingState(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ],
    );
  }

  /// Builds error state
  Widget _buildErrorState(ThemeData theme) {
    final lang = context.watch<LanguageProvider>().currentLanguage;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'cloud_off',
              color: theme.colorScheme.error,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              lang == 'en'
                  ? 'Unable to load weather data'
                  : 'मौसम डेटा लोड नहीं हो सका',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              lang == 'en'
                  ? 'Please check your internet connection and try again'
                  : 'कृपया अपना इंटरनेट कनेक्शन जांचें और पुनः प्रयास करें',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadWeatherData,
              icon: CustomIconWidget(
                iconName: 'refresh',
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
              label: Text(
                lang == 'en' ? 'Retry' : 'पुनः प्रयास करें',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds main weather content
  Widget _buildWeatherContent(ThemeData theme) {
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final locationProvider = context.watch<LocationProvider>();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Location and last updated info
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'location_on',
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  locationProvider.fullLocation,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Text(
              lang == 'en'
                  ? 'Updated ${DateFormat('HH:mm').format(_lastUpdated)}'
                  : 'अपडेट ${DateFormat('HH:mm').format(_lastUpdated)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Current weather card
        CurrentWeatherCardWidget(weatherData: _currentWeather),
        const SizedBox(height: 24),

        // Weather alerts section
        _weatherAlerts.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang == 'en' ? 'Weather Alerts' : 'मौसम चेतावनी',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  WeatherAlertsWidget(
                    alerts: _weatherAlerts,
                    onAlertTap: (index) {
                      setState(() {
                        _weatherAlerts[index]["isExpanded"] =
                            !(_weatherAlerts[index]["isExpanded"] as bool);
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              )
            : const SizedBox.shrink(),

        // Hourly forecast section
        Text(
          lang == 'en' ? 'Hourly Forecast' : 'घंटेवार पूर्वानुमान',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        HourlyForecastWidget(hourlyData: _hourlyForecast),
        const SizedBox(height: 24),

        // 7-day forecast section
        Text(
          lang == 'en' ? '7-Day Forecast' : '7-दिवसीय पूर्वानुमान',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SevenDayForecastWidget(forecastData: _sevenDayForecast),
        const SizedBox(height: 16),
      ],
    );
  }
}
