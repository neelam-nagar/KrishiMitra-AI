import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/language_provider.dart';
import '../../presentation/main_shell/main_shell_screen.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/custom_bottom_bar.dart';

import './widgets/benefits_display_widget.dart';
import './widgets/collapsible_section_widget.dart';
import './widgets/document_requirements_widget.dart';
import './widgets/eligibility_checklist_widget.dart';
import './widgets/scheme_header_widget.dart';

import '../../data/schemes/schemes_data.dart';

class SchemeDetailScreen extends StatefulWidget {
  const SchemeDetailScreen({super.key});

  @override
  State<SchemeDetailScreen> createState() => _SchemeDetailScreenState();
}

class _SchemeDetailScreenState extends State<SchemeDetailScreen> {
  bool _isBookmarked = false;
  late Map<String, dynamic> _schemeData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final schemeKey = ModalRoute.of(context)!.settings.arguments as String;
    _schemeData = schemesData[schemeKey] ?? {};
  }

  void _toggleBookmark() {
    setState(() => _isBookmarked = !_isBookmarked);
    HapticFeedback.lightImpact();
  }

  void _shareScheme() {
    Share.share(
      '${_schemeData["title"]}\n${_schemeData["officialWebsite"] ?? ""}',
    );
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().currentLanguage;

    if (_schemeData.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("Scheme not found")),
      );
    }

    final bool hasOfficialLink =
        _schemeData['officialWebsite'] is String &&
        (_schemeData['officialWebsite'] as String).isNotEmpty;

    return MainShellScreen(
      currentItem: CustomBottomBarItem.dashboard,
      child: Scaffold(
        appBar: AppBar(
          title: Text(lang == 'en' ? 'Scheme Details' : 'योजना विवरण'),
          actions: [
            IconButton(
              icon: CustomIconWidget(
                iconName: _isBookmarked ? 'bookmark' : 'bookmark_border',
              ),
              onPressed: _toggleBookmark,
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareScheme,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SchemeHeaderWidget(schemeData: _schemeData),
              const SizedBox(height: 16),

              CollapsibleSectionWidget(
                title: lang == 'en' ? 'Overview' : 'योजना विवरण',
                icon: Icons.info_outline,
                initiallyExpanded: true,
                content: Text(_schemeData['overview'] ?? ''),
              ),

              CollapsibleSectionWidget(
                title: lang == 'en' ? 'Eligibility' : 'पात्रता',
                icon: Icons.check,
                content: EligibilityChecklistWidget(
                  criteria: List<String>.from(
                    _schemeData['eligibilityCriteria'] ?? [],
                  ),
                ),
              ),

              CollapsibleSectionWidget(
                title: lang == 'en' ? 'Documents' : 'दस्तावेज़',
                icon: Icons.description,
                content: DocumentRequirementsWidget(
                  documents: List<String>.from(
                    _schemeData['documents'] ?? [],
                  ),
                ),
              ),

              CollapsibleSectionWidget(
                title: lang == 'en' ? 'Benefits' : 'लाभ',
                icon: Icons.card_giftcard,
                content: BenefitsDisplayWidget(
                  benefits: List<String>.from(
                    _schemeData['benefits'] ?? [],
                  ),
                ),
              ),

              CollapsibleSectionWidget(
                title: lang == 'en' ? 'How to Apply' : 'आवेदन कैसे करें',
                icon: Icons.assignment,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List<String>.from(
                    _schemeData['howToApply'] ?? [],
                  ).map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '• $item',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ).toList(),
                ),
              ),

              CollapsibleSectionWidget(
                title: lang == 'en' ? 'Where to Apply' : 'कहाँ आवेदन करें',
                icon: Icons.location_on,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List<String>.from(
                    _schemeData['whereToApply'] ?? [],
                  ).map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '• $item',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ).toList(),
                ),
              ),

              const SizedBox(height: 12),

              if (hasOfficialLink)
                ElevatedButton.icon(
                  onPressed: () =>
                      _openLink(_schemeData['officialWebsite'] as String),
                  icon: const Icon(Icons.open_in_new),
                  label: Text(
                    lang == 'en' ? 'Apply Now' : 'अभी आवेदन करें',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
