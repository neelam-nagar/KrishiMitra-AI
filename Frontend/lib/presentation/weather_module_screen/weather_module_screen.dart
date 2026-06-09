import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/language_provider.dart';
import '../../core/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../core/config/app_config.dart';
import './widgets/current_weather_card_widget.dart';
import './widgets/hourly_forecast_widget.dart';
import './widgets/seven_day_forecast_widget.dart';
import './widgets/weather_alerts_widget.dart';

class WeatherModuleScreen extends StatefulWidget {
  const WeatherModuleScreen({super.key});

  @override
  State<WeatherModuleScreen> createState() => _WeatherModuleScreenState();
}

class _WeatherModuleScreenState extends State<WeatherModuleScreen> {
  bool _isLoading = false;
  bool _hasError = false;
  DateTime _lastUpdated = DateTime.now();

  String? _selectedDistrict;
  String? _selectedTehsil;
  String? _selectedVillage;
  List<String> _districts = [];
  List<String> _tehsils = [];
  List<String> _villages = [];

  Map<String, dynamic> _currentWeather = {
    'temperature': 28,
    'condition': 'Partly Cloudy',
    'conditionIcon': 'partly_sunny',
    'humidity': 65,
    'rainfall': 0,
    'windSpeed': 12,
    'feelsLike': 30,
    'uvIndex': 6,
    'visibility': 10,
  };

  List<Map<String, dynamic>> _sevenDayForecast = [
    {
      'date': DateTime.now(),
      'day': 'Today',
      'weatherIcon': _isNightTime() ? 'nights_stay' : 'wb_sunny',
      'condition': 'Sunny',
      'highTemp': 32,
      'lowTemp': 22,
      'rainfallProbability': 10,
      'humidity': 60,
    },
    {
      'date': DateTime.now().add(const Duration(days: 1)),
      'day': 'Tomorrow',
      'weatherIcon': 'cloud',
      'condition': 'Cloudy',
      'highTemp': 30,
      'lowTemp': 21,
      'rainfallProbability': 30,
      'humidity': 70,
    },
    {
      'date': DateTime.now().add(const Duration(days: 2)),
      'day': DateFormat('EEEE').format(DateTime.now().add(const Duration(days: 2))),
      'weatherIcon': 'umbrella',
      'condition': 'Rainy',
      'highTemp': 27,
      'lowTemp': 20,
      'rainfallProbability': 80,
      'humidity': 85,
    },
    {
      'date': DateTime.now().add(const Duration(days: 3)),
      'day': DateFormat('EEEE').format(DateTime.now().add(const Duration(days: 3))),
      'weatherIcon': _isNightTime() ? 'nights_stay' : 'wb_sunny',
      'condition': 'Sunny',
      'highTemp': 31,
      'lowTemp': 22,
      'rainfallProbability': 5,
      'humidity': 55,
    },
    {
      'date': DateTime.now().add(const Duration(days: 4)),
      'day': DateFormat('EEEE').format(DateTime.now().add(const Duration(days: 4))),
      'weatherIcon': 'cloud',
      'condition': 'Partly Cloudy',
      'highTemp': 29,
      'lowTemp': 21,
      'rainfallProbability': 20,
      'humidity': 65,
    },
    {
      'date': DateTime.now().add(const Duration(days: 5)),
      'day': DateFormat('EEEE').format(DateTime.now().add(const Duration(days: 5))),
      'weatherIcon': 'cloud',
      'condition': 'Cloudy',
      'highTemp': 28,
      'lowTemp': 20,
      'rainfallProbability': 40,
      'humidity': 75,
    },
    {
      'date': DateTime.now().add(const Duration(days: 6)),
      'day': DateFormat('EEEE').format(DateTime.now().add(const Duration(days: 6))),
      'weatherIcon': _isNightTime() ? 'nights_stay' : 'wb_sunny',
      'condition': 'Sunny',
      'highTemp': 33,
      'lowTemp': 23,
      'rainfallProbability': 0,
      'humidity': 50,
    },
  ];

  final List<Map<String, dynamic>> _weatherAlerts = [
    {
      'severity': 'high',
      'title': 'Heat Wave Warning',
      'description':
          'High temperatures expected for the next 3 days. Ensure adequate irrigation for crops and avoid working during peak afternoon hours.',
      'validUntil': DateTime.now().add(const Duration(days: 3)),
      'isExpanded': false,
    },
    {
      'severity': 'medium',
      'title': 'Wind Advisory',
      'description':
          'Strong winds expected tomorrow evening. Secure loose farming equipment and protect young plants.',
      'validUntil': DateTime.now().add(const Duration(days: 1)),
      'isExpanded': false,
    },
  ];

  List<Map<String, dynamic>> _hourlyForecast = [];

  @override
  void initState() {
    super.initState();
    _loadDistricts();
    _autoDetectAndLoadWeather();
  }

  Future<void> _autoDetectAndLoadWeather() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever || perm == LocationPermission.denied) {
        _loadWeatherData();
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium, timeLimit: Duration(seconds: 10)),
      );
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty && mounted) {
        final place = placemarks.first;
        final district = place.subAdministrativeArea ?? place.administrativeArea ?? '';
        final tehsil = place.locality ?? district;
        final village = place.subLocality ?? tehsil;
        if (district.isNotEmpty) {
          context.read<LocationProvider>().updateLocation(
            district: district, tehsil: tehsil, village: village,
            latitude: position.latitude, longitude: position.longitude,
          );
        }
      }
      _loadWeatherData();
    } catch (_) {
      _loadWeatherData();
    }
  }

  Future<void> _loadDistricts() async {
    try {
      final res = await http.get(
        Uri.parse('${AppConfig.weatherApiBase}/api/weather/districts'),
      );
      if (!mounted) return;
      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        setState(() => _districts = List<String>.from(decoded is Map ? decoded['districts'] ?? [] : decoded));
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _hasError = true);
    }
  }

  Future<void> _loadTehsils(String district) async {
    try {
      final res = await http.get(Uri.parse(
        '${AppConfig.weatherApiBase}/api/weather/tehsils?district=${Uri.encodeComponent(district)}',
      ));
      if (!mounted) return;
      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        setState(() => _tehsils = List<String>.from(decoded is Map ? decoded['tehsils'] ?? [] : decoded));
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _hasError = true);
    }
  }

  Future<void> _loadVillages(String district, String tehsil) async {
    try {
      final res = await http.get(Uri.parse(
        '${AppConfig.weatherApiBase}/api/weather/villages?district=${Uri.encodeComponent(district)}&tehsil=${Uri.encodeComponent(tehsil)}',
      ));
      if (!mounted) return;
      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        setState(() => _villages = List<String>.from(decoded is Map ? decoded['villages'] ?? [] : decoded));
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _hasError = true);
    }
  }

  Future<void> _loadWeatherData() async {
    if (!mounted) return;

    final locationProvider = context.read<LocationProvider>();
    final district = locationProvider.district;
    final tehsil = locationProvider.tehsil;
    final village = locationProvider.village;

    // FIX: district/tehsil/village are non-nullable Strings — removed null checks
    if (district.isEmpty || tehsil.isEmpty || village.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final url =
          '${AppConfig.weatherApiBase}/api/weather'
          '?district=${Uri.encodeComponent(district)}'
          '&tehsil=${Uri.encodeComponent(tehsil)}'
          '&village=${Uri.encodeComponent(village)}';

      final response = await http.get(Uri.parse(url));
      if (!mounted) return;

      if (response.statusCode != 200) {
        throw Exception('API error: ${response.statusCode}');
      }

      final data = json.decode(response.body);

      if (data['current'] == null ||
          data['forecast'] == null ||
          data['hourly'] == null) {
        throw Exception('Invalid API response');
      }

      final currentWeather = {
        'temperature': data['current']['temperature'],
        'condition': 'Clear',
        'conditionIcon': 'wb_sunny',
        'humidity': data['current']['humidity'],
        'rainfall': data['current']['rain'],
        'windSpeed': data['current']['wind'],
        'feelsLike': data['current']['temperature'],
        'uvIndex': 0,
        'visibility': 10,
      };

      final sevenDayForecast = List<Map<String, dynamic>>.from(
        data['forecast'].map((day) => {
              'date': DateTime.parse(day['date']),
              'day': DateFormat('EEEE').format(DateTime.parse(day['date'])),
              'weatherIcon': _isNightTime() ? 'nights_stay' : 'wb_sunny',
              'condition': day['condition'],
              'highTemp': day['highTemp'],
              'lowTemp': day['lowTemp'],
              'rainfallProbability': day['rainfallProbability'],
              'humidity': day['humidity'],
            }),
      );

      final hourlyForecast = List<Map<String, dynamic>>.from(
        data['hourly'].map((h) {
          final rawTime = h['time'].toString().contains('T')
              ? h['time'].toString().split('T')[1]
              : h['time'].toString();
          final hour = int.parse(rawTime.split(':')[0]);
          final minute = rawTime.split(':')[1];
          final formattedTime = hour == 0
              ? '12:$minute AM'
              : hour < 12
                  ? '$hour:$minute AM'
                  : hour == 12
                      ? '12:$minute PM'
                      : '${hour - 12}:$minute PM';
          return {
            'time': formattedTime,
            'temperature': h['temperature'],
            'precipitation': h['rain'],
            'icon': h['rain'] > 0 ? 'water_drop' : _getWeatherIcon('sunny', isNight: () { final hr = int.tryParse(h['time']?.toString().split('T').last.split(':').first ?? '12') ?? 12; return hr >= 19 || hr < 6; }()),
          };
        }),
      );

      if (!mounted) return;

      setState(() {
        _currentWeather = currentWeather;
        _sevenDayForecast = sevenDayForecast;
        _hourlyForecast = hourlyForecast;
        _lastUpdated = DateTime.now();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRefresh() async => _loadWeatherData();

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
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select Location',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'District'),
                    initialValue: _selectedDistrict,
                    items: _districts
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
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

                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Tehsil'),
                    initialValue: _selectedTehsil,
                    items: _tehsils
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
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

                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Village'),
                    initialValue: _selectedVillage,
                    items: _villages
                        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                        .toList(),
                    onChanged: _selectedTehsil == null
                        ? null
                        : (value) =>
                            setModalState(() => _selectedVillage = value),
                  ),
                  const SizedBox(height: 24),

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

  void _handleShare() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Weather information shared successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }


  /// Returns the correct weather icon based on condition and current time.
  /// Shows moon/night icons between 7 PM and 6 AM.
  static String _getWeatherIcon(String condition, {bool isNight = false}) {
    if (isNight) {
      if (condition.toLowerCase().contains('rain') ||
          condition.toLowerCase().contains('baarish') ||
          condition.toLowerCase().contains('बारिश')) {
        return 'nights_stay'; // rainy night
      }
      if (condition.toLowerCase().contains('cloud') ||
          condition.toLowerCase().contains('badal') ||
          condition.toLowerCase().contains('बादल')) {
        return 'nights_stay'; // cloudy night
      }
      return 'nights_stay'; // clear night
    }
    // Daytime icons
    if (condition.toLowerCase().contains('rain') ||
        condition.toLowerCase().contains('baarish') ||
        condition.toLowerCase().contains('बारिश')) {
      return 'water_drop';
    }
    if (condition.toLowerCase().contains('cloud') ||
        condition.toLowerCase().contains('badal') ||
        condition.toLowerCase().contains('बादल')) {
      return 'cloud';
    }
    if (condition.toLowerCase().contains('storm') ||
        condition.toLowerCase().contains('tufan') ||
        condition.toLowerCase().contains('तूफान')) {
      return 'thunderstorm';
    }
    return 'wb_sunny'; // default sunny
  }

  static bool _isNightTime() {
    final hour = DateTime.now().hour;
    return hour >= 19 || hour < 6; // 7 PM to 6 AM = night
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
                size: 24),
            onPressed: _handleShare,
          ),
          IconButton(
            icon: CustomIconWidget(
                iconName: 'location_on',
                color: theme.colorScheme.onPrimary,
                size: 24),
            onPressed: _handleLocationChange,
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

  Widget _buildLoadingState(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
            height: 200,
            decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16))),
        const SizedBox(height: 16),
        Container(
            height: 150,
            decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16))),
        const SizedBox(height: 16),
        Container(
            height: 120,
            decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16))),
      ],
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    final lang = context.watch<LanguageProvider>().currentLanguage;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
                iconName: 'cloud_off', color: theme.colorScheme.error, size: 64),
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
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadWeatherData,
              icon: CustomIconWidget(
                  iconName: 'refresh',
                  color: theme.colorScheme.onPrimary,
                  size: 20),
              label: Text(lang == 'en' ? 'Retry' : 'पुनः प्रयास करें'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherContent(ThemeData theme) {
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final locationProvider = context.watch<LocationProvider>();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CustomIconWidget(
                    iconName: 'location_on',
                    color: theme.colorScheme.primary,
                    size: 20),
                const SizedBox(width: 4),
                Text(
                  locationProvider.fullLocation,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            Text(
              lang == 'en'
                  ? 'Updated ${DateFormat('HH:mm').format(_lastUpdated)}'
                  : 'अपडेट ${DateFormat('HH:mm').format(_lastUpdated)}',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CurrentWeatherCardWidget(weatherData: _currentWeather),
        const SizedBox(height: 24),
        if (_weatherAlerts.isNotEmpty) ...[
          Text(
            lang == 'en' ? 'Weather Alerts' : 'मौसम चेतावनी',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          WeatherAlertsWidget(
            alerts: _weatherAlerts,
            onAlertTap: (index) {
              setState(() {
                _weatherAlerts[index]['isExpanded'] =
                    !(_weatherAlerts[index]['isExpanded'] as bool);
              });
            },
          ),
          const SizedBox(height: 24),
        ],
        Text(
          lang == 'en' ? 'Hourly Forecast' : 'घंटेवार पूर्वानुमान',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        HourlyForecastWidget(hourlyData: _hourlyForecast),
        const SizedBox(height: 24),
        Text(
          lang == 'en' ? '7-Day Forecast' : '7-दिवसीय पूर्वानुमान',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        SevenDayForecastWidget(forecastData: _sevenDayForecast),
        const SizedBox(height: 16),
      ],
    );
  }
}