import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';
import '../../../core/language_provider.dart';

/// Filter bottom sheet widget for marketplace
/// Provides filtering options for crop category, price range, location, and availability
class FilterBottomSheetWidget extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final ValueChanged<Map<String, dynamic>> onApplyFilters;

  const FilterBottomSheetWidget({
    super.key,
    required this.currentFilters,
    required this.onApplyFilters,
  });

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late Map<String, dynamic> _filters;
  late RangeValues _priceRange;
  late double _locationRadius;

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.currentFilters);
    _priceRange = RangeValues(
      (_filters['minPrice'] as num?)?.toDouble() ?? 0,
      (_filters['maxPrice'] as num?)?.toDouble() ?? 10000,
    );
    _locationRadius = (_filters['locationRadius'] as num?)?.toDouble() ?? 50;
  }

  void _clearAllFilters() {
    setState(() {
      _filters = {
        'category': null,
        'minPrice': 0,
        'maxPrice': 10000,
        'locationRadius': 50,
        'availabilityStatus': null,
      };
      _priceRange = const RangeValues(0, 10000);
      _locationRadius = 50;
    });
  }

  void _applyFilters() {
    _filters['minPrice'] = _priceRange.start;
    _filters['maxPrice'] = _priceRange.end;
    _filters['locationRadius'] = _locationRadius;
    widget.onApplyFilters(_filters);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isHindi ? 'उत्पाद फ़िल्टर करें' : 'Filter Products',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _clearAllFilters();
                    },
                    child: Text(
                      isHindi ? 'सभी हटाएं' : 'Clear All',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: theme.dividerColor),
            // Filter Options
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Crop Category
                    Text(
                      isHindi ? 'फसल श्रेणी' : 'Crop Category',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Wrap(
                      spacing: 2.w,
                      runSpacing: 1.h,
                      children:
                          [
                            isHindi ? 'सभी' : 'All',
                            isHindi ? 'अनाज' : 'Grains',
                            isHindi ? 'सब्ज़ियां' : 'Vegetables',
                            isHindi ? 'फल' : 'Fruits',
                            isHindi ? 'दालें' : 'Pulses',
                            isHindi ? 'मसाले' : 'Spices',
                          ].map((category) {
                            final isSelected =
                                _filters['category'] == category ||
                                (category == (isHindi ? 'सभी' : 'All') &&
                                    _filters['category'] == null);
                            return FilterChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (selected) {
                                HapticFeedback.lightImpact();
                                setState(() {
                                  _filters['category'] = category == (isHindi ? 'सभी' : 'All')
                                      ? null
                                      : category;
                                });
                              },
                              backgroundColor: theme.colorScheme.surface,
                              selectedColor: theme.colorScheme.primary
                                  .withValues(alpha: 0.2),
                              labelStyle: theme.textTheme.bodyMedium?.copyWith(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.brightness == Brightness.light
                                    ? const Color(0xFF757575)
                                    : const Color(0xFFB0B0B0),
                              ),
                            );
                          }).toList(),
                    ),
                    SizedBox(height: 2.h),
                    // Price Range
                    Text(
                      isHindi ? 'मूल्य सीमा (₹)' : 'Price Range (₹)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${_priceRange.start.toInt()}',
                          style: theme.textTheme.bodyMedium,
                        ),
                        Text(
                          '₹${_priceRange.end.toInt()}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    RangeSlider(
                      values: _priceRange,
                      min: 0,
                      max: 10000,
                      divisions: 100,
                      labels: RangeLabels(
                        '₹${_priceRange.start.toInt()}',
                        '₹${_priceRange.end.toInt()}',
                      ),
                      onChanged: (values) {
                        setState(() {
                          _priceRange = values;
                        });
                      },
                    ),
                    SizedBox(height: 2.h),
                    // Location Radius
                    Text(
                      isHindi ? 'स्थान सीमा' : 'Location Radius',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isHindi
                              ? '${_locationRadius.toInt()} किमी के भीतर'
                              : 'Within ${_locationRadius.toInt()} km',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    Slider(
                      value: _locationRadius,
                      min: 5,
                      max: 200,
                      divisions: 39,
                      label: isHindi
                          ? '${_locationRadius.toInt()} किमी'
                          : '${_locationRadius.toInt()} km',
                      onChanged: (value) {
                        setState(() {
                          _locationRadius = value;
                        });
                      },
                    ),
                    SizedBox(height: 2.h),
                    // Availability Status
                    Text(
                      isHindi ? 'उपलब्धता स्थिति' : 'Availability Status',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Wrap(
                      spacing: 2.w,
                      runSpacing: 1.h,
                      children: [
                        isHindi ? 'सभी' : 'All',
                        isHindi ? 'उपलब्ध' : 'Available',
                        isHindi ? 'सीमित स्टॉक' : 'Limited Stock',
                      ].map((
                        status,
                      ) {
                        final isSelected =
                            _filters['availabilityStatus'] == status ||
                            (status == (isHindi ? 'सभी' : 'All') &&
                                _filters['availabilityStatus'] == null);
                        return FilterChip(
                          label: Text(status),
                          selected: isSelected,
                          onSelected: (selected) {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _filters['availabilityStatus'] = status == (isHindi ? 'सभी' : 'All')
                                  ? null
                                  : status;
                            });
                          },
                          backgroundColor: theme.colorScheme.surface,
                          selectedColor: theme.colorScheme.primary.withValues(
                            alpha: 0.2,
                          ),
                          labelStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.brightness == Brightness.light
                                ? const Color(0xFF757575)
                                : const Color(0xFFB0B0B0),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            // Apply Button
            Padding(
              padding: EdgeInsets.all(4.w),
              child: SizedBox(
                width: double.infinity,
                height: 6.h,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _applyFilters();
                  },
                  child: Text(
                    isHindi ? 'फ़िल्टर लागू करें' : 'Apply Filters',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
