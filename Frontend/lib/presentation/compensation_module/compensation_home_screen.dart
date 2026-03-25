import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import 'widgets/compensation_option_card.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../core/app_export.dart';
import 'package:provider/provider.dart';
import '../../core/language_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CompensationHomeScreen extends StatelessWidget {
  const CompensationHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        elevation: 0,
        title: Text(
          isHindi ? 'किसान मुआवज़ा' : 'Kisan Compensation',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🇮🇳 Government Header Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE8F5E9), Color(0xFFD0EED6)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFB2DFDB)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.agriculture,
                  color: Color(0xFF1B5E20),
                  size: 40,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHindi ? 'फसल नुकसान मुआवज़ा सेवाएं' : 'Crop Loss Compensation Services',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isHindi ? 'पीएमएफबीवाई • एसडीआरएफ • राज्य आपदा राहत' : 'PMFBY • SDRF • State Disaster Relief',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 📂 Section title
          Text(
            isHindi ? 'उपलब्ध सेवाएं' : 'Available Services',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),

          // 📊 Calculator
          CompensationOptionCard(
            icon: Icons.calculate,
            title: isHindi ? 'मुआवज़ा कैलकुलेटर' : 'Compensation Calculator',
            subtitle: isHindi
              ? 'फसल, नुकसान और कारण के आधार पर मुआवज़ा अनुमान'
              : 'Estimate compensation based on crop, damage & cause',
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.compensationCalculator,
              );
            },
          ),

          // ✅ Eligibility
          CompensationOptionCard(
            icon: Icons.verified_user,
            title: isHindi ? 'पात्रता जांच' : 'Eligibility Check',
            subtitle: isHindi
              ? 'पीएमएफबीवाई / राज्य राहत नियमों के अनुसार पात्रता जांचें'
              : 'Check eligibility under PMFBY / State relief norms',
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.compensationEligibility,
              );
            },
          ),

          // 📋 Process
          CompensationOptionCard(
            icon: Icons.account_tree,
            title: isHindi ? 'आवेदन प्रक्रिया' : 'Application Process',
            subtitle: isHindi
              ? 'सरकारी चरणबद्ध दावा प्रक्रिया'
              : 'Official step-by-step claim procedure',
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.compensationProcess,
              );
            },
          ),

          // 📄 Report
          CompensationOptionCard(
            icon: Icons.picture_as_pdf,
            title: isHindi ? 'रिपोर्ट डाउनलोड करें' : 'Download Report',
            subtitle: isHindi
              ? 'अनुमानित मुआवज़ा रिपोर्ट सहेजें (PDF / TXT)'
              : 'Save estimated compensation report (PDF / TXT)',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isHindi
                      ? 'PDF / TXT डाउनलोड जल्द उपलब्ध होगा'
                      : 'PDF / TXT download will be available soon',
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 28),

          const SizedBox(height: 16),

          // ☎️ Helpline Strip
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.support_agent, color: Color(0xFF1B5E20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isHindi
                      ? 'आधिकारिक सहायता:\n'
                        '• ब्लॉक / तहसील कृषि कार्यालय\n'
                        '• राजस्थान कृषि हेल्पलाइन: 1800-180-1551\n'
                        '• पीएमएफबीवाई टोल-फ्री: 14447'
                      : 'Official Helpdesk:\n'
                        '• Block / Tehsil Agriculture Office\n'
                        '• Rajasthan Agriculture Helpline: 1800-180-1551\n'
                        '• PMFBY Toll-Free: 14447',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ℹ️ Official Disclaimer
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              isHindi
                ? 'अस्वीकरण: यहां दिखाए गए मुआवज़ा आंकड़े केवल अनुमानित हैं। '
                  'अंतिम मुआवज़ा राशि आधिकारिक खेत सर्वेक्षण, '
                  'जिला अधिसूचना और कृषि विभाग द्वारा स्वीकृत '
                  'बीमा रिकॉर्ड पर निर्भर करती है।'
                : 'Disclaimer: Compensation figures shown are indicative only. '
                  'Final compensation amount depends on official field survey, '
                  'district notification and insurance records approved by '
                  'the Agriculture Department.',
              style: theme.textTheme.bodySmall,
            ),
          ),

          const SizedBox(height: 24),

          // 🧭 Where to Apply (Direct & Clear)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHindi ? 'मुआवज़ा कहाँ आवेदन करें?' : 'Where to Apply for Compensation?',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),

                // PMFBY insured farmers
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    final uri = Uri.parse(
                      'https://pmfby.gov.in/farmerLogin',
                    );
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.shield, color: Colors.white),
                  label: Text(
                    isHindi
                      ? 'बीमित किसान (PMFBY दावा करें)'
                      : 'Insured Farmer (PMFBY Claim)',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),

                const SizedBox(height: 8),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFF90CAF9)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFF1565C0),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isHindi
                            ? 'गैर-बीमित किसान (राज्य आपदा राहत):\n'
                              '• ऑनलाइन व्यक्तिगत आवेदन नहीं होता\n'
                              '• पटवारी / गिरदावर द्वारा खेत सर्वे किया जाता है\n'
                              '• जिला प्रशासन मुआवज़ा सूची जारी करता है\n'
                              '• स्वीकृत राशि सीधे बैंक खाते में भेजी जाती है\n\n'
                              'किसान तुरंत पटवारी या तहसील कार्यालय को फसल नुकसान की सूचना दें।'
                            : 'Non‑Insured Farmers (State Disaster Relief):\n'
                              '• No individual online application\n'
                              '• Field survey is done by Patwari / Girdawar\n'
                              '• District administration prepares beneficiary list\n'
                              '• Approved amount is transferred directly to bank\n\n'
                              'Farmers must immediately inform the Patwari or Tehsil office.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  isHindi
                    ? 'नोट: यदि ऑनलाइन विकल्प उपलब्ध न हो, तो नजदीकी पटवारी / तहसील कार्यालय में तुरंत सूचना दें।'
                    : 'Note: If online option is not available, immediately inform the Patwari / Tehsil office.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      )
      ,
      bottomNavigationBar: CustomBottomBar(
        currentItem: CustomBottomBarItem.dashboard,
        onItemTapped: (item) {
          switch (item) {
            case CustomBottomBarItem.dashboard:
              Navigator.pushReplacementNamed(context, AppRoutes.mainDashboard);
              break;
            case CustomBottomBarItem.marketplace:
              Navigator.pushReplacementNamed(context, AppRoutes.marketplace);
              break;
            case CustomBottomBarItem.community:
              Navigator.pushReplacementNamed(context, AppRoutes.communityChat);
              break;
            case CustomBottomBarItem.chatbot:
              Navigator.pushReplacementNamed(context, AppRoutes.aiChatbot);
              break;
            case CustomBottomBarItem.profile:
              Navigator.pushReplacementNamed(context, AppRoutes.profile);
              break;
          }
        },
      )
    );
  }
}