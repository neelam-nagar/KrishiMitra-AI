import '../main_shell/main_shell_screen.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/guide_topic_card_widget.dart';
import './widgets/guide_category_widget.dart';
import 'package:provider/provider.dart';
import '../../core/language_provider.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

/// Organic Farming Guide Screen - Comprehensive organic farming information
/// Provides guidance on organic farming practices and techniques
class OrganicFarmingGuideScreen extends StatefulWidget {
  const OrganicFarmingGuideScreen({super.key});

  @override
  State<OrganicFarmingGuideScreen> createState() =>
      _OrganicFarmingGuideScreenState();
}

class _OrganicFarmingGuideScreenState extends State<OrganicFarmingGuideScreen> {

  // Selected category
  String _selectedCategory = 'All';

  List<Map<String, dynamic>> _guides = [];
  bool _loading = true;

  // Categories
  final List<String> _categories = [
    'All',
    'Basics',
    'Soil Health',
    'Pest Control',
    'Techniques',
    'Certification',
  ];

  /// Filter guides based on category
  List<Map<String, dynamic>> get _filteredGuides {
    if (_selectedCategory == 'All') return _guides;
    return _guides
        .where((guide) => guide['category'] == _selectedCategory)
        .toList();
  }

 Future<void> _loadGuides() async {
  final lang = context.read<LanguageProvider>().currentLanguage;

  final path = lang == 'en'
      ? 'assets/organic_guide/language/organic_awareness_en.json'
      : 'assets/organic_guide/language/organic_awareness_hi.json';

  final jsonString = await rootBundle.loadString(path);
  final List data = json.decode(jsonString);

  setState(() {
    _guides = data.map<Map<String, dynamic>>((item) {
      return {
        'title': item['title'],
        'titleHindi': item['title'],
        'description': item['description'],
        'descriptionHindi': item['description'],
        'category': item['category'] ?? 'Basics',
        'duration': '5 min read',
        'difficulty': 'Beginner',
        'imageUrl': 'https://picsum.photos/600/400',
      };
    }).toList();

    _loading = false;
  });
}
  @override
  void initState() {
    super.initState();
    _loadGuides();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage; // 'hi' or 'en'

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
                provider.changeLanguage(provider.currentLanguage == 'en' ? 'hi' : 'en');
              },
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                  SizedBox(height: 1.h),
                  Text(
                    lang == 'en'
                        ? 'Comprehensive guides for organic farming practices'
                        : 'जैविक खेती प्रथाओं के लिए व्यापक गाइड',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(179),
                    ),
                  ),
                ],
              ),
            ),

            // Category filter
            GuideCategoryWidget(
              categories: _categories,
              selectedCategory: _selectedCategory,
              onCategoryChanged: (category) {
                setState(() => _selectedCategory = category);
              },
            ),

            // Guides list
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(4.w),
                      itemCount: _filteredGuides.length,
                      itemBuilder: (context, index) {
                        return GuideTopicCardWidget(
                          guideData: _filteredGuides[index],
                          onTap: () => _showGuideDetails(_filteredGuides[index]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show guide details
  void _showGuideDetails(Map<String, dynamic> guideData) {
    final theme = Theme.of(context);
    final lang = context.read<LanguageProvider>().currentLanguage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Guide image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16.0),
                    ),
                    child: Image.network(
                      guideData['imageUrl'],
                      height: 30.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 30.h,
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Center(
                            child: CustomIconWidget(
                              iconName: 'eco',
                              size: 64,
                              color: theme.colorScheme.primary.withAlpha(77),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          lang == 'en'
                              ? guideData['title']
                              : guideData['titleHindi'],
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 1.h),

                        // Metadata
                        Wrap(
                          spacing: 2.w,
                          children: [
                            Chip(
                              label: Text(guideData['category']),
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                            ),
                            Chip(
                              label: Text(guideData['difficulty']),
                              backgroundColor:
                                  theme.colorScheme.secondaryContainer,
                            ),
                            Chip(
                              avatar: CustomIconWidget(
                                iconName: 'schedule',
                                size: 18,
                              ),
                              label: Text(guideData['duration']),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),

                        // Description
                        Text(
                          lang == 'en'
                              ? guideData['description']
                              : guideData['descriptionHindi'],
                          style: theme.textTheme.bodyLarge,
                        ),
                        SizedBox(height: 2.h),

                        // Placeholder content
                        Text(
                          lang == 'en'
                              ? 'Full Guide Content'
                              : 'पूर्ण गाइड सामग्री',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          lang == 'en'
                              ? 'This comprehensive guide will cover all aspects of this topic. Full content coming soon...'
                              : 'यह व्यापक गाइड इस विषय के सभी पहलुओं को कवर करेगी। पूरी सामग्री जल्द आ रही है...',
                          style: theme.textTheme.bodyLarge,
                        ),
                        SizedBox(height: 3.h),

                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        lang == 'en'
                                            ? 'Guide bookmarked'
                                            : 'गाइड बुकमार्क की गई',
                                      ),
                                    ),
                                  );
                                },
                                icon: CustomIconWidget(
                                  iconName: 'bookmark_border',
                                  size: 20,
                                ),
                                label: Text(
                                  lang == 'en'
                                      ? 'Bookmark'
                                      : 'बुकमार्क',
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 1.5.h,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        lang == 'en'
                                            ? 'Guide shared'
                                            : 'गाइड साझा की गई',
                                      ),
                                    ),
                                  );
                                },
                                icon: CustomIconWidget(
                                  iconName: 'share',
                                  size: 20,
                                  color: theme.colorScheme.onPrimary,
                                ),
                                label: Text(
                                  lang == 'en'
                                      ? 'Share'
                                      : 'साझा करें',
                                  style: TextStyle(
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 1.5.h,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
