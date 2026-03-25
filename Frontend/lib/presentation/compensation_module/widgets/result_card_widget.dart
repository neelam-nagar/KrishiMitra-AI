import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/language_provider.dart';

class ResultCardWidget extends StatelessWidget {
  final String crop;
  final String cause;
  final double damagePercent;
  final double pmfbyAmount;
  final double sdrfAmount;
  final double totalAmount;

  const ResultCardWidget({
    super.key,
    required this.crop,
    required this.cause,
    required this.damagePercent,
    required this.pmfbyAmount,
    required this.sdrfAmount,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isHindi ? 'मुआवज़ा परिणाम' : 'Compensation Result',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),

            Text(isHindi ? 'फसल: $crop' : 'Crop: $crop'),
            Text(isHindi ? 'कारण: $cause' : 'Cause: $cause'),

            const Divider(height: 24),

            _row(
              isHindi ? 'नुकसान प्रतिशत' : 'Damage Percentage',
              '${damagePercent.toStringAsFixed(1)} %',
            ),
            _row(
              isHindi ? 'पीएमएफबीवाई मुआवज़ा' : 'PMFBY Compensation',
              '₹ ${pmfbyAmount.toStringAsFixed(2)}',
            ),
            _row(
              isHindi ? 'एसडीआरएफ / राज्य राहत' : 'SDRF / State Relief',
              '₹ ${sdrfAmount.toStringAsFixed(2)}',
            ),

            const Divider(height: 24),

            _row(
              isHindi ? 'कुल अनुमानित मुआवज़ा' : 'Total Estimated Compensation',
              '₹ ${totalAmount.toStringAsFixed(2)}',
              bold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
