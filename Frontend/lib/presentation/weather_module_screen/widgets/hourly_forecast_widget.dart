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
    // ignore: unused_local_variable — lang kept for future localisation of time labels
    final lang = context.watch<LanguageProvider>().currentLanguage;

    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: hourlyData.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return _buildHourlyItem(hourlyData[index], theme);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHourlyItem(Map<String, dynamic> hour, ThemeData theme) {
    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        // FIX: withOpacity → withValues
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            hour['time']?.toString() ?? '',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          () {
            final rain = hour['rain'] ?? hour['precipitation'] ?? 0;
            final iconName = (rain as num) > 0 ? 'water_drop' : 'wb_sunny';
            return CustomIconWidget(
              iconName: iconName,
              color: _getWeatherIconColor(iconName),
              size: 28,
            );
          }(),
          Text(
            '${hour['temperature']?.toStringAsFixed(0)}°',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                  iconName: 'water_drop',
                  color: const Color(0xFF4FC3F7),
                  size: 12),
              const SizedBox(width: 2),
              Text(
                '${hour['rain'] ?? hour['precipitation'] ?? 0} mm',
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
  if (icon.contains('sun')) return const Color(0xFFFFC107);
  if (icon.contains('cloud')) return const Color(0xFFB0BEC5);
  if (icon.contains('rain') || icon.contains('water')) return const Color(0xFF4FC3F7);
  if (icon.contains('night')) return Colors.white;
  return const Color(0xFFE8EAED);
}