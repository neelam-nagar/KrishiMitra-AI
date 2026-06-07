import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/language_provider.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Seven-day forecast widget with horizontal scrolling cards
class SevenDayForecastWidget extends StatelessWidget {
  final List<Map<String, dynamic>> forecastData;

  const SevenDayForecastWidget({super.key, required this.forecastData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;

    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: forecastData.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final forecast = forecastData[index];
          return _buildForecastCard(context, forecast, theme, lang);
        },
      ),
    );
  }

  /// Builds individual forecast card
  Widget _buildForecastCard(
    BuildContext context,
    Map<String, dynamic> forecast,
    ThemeData theme,
    String lang,
  ) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Day
            Text(
              lang == 'en'
                  ? DateFormat('EEE').format(DateTime.parse(forecast["date"]))
                  : _getHindiDay(DateFormat('EEEE').format(DateTime.parse(forecast["date"]))),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // Date
            Text(
              DateFormat('dd MMM').format(DateTime.parse(forecast["date"])),
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),

            // Weather icon
            (() {
              final condition = forecast["condition"] ?? "sunny";
              final iconName = condition == "Rainy"
                  ? "water_drop"
                  : condition == "Cloudy"
                      ? "cloud"
                      : "wb_sunny";
              return CustomIconWidget(
                iconName: iconName,
                color: _getWeatherIconColor(iconName),
                size: 40,
              );
            })(),

            // Temperature range
            Column(
              children: [
                Text(
                  '${forecast["highTemp"]?.toStringAsFixed(0)}°',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '${forecast["lowTemp"]?.toStringAsFixed(0)}°',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            // Rainfall probability
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'water_drop',
                  color: Colors.blue.shade400,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  '${forecast["rainfallProbability"] ?? 0} mm',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.blue.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getWeatherIconColor(String icon) {
    if (icon.contains('sun')) return const Color(0xFFFFC107); // yellow sun
    if (icon.contains('cloud')) return const Color(0xFFB0BEC5); // cloud grey
    if (icon.contains('rain') || icon.contains('water'))
      return const Color(0xFF4FC3F7); // rain blue
    if (icon.contains('night')) return Colors.white; // night
    return const Color(0xFFE8EAED);
  }

  String _getHindiDay(String day) {
    switch (day.toLowerCase()) {
      case 'today':
        return 'आज';
      case 'tomorrow':
        return 'कल';
      case 'monday':
        return 'सोमवार';
      case 'tuesday':
        return 'मंगलवार';
      case 'wednesday':
        return 'बुधवार';
      case 'thursday':
        return 'गुरुवार';
      case 'friday':
        return 'शुक्रवार';
      case 'saturday':
        return 'शनिवार';
      case 'sunday':
        return 'रविवार';
      default:
        return day;
    }
  }
}
