import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';
import '../../../core/language_provider.dart';

/// Guide category widget for filtering guides
class GuideCategoryWidget extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategoryChanged;

  const GuideCategoryWidget({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage; // 'hi' or 'en'

    return Container(
      height: 6.h,
      margin: EdgeInsets.symmetric(vertical: 1.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;

          return Padding(
            padding: EdgeInsets.only(right: 2.w),
            child: FilterChip(
              label: Text(_getCategoryName(category, lang)),
              selected: isSelected,
              onSelected: (_) => onCategoryChanged(category),
              backgroundColor: theme.colorScheme.surface,
              selectedColor: theme.colorScheme.primary,
              labelStyle: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  /// Get localized category name
  String _getCategoryName(String category, String lang) {
    if (lang == 'en') return category;

    final translations = {
      'All': 'सभी',
      'Basics': 'बुनियादी',
      'Soil Health': 'मिट्टी स्वास्थ्य',
      'Pest Control': 'कीट नियंत्रण',
      'Techniques': 'तकनीक',
      'Certification': 'प्रमाणन',
    };

    return translations[category] ?? category;
  }
}
