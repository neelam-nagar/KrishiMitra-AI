import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/language_provider.dart';

import 'package:provider/provider.dart';

class KisanLoanScreen extends StatelessWidget {
  const KisanLoanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final isEnglish = lang == 'en';

    final loans = [
      {
        "type": "kcc",
        "title_en": "Kisan Credit Card (KCC)",
        "title_hi": "किसान क्रेडिट कार्ड (केसीसी)",
        "desc_en": "Crop loan with low interest",
        "desc_hi": "कम ब्याज पर फसल ऋण",
        "url": "https://www.sbi.co.in/web/agri-rural/agriculture-banking/crop-loan/kisan-credit-card",
      },
      {
        "type": "pmfby",
        "title_en": "PMFBY Insurance",
        "title_hi": "पीएमएफबीवाई बीमा",
        "desc_en": "Crop insurance scheme",
        "desc_hi": "फसल बीमा योजना",
        "url": "https://pmfby.gov.in",
      },
      {
        "type": "nabard",
        "title_en": "NABARD Loan",
        "title_hi": "नाबार्ड ऋण",
        "desc_en": "Long-term agriculture loan",
        "desc_hi": "दीर्घकालिक कृषि ऋण",
        "url": "https://www.nabard.org",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: const Color(0xFF2E7D32),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        color: const Color(0xFFF1F8F4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEnglish ? "Kisan Loan Schemes" : "किसान ऋण योजनाएं",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isEnglish
                        ? "Choose the best loan or scheme for your farming needs"
                        : "अपनी खेती के लिए सही ऋण या योजना चुनें",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                itemCount: loans.length,
                itemBuilder: (context, index) {
                  final loan = loans[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.account_balance, color: Color(0xFF2E7D32)),
                      ),
                      title: Text(
                        isEnglish ? loan['title_en']! : loan['title_hi']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          isEnglish ? loan['desc_en']! : loan['desc_hi']!,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LoanDetailScreen(
                              title: isEnglish ? loan['title_en']! : loan['title_hi']!,
                              url: loan['url']!,
                              isEnglish: isEnglish,
                              type: loan['type']!,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoanDetailScreen extends StatelessWidget {
  final String title;
  final String url;
  final bool isEnglish;
  final String type;

  const LoanDetailScreen({
    super.key,
    required this.title,
    required this.url,
    required this.isEnglish,
    required this.type,
  });

  Future<void> openWebsite() async {
    String finalUrl;

    if (type == "kcc") {
      finalUrl = "https://www.myscheme.gov.in/schemes/kcc";
    } else if (type == "pmfby") {
      finalUrl = "https://pmfby.gov.in";
    } else {
      finalUrl = "https://www.nabard.org";
    }

    final Uri uri = Uri.parse(finalUrl);
    await launchUrl(uri);
  }

  Map<String, dynamic> getSchemeData() {
    if (type == "kcc") {
      return {
        "highlight": isEnglish
            ? "As per RBI & Govt norms | Interest subsidy available under schemes"
            : "सरकारी नियमों के अनुसार | ब्याज पर सब्सिडी उपलब्ध",
        "eligibility": [
          isEnglish
              ? "All farmers including tenant, SHG & groups"
              : "सभी किसान (पट्टेदार, समूह सहित)",
          isEnglish
              ? "Loan based on land size & crop pattern"
              : "भूमि और फसल के आधार पर ऋण",
        ],
        "details": [
          isEnglish
            ? "Loan is provided based on Scale of Finance decided by District Level Technical Committee (DLTC)"
            : "ऋण जिले की स्केल ऑफ फाइनेंस (DLTC) के अनुसार दिया जाता है",
          isEnglish
            ? "Loan amount depends on crop type, land holding and district norms"
            : "ऋण राशि फसल, भूमि और जिले के नियमों पर निर्भर करती है",
          isEnglish
            ? "Interest rate is decided by banks as per RBI guidelines"
            : "ब्याज दर RBI और बैंक के नियमों के अनुसार तय होती है",
          isEnglish
            ? "Interest subvention schemes may reduce effective interest for eligible farmers"
            : "सरकारी सब्सिडी योजनाओं से ब्याज कम हो सकता है",
          isEnglish
            ? "Repayment schedule is generally aligned with crop cycle"
            : "भुगतान आमतौर पर फसल चक्र के अनुसार होता है",
        ],
        "extra": [
          isEnglish
            ? "Scale of finance varies for each district and crop"
            : "हर जिले और फसल के लिए स्केल ऑफ फाइनेंस अलग होता है",
          isEnglish
            ? "Credit limit is revised periodically based on performance"
            : "ऋण सीमा समय-समय पर बदली जा सकती है",
          isEnglish
            ? "Timely repayment may make farmer eligible for interest subvention benefits"
            : "समय पर भुगतान करने पर ब्याज सब्सिडी मिल सकती है",
          isEnglish
            ? "Banks may conduct field verification before approval"
            : "बैंक ऋण से पहले फील्ड जांच कर सकता है",
        ],
      };
    } else if (type == "pmfby") {
      return {
        "highlight": isEnglish
            ? "Pradhan Mantri Fasal Bima Yojana | Premium as per Govt notification"
            : "प्रधानमंत्री फसल बीमा योजना | प्रीमियम सरकार के नियम अनुसार",
        "eligibility": [
          isEnglish
              ? "All farmers (loanee + non-loanee)"
              : "सभी किसान (लोन वाले और बिना लोन वाले)",
        ],
        "details": [
          isEnglish
            ? "Covers yield loss due to natural calamities, pests and diseases"
            : "प्राकृतिक आपदा, कीट और रोग से फसल नुकसान कवर होता है",
          isEnglish
            ? "Premium rates and sum insured are notified by Government"
            : "प्रीमियम और बीमा राशि सरकार द्वारा तय की जाती है",
          isEnglish
            ? "Claims are processed based on crop cutting experiments"
            : "क्लेम फसल कटाई प्रयोग के आधार पर दिया जाता है",
        ],
        "extra": [],
      };
    } else {
      return {
        "highlight": isEnglish
            ? "NABARD Supported Schemes | Through Banks"
            : "नाबार्ड समर्थित योजनाएं | बैंक के माध्यम से",
        "eligibility": [
          isEnglish
              ? "Farmers investing in equipment or infra"
              : "उपकरण या इंफ्रास्ट्रक्चर में निवेश करने वाले किसान",
        ],
        "details": [
          isEnglish
            ? "NABARD provides refinance support to banks for agriculture loans"
            : "नाबार्ड बैंकों को कृषि ऋण के लिए पुनर्वित्त (refinance) देता है",
          isEnglish
            ? "Loans are given by banks for infrastructure like irrigation, tractors, warehouses"
            : "बैंक ट्रैक्टर, सिंचाई और गोदाम के लिए ऋण देते हैं",
          isEnglish
            ? "Loan terms depend on bank policies and NABARD guidelines"
            : "ऋण शर्तें बैंक और नाबार्ड के नियमों पर निर्भर करती हैं",
        ],
        "extra": [],
      };
    }
  }
  Widget step(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: const Color(0xFF2E7D32),
            child: Text(number,
                style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget expandableSection(String title, IconData icon, List<String> items) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFF9FBFA)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF2E7D32), size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        iconColor: const Color(0xFF2E7D32),
        collapsedIconColor: Colors.grey,
        children: items.map((e) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8F4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    e,
                    style: const TextStyle(fontSize: 13.5, height: 1.4),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = getSchemeData();
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: const Color(0xFF2E7D32),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFFF1F8F4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(
                      data["highlight"],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              expandableSection(
                isEnglish ? "Application Process" : "आवेदन प्रक्रिया",
                Icons.timeline,
                [
                  isEnglish
                    ? "Step 1: Visit nearest bank (SBI / RRB / Cooperative) and ask for Kisan Credit Card (KCC) application form"
                    : "स्टेप 1: नजदीकी बैंक (SBI / RRB / सहकारी) में जाकर केसीसी फॉर्म लें",
                  isEnglish
                    ? "Step 2: Fill form with land size, crop type, irrigation source and personal details"
                    : "स्टेप 2: फॉर्म में जमीन, फसल, सिंचाई और व्यक्तिगत जानकारी भरें",

                  isEnglish
                    ? "Step 3: Submit Aadhaar, land record (Jamabandi), bank passbook and photo"
                    : "स्टेप 3: आधार, जमाबंदी, बैंक पासबुक और फोटो जमा करें",

                  isEnglish
                    ? "Step 4: Bank verifies documents and may visit your farm (field verification)"
                    : "स्टेप 4: बैंक दस्तावेज जांचता है और खेत का निरीक्षण भी कर सकता है",

                  isEnglish
                    ? "Step 5: Loan limit is calculated based on district scale, crop type and land area"
                    : "स्टेप 5: ऋण सीमा जिले के स्केल, फसल और जमीन के आधार पर तय होती है",

                  isEnglish
                    ? "Step 6: Loan is approved and amount/card is issued in your bank account"
                    : "स्टेप 6: ऋण स्वीकृत होकर पैसा या कार्ड खाते में आता है",

                  isEnglish
                    ? "Step 7: Use loan for farming and repay after harvest season"
                    : "स्टेप 7: फसल के बाद भुगतान करना होता है",
                ],
              ),

              expandableSection(
                isEnglish ? "Eligibility" : "पात्रता",
                Icons.person,
                [
                  isEnglish
                    ? "All farmers including land owners, tenant farmers, SHGs and groups"
                    : "सभी किसान (जमीन मालिक, पट्टेदार, समूह शामिल)",

                  isEnglish
                    ? "Must be engaged in agriculture or allied activities"
                    : "खेती या कृषि कार्य से जुड़े होना जरूरी है",

                  isEnglish
                    ? "Loan eligibility depends on land size, crop and district scale"
                    : "ऋण पात्रता जमीन, फसल और जिले के स्केल पर निर्भर करती है",
                ],
              ),

              expandableSection(
                isEnglish ? "Details" : "विवरण",
                Icons.info,
                List<String>.from(data["details"]),
              ),

              expandableSection(
                isEnglish ? "Extra Info" : "अतिरिक्त जानकारी",
                Icons.star,
                List<String>.from(data["extra"]),
              ),

          
              expandableSection(
                isEnglish
                    ? "Documents Required"
                    : "आवश्यक दस्तावेज़",
                Icons.description,
                [
                  isEnglish ? "Aadhaar Card" : "आधार कार्ड",
                  isEnglish ? "Land Record" : "भूमि रिकॉर्ड",
                  isEnglish ? "Bank Passbook" : "बैंक पासबुक",
                  isEnglish ? "Photo" : "फोटो",
                ],
              ),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                icon: const Icon(Icons.open_in_new),
                label: Text(isEnglish
                    ? "Apply on Official Website"
                    : "आधिकारिक वेबसाइट पर आवेदन करें"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  elevation: 6,
                  shadowColor: Colors.black45,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: openWebsite,
              ),
            ],
          ),
        ),
      ),
    );
  }
}