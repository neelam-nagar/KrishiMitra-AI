import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/language_provider.dart';
import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Current weather card widget displaying comprehensive weather information
class CurrentWeatherCardWidget extends StatelessWidget {
  final Map<String, dynamic> weatherData;

  const CurrentWeatherCardWidget({super.key, required this.weatherData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB9DBF7), // light natural sky
              Color(0xFFEAF4FD), // very soft sky fade
            ],
          ),
        ),
        child: Column(
          children: [
            // Temperature and condition
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${weatherData["temperature"]}°C',
                        style: theme.textTheme.displayLarge?.copyWith(
                          color: const Color(0xFF1E293B),
                          fontWeight: FontWeight.w800,
                          fontSize: 60,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        weatherData["condition"] as String,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lang == 'en'
                          ? 'Feels like ${weatherData["feelsLike"]}°C'
                          : 'महसूस ${weatherData["feelsLike"]}°C',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
                CustomIconWidget(
                  iconName: weatherData["icon"] ?? 'wb_sunny',
                  color: _getMainWeatherIconColor(
                    weatherData["icon"] ?? 'sun',
                  ),
                  size: 80,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Weather details grid
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.75),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildWeatherDetail(
                          context,
                          icon: 'water_drop',
                          label: lang == 'en' ? 'Humidity' : 'नमी',
                          value: '${weatherData["humidity"]}%',
                        ),
                      ),
                      Expanded(
                        child: _buildWeatherDetail(
                          context,
                          icon: 'grain',
                          label: lang == 'en' ? 'Rainfall' : 'वर्षा',
                          value: '${weatherData["rainfall"]} mm',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildWeatherDetail(
                          context,
                          icon: 'air',
                          label: lang == 'en' ? 'Wind Speed' : 'हवा की गति',
                          value: '${weatherData["windSpeed"]} km/h',
                        ),
                      ),
                      Expanded(
                        child: _buildWeatherDetail(
                          context,
                          icon: 'wb_sunny',
                          label: lang == 'en' ? 'UV Index' : 'यूवी सूचकांक',
                          value: '${weatherData["uvIndex"]}',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds individual weather detail item
  Widget _buildWeatherDetail(
    BuildContext context, {
    required String icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        CustomIconWidget(
          iconName: icon,
          color: _getDetailIconColor(icon),
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: const Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: const Color(0xFF111827),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

Color _getMainWeatherIconColor(String icon) {
  if (icon.contains('sun')) return const Color(0xFFF9AB00); // Google sun yellow
  if (icon.contains('cloud')) return Colors.grey.shade300;
  if (icon.contains('rain')) return Colors.blue.shade400;
  if (icon.contains('night')) return Colors.white;
  return Colors.white;
}

Color _getDetailIconColor(String icon) {
  if (icon == 'water_drop') return Colors.blue.shade400;
  if (icon == 'grain') return Colors.blue.shade300;
  if (icon == 'air') return Colors.grey.shade700;
  if (icon == 'wb_sunny') return Colors.orange.shade400;
  return Colors.black54;
}
