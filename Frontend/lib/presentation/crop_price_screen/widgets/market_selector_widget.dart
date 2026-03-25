import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';

import '../../../core/language_provider.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Market selector widget for choosing market/mandi
class MarketSelectorWidget extends StatelessWidget {
  final String selectedMarket;
  final Function(String) onMarketChanged;

  const MarketSelectorWidget({
    super.key,
    required this.selectedMarket,
    required this.onMarketChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';

    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'location_on',
            color: theme.colorScheme.primary,
            size: 24,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  !isHindi ? 'Market' : 'मंडी',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withAlpha(179),
                  ),
                ),
                Text(
                  selectedMarket,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: CustomIconWidget(
              iconName: 'edit',
              color: theme.colorScheme.primary,
              size: 20,
            ),
            onPressed: () => _showMarketSelector(context),
          ),
        ],
      ),
    );
  }

  /// Show market selector dialog
  void _showMarketSelector(BuildContext context) {
    final theme = Theme.of(context);
    final markets = [
      'Jaipur Mandi',
      'Kota Mandi',
      'Udaipur Mandi',
      'Ajmer Mandi',
      'Jodhpur Mandi',
    ];
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                !isHindi ? 'Select Market' : 'मंडी चुनें',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              ...markets.map(
                (market) => ListTile(
                  leading: CustomIconWidget(
                    iconName: 'store',
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(market),
                  trailing: selectedMarket == market
                      ? CustomIconWidget(
                          iconName: 'check_circle',
                          color: theme.colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    onMarketChanged(market);
                    Navigator.pop(context);
                  },
                ),
              ),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }
}
