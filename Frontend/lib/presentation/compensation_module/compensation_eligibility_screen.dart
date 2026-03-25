import 'package:flutter/material.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../core/app_export.dart';
import 'package:provider/provider.dart';
import '../../core/language_provider.dart';
class CompensationEligibilityScreen extends StatefulWidget {
  const CompensationEligibilityScreen({super.key});

  @override
  State<CompensationEligibilityScreen> createState() =>
      _CompensationEligibilityScreenState();
}

class _CompensationEligibilityScreenState
    extends State<CompensationEligibilityScreen> {
  bool isInsured = false;
  bool isAadhaarLinked = false;
  bool isNaturalCalamity = false;
  bool knowsDamagePercent = false;

  bool showResult = false;

  void _checkEligibility() {
    setState(() {
      showResult = true;
    });
  }

  bool get isEligible =>
      isInsured && isAadhaarLinked && isNaturalCalamity;

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
          isHindi ? 'पात्रता जांच' : 'Eligibility Check',
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
                const Icon(Icons.verified_user,
                    color: Color(0xFF2E7D32), size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isHindi
                        ? 'जांचें कि आप फसल नुकसान\n'
                          'मुआवज़े के पात्र हैं या नहीं'
                        : 'Check whether you are eligible\n'
                          'for crop loss compensation',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _sectionTitle(isHindi ? 'पात्रता प्रश्न' : 'Eligibility Questions'),

          const SizedBox(height: 12),

          _checkTile(
            title: isHindi ? 'पीएमएफबीवाई के अंतर्गत बीमित किसान' : 'Farmer insured under PMFBY',
            subtitle: isHindi ? 'प्रधानमंत्री फसल बीमा योजना' : 'Pradhan Mantri Fasal Bima Yojana',
            value: isInsured,
            onChanged: (val) {
              setState(() {
                isInsured = val!;
              });
            },
          ),

          _checkTile(
            title: isHindi ? 'आधार बैंक खाते से जुड़ा है' : 'Aadhaar linked with bank account',
            subtitle: isHindi ? 'डीबीटी भुगतान के लिए आवश्यक' : 'Required for DBT payment',
            value: isAadhaarLinked,
            onChanged: (val) {
              setState(() {
                isAadhaarLinked = val!;
              });
            },
          ),

          _checkTile(
            title: isHindi ? 'सूचित प्राकृतिक आपदा से नुकसान' : 'Damage due to notified natural calamity',
            subtitle: isHindi ? 'बाढ़, ओलावृष्टि, सूखा, कीट आदि' : 'Flood, hailstorm, drought, pest etc.',
            value: isNaturalCalamity,
            onChanged: (val) {
              setState(() {
                isNaturalCalamity = val!;
              });
            },
          ),

          _checkTile(
            title: isHindi ? 'क्या आपको नुकसान का प्रतिशत पता है?' : 'Do you know damage percentage?',
            subtitle: isHindi ? 'अनुमानित फसल नुकसान प्रतिशत' : 'Approximate crop loss percentage',
            value: knowsDamagePercent,
            onChanged: (val) {
              setState(() {
                knowsDamagePercent = val!;
              });
            },
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.search),
              label: Text(isHindi ? 'पात्रता जांचें' : 'Check Eligibility'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
              ),
              onPressed: _checkEligibility,
            ),
          ),

          const SizedBox(height: 24),

          if (showResult)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isEligible
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isEligible
                      ? Colors.green
                      : Colors.red,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isEligible
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isEligible
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: isEligible
                            ? Colors.green
                            : Colors.red,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isEligible
                            ? (isHindi ? 'किसान संभवतः पात्र है' : 'Farmer is likely ELIGIBLE')
                            : (isHindi ? 'किसान पात्र नहीं है' : 'Farmer is NOT eligible'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isEligible
                              ? Colors.green.shade800
                              : Colors.red.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (isEligible)
                    Text(
                      isHindi
                          ? 'अगले चरण:\n'
                            '1) 7 दिनों के भीतर ब्लॉक / तहसील कार्यालय से संपर्क करें\n'
                            '2) फसल नुकसान दर्ज कराएं (गिरदावरी / सर्वे)\n'
                            '3) पीएमएफबीवाई पोर्टल / बैंक / सीएससी से आवेदन करें\n'
                            '4) दस्तावेज़ जमा करें (आधार, बैंक, भूमि रिकॉर्ड, फोटो)\n'
                            '5) डीबीटी भुगतान की स्थिति जांचें'
                          : 'Next Steps:\n'
                            '1) Contact Block / Tehsil office within 7 days\n'
                            '2) Register crop damage (Girdawari / Survey)\n'
                            '3) Apply via PMFBY portal / Bank / CSC\n'
                            '4) Submit documents (Aadhaar, bank, land record, photos)\n'
                            '5) Track DBT credit status',
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  if (!isEligible)
                    Text(
                      isHindi
                          ? 'कृपया अपनी जानकारी जांचें और सहायता के लिए नजदीकी कृषि कार्यालय से संपर्क करें।'
                          : 'Please verify your details and contact the nearest agricultural office for assistance.',
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          Text(
            isHindi
                ? 'नोट: पात्रता केवल संकेतात्मक है। अंतिम निर्णय '
                  'आधिकारिक सर्वेक्षण और जिला अधिसूचना पर निर्भर करता है।'
                : 'Note: Eligibility is indicative only. Final decision '
                  'depends on official survey and district notification.',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: Colors.grey),
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

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _checkTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF2E7D32),
      ),
    );
  }
}