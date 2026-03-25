import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../../core/language_provider.dart';

class WeatherAlertsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> alerts;
  final Function(int) onAlertTap;

  const WeatherAlertsWidget({
    super.key,
    required this.alerts,
    required this.onAlertTap,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().currentLanguage;

    // ✅ EMPTY STATE
    if (alerts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F7FE), // soft sky background
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          lang == 'en'
              ? 'No weather alerts currently'
              : 'कोई मौसम चेतावनी नहीं है',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    // ✅ ALERT LIST
    return Column(
      children: List.generate(
        alerts.length,
        (index) => _buildAlertCard(context, alerts[index], index),
      ),
    );
  }

  Widget _buildAlertCard(
    BuildContext context,
    Map<String, dynamic> alert,
    int index,
  ) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;

    final severity = alert["severity"] as String;
    final isExpanded = alert["isExpanded"] ?? false;

    Color color;
    String label;

    switch (severity) {
      case "high":
        color = theme.colorScheme.error;
        label = lang != 'en' ? 'गंभीर चेतावनी' : 'High Alert';
        break;
      case "medium":
        color = const Color(0xFFF57C00);
        label = lang != 'en' ? 'चेतावनी' : 'Warning';
        break;
      default:
        color = theme.colorScheme.primary;
        label = lang != 'en' ? 'सूचना' : 'Info';
    }

    return InkWell(
      onTap: () => onAlertTap(index),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // severity strip
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: color.withOpacity(0.8),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(14),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'warning',
                          color: color.withOpacity(0.85),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            alert["title"],
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            label,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      lang == 'en'
                          ? 'Valid till ${DateFormat('dd MMM, HH:mm').format(alert["validUntil"])}'
                          : 'मान्य ${DateFormat('dd MMM, HH:mm').format(alert["validUntil"])} तक',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (isExpanded) ...[
                      const SizedBox(height: 10),
                      Text(
                        lang == 'en'
                            ? alert["description"]
                            : (alert["descriptionHindi"] ?? alert["description"]),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}