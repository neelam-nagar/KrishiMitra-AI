import '../main_shell/main_shell_screen.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import 'package:provider/provider.dart';
import '../../core/language_provider.dart';
import './region_menu_screen.dart';

class OrganicFarmingGuideScreen extends StatefulWidget {
  const OrganicFarmingGuideScreen({super.key});

  @override
  State<OrganicFarmingGuideScreen> createState() =>
      _OrganicFarmingGuideScreenState();
}

class _OrganicFarmingGuideScreenState extends State<OrganicFarmingGuideScreen> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;

    return MainShellScreen(
      currentItem: CustomBottomBarItem.dashboard,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: lang == 'en'
              ? 'Organic Farming Guide'
              : 'जैविक खेती गाइड',
          showBackButton: true,
          actions: [
            IconButton(
              icon: CustomIconWidget(
                iconName: 'translate',
                color: theme.colorScheme.onSurface,
              ),
              onPressed: () {
                final provider = context.read<LanguageProvider>();
                provider.changeLanguage(
                  provider.currentLanguage == 'en' ? 'hi' : 'en',
                );
              },
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.secondaryContainer,
                  ],
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'eco',
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      lang == 'en'
                          ? 'Learn Sustainable Farming'
                          : 'टिकाऊ खेती सीखें',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Title
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Text(
                lang == 'en' ? "Choose Region" : "क्षेत्र चुनें",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Region List
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                children: [
                  _buildRegionTile(context, "hadoti_region", lang),
                  _buildRegionTile(context, "eastern_rajasthan", lang),
                  _buildRegionTile(context, "western_rajasthan", lang),
                  _buildRegionTile(context, "shekhawati_region", lang),
                  _buildRegionTile(context, "southern_rajasthan", lang),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 Region Tile
  Widget _buildRegionTile(BuildContext context, String region, String lang) {
    final names = {
      "hadoti_region": {"en": "Hadoti", "hi": "हाड़ौती"},
      "eastern_rajasthan": {"en": "Eastern Rajasthan", "hi": "पूर्वी राजस्थान"},
      "western_rajasthan": {"en": "Western Rajasthan", "hi": "पश्चिमी राजस्थान"},
      "shekhawati_region": {"en": "Shekhawati", "hi": "शेखावाटी"},
      "southern_rajasthan": {"en": "Southern Rajasthan", "hi": "दक्षिणी राजस्थान"},
    };

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
          child: const Icon(Icons.agriculture, color: Colors.green),
        ),
        title: Text(
          names[region]?[lang] ?? region,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        // subtitle removed
        trailing: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RegionMenuScreen(regionKey: region),
            ),
          );
        },
      ),
    );
  }
}