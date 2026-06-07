import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../core/app_export.dart';
import '../../core/language_provider.dart';

class LandRecordHomeScreen extends StatelessWidget {
  const LandRecordHomeScreen({super.key});

  Future<void> _openBhulekhPortal() async {
    const url = 'https://apnakhata.rajasthan.gov.in';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        title: Text(
          !isHindi ? 'Land Records' : 'भूमि रिकॉर्ड',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🔰 Header Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance, color: Color(0xFF1B5E20), size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    !isHindi
                      ? 'View Your Land Records (Bhulekh)\nApna Khata – Rajasthan Government'
                      : 'अपने भूमि रिकॉर्ड देखें (भूलेख)\nअपना खाता – राजस्थान सरकार',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _optionCard(
            icon: Icons.search,
            title: !isHindi ? 'View Land Record' : 'भूमि रिकॉर्ड देखें',
            subtitle: !isHindi
              ? 'Check Khasra, Khatauni & ownership details'
              : 'खसरा, खातौनी और स्वामित्व विवरण देखें',
            onTap: _openBhulekhPortal,
          ),

          _optionCard(
            icon: Icons.description,
            title: !isHindi ? 'Required Documents' : 'आवश्यक दस्तावेज़',
            subtitle: !isHindi
              ? 'Aadhaar, Khasra Number, District details'
              : 'आधार, खसरा नंबर, जिला विवरण',
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(isHindi ? 'आवश्यक दस्तावेज़' : 'Required Documents'),
                  content: Text(
                    isHindi
                      ? '• खसरा / खाता संख्या\n'
                        '• जिला, तहसील और गाँव का नाम\n'
                        '• खातेदार का नाम\n'
                        '• जनआधार / आधार (कुछ सेवाओं के लिए)\n\n'
                        'नोट: भूमि रिकॉर्ड देखने के लिए लॉगिन आवश्यक नहीं होता।'
                      : '• Khasra / Khata Number\n'
                        '• District, Tehsil & Village\n'
                        '• Account holder name\n'
                        '• Jan Aadhaar / Aadhaar (for some services)\n\n'
                        'Note: Login is not required to view land records.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(isHindi ? 'ठीक है' : 'OK'),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(0xFF90CAF9)),
            ),
            child: Text(
              !isHindi
                ? 'Farmer Guidance:\n'
                  '• Land records are maintained by the Revenue Department\n'
                  '• Any correction requires Patwari / Tehsil office visit\n'
                  '• Online portal is for viewing records only\n'
                  '• Updates reflect after official verification'
                : 'किसान मार्गदर्शन:\n'
                  '• भूमि रिकॉर्ड राजस्व विभाग द्वारा संचालित होते हैं\n'
                  '• किसी भी सुधार के लिए पटवारी / तहसील कार्यालय जाएँ\n'
                  '• पोर्टल केवल रिकॉर्ड देखने हेतु है\n'
                  '• सुधार सरकारी सत्यापन के बाद ही दिखते हैं',
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 16),

          // ℹ️ Disclaimer
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              !isHindi
                ? 'Disclaimer: This service redirects to the official Rajasthan Bhulekh (Apna Khata) portal. Data accuracy depends on government records.'
                : 'अस्वीकरण: यह सेवा राजस्थान सरकार के आधिकारिक भूलेख (अपना खाता) पोर्टल पर रीडायरेक्ट करती है। डेटा की सटीकता सरकारी रिकॉर्ड पर निर्भर करती है।',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
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

  Widget _optionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Icon(icon, color: const Color(0xFF1B5E20)),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}