import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:provider/provider.dart';
import '../../../core/language_provider.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Collapsible card widget for scheme detail sections
class CollapsibleSectionWidget extends StatefulWidget {
  final String title;
  final IconData icon;
  final Widget content;
  final bool initiallyExpanded;

  const CollapsibleSectionWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.content,
    this.initiallyExpanded = false,
  });

  @override
  State<CollapsibleSectionWidget> createState() =>
      _CollapsibleSectionWidgetState();
}

class _CollapsibleSectionWidgetState extends State<CollapsibleSectionWidget> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(
                        alpha: 0.2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      widget.icon,
                      size: 24,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      lang == 'en'
                          ? widget.title
                          : widget.title, // keep same for now, Hindi title passed from parent
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  CustomIconWidget(
                    iconName: _isExpanded ? 'expand_less' : 'expand_more',
                    size: 24,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Container(
              padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 4.w),
              child: widget.content,
            ),
        ],
      ),
    );
  }
}
