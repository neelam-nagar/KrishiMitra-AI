import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';
import 'package:provider/provider.dart';
import '../../../core/language_provider.dart';

/// Weather preview card widget for dashboard
/// Shows current weather conditions with temperature and location
class WeatherPreviewCard extends StatelessWidget {
  final Map<String, dynamic> weatherData;
  final VoidCallback onTap;

  const WeatherPreviewCard({
    super.key,
    required this.weatherData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';
    final temperature = weatherData['temperature'] ?? 0;
    final condition = weatherData['condition'] ?? 'Clear';
    final location = weatherData['location'] ?? 'Unknown';
    final humidity = weatherData['humidity'] ?? 0;
    final windSpeed = weatherData['windSpeed'] ?? 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFB9DBF7), // light natural sky
              Color(0xFFEAF4FD), // soft sky fade
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHindi ? 'मौसम की जानकारी' : 'Current Weather',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF1F2937),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'location_on',
                            color: const Color(0xFF475569),
                            size: 16,
                          ),
                          SizedBox(width: 1.w),
                          Flexible(
                            child: Text(
                              location,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF475569).withAlpha(230),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                CustomIconWidget(
                  iconName: _getWeatherIcon(condition),
                  color: const Color(0xFFFACC15),
                  size: 48,
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$temperature°C',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: const Color(0xFF0F172A),
                        fontWeight: FontWeight.bold,
                        fontSize: 36,
                      ),
                    ),
                    Text(
                      isHindi ? _hindiCondition(condition) : condition,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF334155).withAlpha(230),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildWeatherDetail(
                      context,
                      'water_drop',
                      '$humidity%',
                      isHindi ? 'नमी' : 'Humidity',
                    ),
                    SizedBox(height: 1.h),
                    _buildWeatherDetail(
                      context,
                      'air',
                      '$windSpeed km/h',
                      isHindi ? 'हवा' : 'Wind',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(
    BuildContext context,
    String iconName,
    String value,
    String label,
  ) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: const Color(0xFF60A5FA),
          size: 16,
        ),
        SizedBox(width: 1.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF64748B),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
      case 'sunny':
        return 'wb_sunny';
      case 'cloudy':
      case 'partly cloudy':
        return 'cloud';
      case 'rainy':
      case 'rain':
        return 'water_drop';
      case 'thunderstorm':
        return 'thunderstorm';
      case 'foggy':
      case 'mist':
        return 'foggy';
      default:
        return 'wb_sunny';
    }
  }

  String _hindiCondition(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
      case 'sunny':
        return 'साफ मौसम';
      case 'cloudy':
      case 'partly cloudy':
        return 'आंशिक बादल';
      case 'rainy':
      case 'rain':
        return 'बारिश';
      case 'thunderstorm':
        return 'आंधी तूफान';
      case 'foggy':
      case 'mist':
        return 'कोहरा';
      default:
        return 'मौसम';
    }
  }
}
