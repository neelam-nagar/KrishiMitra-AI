import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';
import 'package:provider/provider.dart';
import '../../../core/language_provider.dart';

/// Search and filter bar widget for marketplace
/// Provides search input with voice support and filter button
class SearchFilterBarWidget extends StatefulWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilterTapped;
  final VoidCallback? onVoiceSearchTapped;

  const SearchFilterBarWidget({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onFilterTapped,
    this.onVoiceSearchTapped,
  });

  @override
  State<SearchFilterBarWidget> createState() => _SearchFilterBarWidgetState();
}

class _SearchFilterBarWidgetState extends State<SearchFilterBarWidget> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 6.h,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.brightness == Brightness.light
                      ? const Color(0xFFE0E0E0)
                      : const Color(0xFF424242),
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: widget.onSearchChanged,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: isHindi ? 'फसल, उत्पाद खोजें...' : 'Search crops, products...',
                  hintStyle: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.brightness == Brightness.light
                        ? const Color(0xFFBDBDBD)
                        : const Color(0xFF6B6B6B),
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(2.w),
                    child: CustomIconWidget(
                      iconName: 'search',
                      color: theme.brightness == Brightness.light
                          ? const Color(0xFF757575)
                          : const Color(0xFFB0B0B0),
                      size: 24,
                    ),
                  ),
                  suffixIcon: widget.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: CustomIconWidget(
                            iconName: 'clear',
                            color: theme.brightness == Brightness.light
                                ? const Color(0xFF757575)
                                : const Color(0xFFB0B0B0),
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            widget.onSearchChanged('');
                          },
                        )
                      : (widget.onVoiceSearchTapped != null
                            ? IconButton(
                                icon: CustomIconWidget(
                                  iconName: 'mic',
                                  color: theme.colorScheme.primary,
                                  size: 24,
                                ),
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  widget.onVoiceSearchTapped!();
                                },
                              )
                            : null),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 1.5.h,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 2.w),
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onFilterTapped();
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 6.h,
              width: 12.w,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'filter_list',
                  color: theme.colorScheme.onPrimary,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
