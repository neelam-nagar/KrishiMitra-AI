import 'package:flutter/material.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../core/app_export.dart';
import 'package:provider/provider.dart';
import '../../core/language_provider.dart';

class CompensationProcessScreen extends StatelessWidget {
  const CompensationProcessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: Text(
          isHindi ? 'आवेदन प्रक्रिया' : 'Application Process',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🔰 Header banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_tree,
                    color: Color(0xFF2E7D32), size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isHindi
                        ? 'फसल क्षति मुआवज़ा प्राप्त करने की\n'
                          'सरकारी चरणबद्ध प्रक्रिया'
                        : 'Official step-by-step process\n'
                          'to claim crop damage compensation',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _stepCard(
            step: '1',
            title: isHindi
                ? 'फसल क्षति की सूचना (7 दिन के भीतर)'
                : 'Report Damage (within 7 days)',
            subtitle: isHindi
                ? 'अपने नजदीकी ब्लॉक / तहसील कृषि कार्यालय में जाकर '
                  'फसल नुकसान की जानकारी दें।'
                : 'Visit your nearest Block / Tehsil Agriculture Office '
                  'and inform officials about crop loss.',
            icon: Icons.report_problem,
          ),

          _stepCard(
            step: '2',
            title: isHindi
                ? 'गिरदावरी / खेत सर्वे'
                : 'Girdawari / Field Survey',
            subtitle: isHindi
                ? 'कृषि अधिकारी आपके खेत का निरीक्षण करेंगे '
                  'और नुकसान का आकलन करेंगे।'
                : 'Agriculture officials will visit your field '
                  'and assess the extent of crop damage.',
            icon: Icons.grass,
          ),

          _stepCard(
            step: '3',
            title: isHindi
                ? 'दावा आवेदन जमा करें'
                : 'Submit Claim Application',
            subtitle: isHindi
                ? 'पीएमएफबीवाई पोर्टल, सीएससी, बैंक शाखा '
                  'या कृषि कार्यालय के माध्यम से आवेदन करें।'
                : 'Apply through PMFBY portal, CSC, bank branch '
                  'or agriculture office (if insured).',
            icon: Icons.assignment,
          ),

          _stepCard(
            step: '4',
            title: isHindi
                ? 'आवश्यक दस्तावेज़ जमा करें'
                : 'Submit Required Documents',
            subtitle: isHindi
                ? 'आधार कार्ड, बैंक पासबुक, भूमि रिकॉर्ड, '
                  'फसल क्षति की फोटो और सर्वे विवरण।'
                : 'Aadhaar card, bank passbook, land record, '
                  'crop damage photos and survey details.',
            icon: Icons.description,
          ),

          _stepCard(
            step: '5',
            title: isHindi
                ? 'मुआवज़ा प्राप्त करें (DBT)'
                : 'Receive Compensation (DBT)',
            subtitle: isHindi
                ? 'स्वीकृत मुआवज़ा राशि सीधे '
                  'आपके बैंक खाते में भेजी जाती है।'
                : 'Approved compensation amount is directly '
                  'credited to your bank account.',
            icon: Icons.account_balance_wallet,
          ),

          const SizedBox(height: 24),

          // ℹ️ Important Note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              isHindi
                  ? 'महत्वपूर्ण: सभी जमा किए गए दस्तावेज़ों की '
                    'प्रतियां सुरक्षित रखें और DBT मिलने तक '
                    'अधिकारियों से संपर्क में रहें।'
                  : 'Important: Always keep copies of all submitted documents '
                    'and follow up with officials until the DBT amount is credited.',
              style: theme.textTheme.bodySmall,
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

  Widget _stepCard({
    required String step,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFFE8F5E9),
          child: Text(
            step,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(icon, color: const Color(0xFF2E7D32)),
      ),
    );
  }
}