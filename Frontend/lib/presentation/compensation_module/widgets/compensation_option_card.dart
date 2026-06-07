import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/language_provider.dart';

class CompensationOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const CompensationOptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        margin: const EdgeInsets.only(bottom: 14),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // 🇮🇳 Left govt accent strip
            Container(
              width: 6,
              height: 86,
              decoration: const BoxDecoration(
                color: Color(0xFF1B5E20),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    // 🔰 Icon box
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: const Color(0xFF1B5E20),
                        size: 24,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // 📝 Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isHindi && title.contains('Calculator')
                                ? 'मुआवज़ा कैलकुलेटर'
                                : isHindi && title.contains('Eligibility')
                                    ? 'पात्रता जांच'
                                    : isHindi && title.contains('Application')
                                        ? 'आवेदन प्रक्रिया'
                                        : isHindi && title.contains('Download')
                                            ? 'रिपोर्ट डाउनलोड करें'
                                            : title,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isHindi && subtitle.contains('Estimate')
                                ? 'फसल नुकसान के आधार पर मुआवज़ा अनुमान'
                                : isHindi && subtitle.contains('Check eligibility')
                                    ? 'पीएमएफबीवाई / राज्य राहत के अनुसार पात्रता'
                                    : isHindi && subtitle.contains('step-by-step')
                                        ? 'सरकारी चरणबद्ध दावा प्रक्रिया'
                                        : isHindi && subtitle.contains('Save')
                                            ? 'अनुमानित मुआवज़ा रिपोर्ट सहेजें'
                                            : subtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // ➡️ Arrow only
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}