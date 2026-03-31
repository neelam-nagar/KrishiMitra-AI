import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';
import '../../../core/language_provider.dart';

/// Region selection widget
class RegionSelectionWidget extends StatelessWidget {
  final Function(String) onRegionSelected;

  const RegionSelectionWidget({
    super.key,
    required this.onRegionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;

    final regions = [
      {"key": "hadoti_region", "en": "Hadoti", "hi": "हाड़ौती"},
      {"key": "eastern_rajasthan", "en": "Eastern Rajasthan", "hi": "पूर्वी राजस्थान"},
      {"key": "western_rajasthan", "en": "Western Rajasthan", "hi": "पश्चिमी राजस्थान"},
      {"key": "shekhawati_region", "en": "Shekhawati", "hi": "शेखावाटी"},
      {"key": "southern_rajasthan", "en": "Southern Rajasthan", "hi": "दक्षिणी राजस्थान"},
    ];

    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: regions.length,
      itemBuilder: (context, index) {
        final region = regions[index];

        return Container(
          margin: EdgeInsets.only(bottom: 2.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Colors.green.shade100,
                Colors.green.shade50,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            leading: CircleAvatar(
              backgroundColor: Colors.green.shade200,
              child: Icon(Icons.agriculture, color: Colors.green.shade800),
            ),
            title: Text(
              lang == 'en'
                  ? (region['en'] ?? region['key'])
                  : (region['hi'] ?? region['key']),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade900,
              ),
            ),
            subtitle: Text(
              lang == 'en' ? 'View farming guide' : 'खेती गाइड देखें',
              style: theme.textTheme.bodySmall,
            ),
            trailing: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.green.shade700,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
            ),
            onTap: () => onRegionSelected(region['key']!),
          ),
        );
      },
    );
  }
}
