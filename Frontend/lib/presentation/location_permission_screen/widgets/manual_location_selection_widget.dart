import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_export.dart';
import '../../../../core/language_provider.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Manual location selection widget
/// Provides state, district, and tehsil dropdowns for manual location entry
class ManualLocationSelectionWidget extends StatefulWidget {
  final Function(String state, String district, String tehsil)
  onLocationSelected;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;

  const ManualLocationSelectionWidget({
    super.key,
    required this.onLocationSelected,
    required this.isExpanded,
    required this.onToggleExpanded,
  });

  @override
  State<ManualLocationSelectionWidget> createState() =>
      _ManualLocationSelectionWidgetState();
}

class _ManualLocationSelectionWidgetState
    extends State<ManualLocationSelectionWidget> {
  String? _selectedState;
  String? _selectedDistrict;
  String? _selectedTehsil;

  // Mock data for Indian states
  final List<String> _states = [
    'Rajasthan',
    'Punjab',
    'Haryana',
    'Uttar Pradesh',
    'Madhya Pradesh',
    'Gujarat',
    'Maharashtra',
  ];

  // Mock data for districts (filtered by state)
  final Map<String, List<String>> _districts = {
    'Rajasthan': ['Jaipur', 'Jodhpur', 'Udaipur', 'Kota', 'Ajmer', 'Bikaner'],
    'Punjab': ['Ludhiana', 'Amritsar', 'Jalandhar', 'Patiala', 'Bathinda'],
    'Haryana': ['Gurugram', 'Faridabad', 'Panipat', 'Ambala', 'Karnal'],
    'Uttar Pradesh': ['Lucknow', 'Kanpur', 'Agra', 'Varanasi', 'Meerut'],
    'Madhya Pradesh': ['Bhopal', 'Indore', 'Gwalior', 'Jabalpur', 'Ujjain'],
    'Gujarat': ['Ahmedabad', 'Surat', 'Vadodara', 'Rajkot', 'Bhavnagar'],
    'Maharashtra': ['Mumbai', 'Pune', 'Nagpur', 'Nashik', 'Aurangabad'],
  };

  // Mock data for tehsils (filtered by district)
  final Map<String, List<String>> _tehsils = {
    'Jaipur': ['Jaipur City', 'Amber', 'Sanganer', 'Bassi', 'Chaksu'],
    'Jodhpur': ['Jodhpur City', 'Bilara', 'Osian', 'Phalodi', 'Shergarh'],
    'Udaipur': ['Udaipur City', 'Girwa', 'Mavli', 'Vallabhnagar', 'Salumbar'],
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Manual selection header
        InkWell(
          onTap: widget.onToggleExpanded,
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor, width: 1),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'edit_location',
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    !isHindi ? 'Select Location Manually' : 'मैन्युअल रूप से लोकेशन चुनें',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                CustomIconWidget(
                  iconName: widget.isExpanded ? 'expand_less' : 'expand_more',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        // Expandable manual selection form
        if (widget.isExpanded) ...[
          SizedBox(height: 2.h),

          // State dropdown
          _buildDropdown(
            theme: theme,
            label: !isHindi ? 'State' : 'राज्य',
            value: _selectedState,
            items: _states,
            onChanged: (value) {
              setState(() {
                _selectedState = value;
                _selectedDistrict = null;
                _selectedTehsil = null;
              });
            },
          ),

          SizedBox(height: 2.h),

          // District dropdown
          _buildDropdown(
            theme: theme,
            label: !isHindi ? 'District' : 'जिला',
            value: _selectedDistrict,
            items: _selectedState != null
                ? _districts[_selectedState!] ?? []
                : [],
            onChanged: (value) {
              setState(() {
                _selectedDistrict = value;
                _selectedTehsil = null;
              });
            },
            enabled: _selectedState != null,
          ),

          SizedBox(height: 2.h),

          // Tehsil dropdown
          _buildDropdown(
            theme: theme,
            label: !isHindi ? 'Tehsil' : 'तहसील',
            value: _selectedTehsil,
            items: _selectedDistrict != null
                ? _tehsils[_selectedDistrict!] ?? [!isHindi ? 'Not Available' : 'उपलब्ध नहीं']
                : [],
            onChanged: (value) {
              setState(() {
                _selectedTehsil = value;
              });
            },
            enabled: _selectedDistrict != null,
          ),

          SizedBox(height: 3.h),

          // Confirm button
          ElevatedButton(
            onPressed:
                _selectedState != null &&
                    _selectedDistrict != null &&
                    _selectedTehsil != null
                ? () {
                    widget.onLocationSelected(
                      _selectedState!,
                      _selectedDistrict!,
                      _selectedTehsil!,
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 6.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              !isHindi ? 'Confirm Manual Location' : 'लोकेशन पुष्टि करें',
              style: theme.textTheme.labelLarge?.copyWith(fontSize: 14.sp),
            ),
          ),
        ],
      ],
    );
  }

  /// Build dropdown widget
  Widget _buildDropdown({
    required ThemeData theme,
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool enabled = true,
  }) {
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          decoration: BoxDecoration(
            color: enabled
                ? theme.colorScheme.surface
                : theme.colorScheme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.dividerColor, width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(
                !enabled
                    ? ''
                    : (!isHindi ? 'Select $label' : '$label चुनें'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              isExpanded: true,
              icon: CustomIconWidget(
                iconName: 'arrow_drop_down',
                color: theme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                );
              }).toList(),
              onChanged: enabled ? onChanged : null,
            ),
          ),
        ),
      ],
    );
  }
}
