import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/language_provider.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Hourly forecast widget showing next 24 hours weather timeline
class HourlyForecastWidget extends StatelessWidget {
  final List<Map<String, dynamic>> hourlyData;

  const HourlyForecastWidget({super.key, required this.hourlyData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;

    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Temperature graph
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: hourlyData.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final hour = hourlyData[index];
                  return _buildHourlyItem(context, hour, theme, lang);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds individual hourly forecast item
  Widget _buildHourlyItem(
    BuildContext context,
    Map<String, dynamic> hour,
    ThemeData theme,
    String lang,
  ) {

  return Container(
  width: 72,
  padding: const EdgeInsets.symmetric(vertical: 12),
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.85),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Colors.grey.shade300,
    ),
  ),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
          // Time
          Text(
            lang == 'en'
              ? hour["time"] as String
              : _getHindiTime(hour["time"] as String),
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),

          // Weather icon
          CustomIconWidget(
            iconName: hour["icon"] as String,
            color: _getWeatherIconColor(hour["icon"] as String),
            size: 28,
          ),

          // Temperature
          Text(
            '${hour["temperature"]}°',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),

          // Precipitation
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'water_drop',
                color: const Color(0xFF4FC3F7),
                size: 12,
              ),
              const SizedBox(width: 2),
              Text(
                '${hour["precipitation"]}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.blue.shade400,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color _getWeatherIconColor(String icon) {
  if (icon.contains('sun')) return const Color(0xFFFFC107); // yellow
  if (icon.contains('cloud')) return const Color(0xFFB0BEC5); // cloud grey
  if (icon.contains('rain') || icon.contains('water'))
    return const Color(0xFF4FC3F7); // rain blue
  if (icon.contains('night')) return Colors.white;
  return const Color(0xFFE8EAED);
}

String _getHindiTime(String time) {
  switch (time.toLowerCase()) {
    case 'now':
      return 'अभी';
    case '1 pm':
      return '1 बजे';
    case '2 pm':
      return '2 बजे';
    case '3 pm':
      return '3 बजे';
    case '4 pm':
      return '4 बजे';
    case '5 pm':
      return '5 बजे';
    case '6 pm':
      return '6 बजे';
    case '7 pm':
      return '7 बजे';
    case '8 pm':
      return '8 बजे';
    case '9 pm':
      return '9 बजे';
    case '10 pm':
      return '10 बजे';
    case '11 pm':
      return '11 बजे';
    default:
      return time;
  }
}
