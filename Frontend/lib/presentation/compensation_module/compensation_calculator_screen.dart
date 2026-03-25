import 'package:flutter/material.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../core/app_export.dart';

class CompensationCalculatorScreen extends StatefulWidget {
  const CompensationCalculatorScreen({super.key});

  @override
  State<CompensationCalculatorScreen> createState() =>
      _CompensationCalculatorScreenState();
}

class _CompensationCalculatorScreenState
    extends State<CompensationCalculatorScreen> {
  String _selectedCrop = 'गेहूँ';
  String _selectedCause = 'ओलावृष्टि';
  double _damagePercent = 0;

  double _pmfbyAmount = 0;
  double _sdrfAmount = 0;
  double _totalAmount = 0;

  final List<String> crops = [
    'गेहूँ',
    'सरसों',
    'सोयाबीन',
    'चना',
    'मक्का',
  ];

  final List<String> causes = [
    'ओलावृष्टि',
    'बाढ़',
    'सूखा',
    'कीट / रोग',
    'अन्य',
  ];

  void _calculateCompensation() {
    const double pmfbyRate = 30000; // प्रति हेक्टेयर अनुमानित
    const double sdrfRate = 13500;  // प्रति हेक्टेयर अनुमानित

    setState(() {
      _pmfbyAmount = pmfbyRate * (_damagePercent / 100);
      _sdrfAmount = sdrfRate * (_damagePercent / 100);
      _totalAmount = _pmfbyAmount + _sdrfAmount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text(
          'मुआवज़ा कैलकुलेटर',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔰 Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.calculate, color: Color(0xFF2E7D32), size: 36),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'फसल नुकसान मुआवज़ा का अनुमान\n'
                      'पीएमएफबीवाई + एसडीआरएफ (अनुमानित)',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 📋 Input Section
            _sectionTitle('फसल और नुकसान विवरण'),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _selectedCrop,
              decoration: const InputDecoration(
                labelText: 'फसल चुनें',
                prefixIcon: Icon(Icons.agriculture),
                border: OutlineInputBorder(),
              ),
              items: crops
                  .map(
                    (crop) => DropdownMenuItem(
                      value: crop,
                      child: Text(crop),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCrop = value!;
                });
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'नुकसान प्रतिशत (0 – 100)',
                prefixIcon: Icon(Icons.percent),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _damagePercent = double.tryParse(value) ?? 0;
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedCause,
              decoration: const InputDecoration(
                labelText: 'नुकसान का कारण',
                prefixIcon: Icon(Icons.warning_amber),
                border: OutlineInputBorder(),
              ),
              items: causes
                  .map(
                    (cause) => DropdownMenuItem(
                      value: cause,
                      child: Text(cause),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCause = value!;
                });
              },
            ),

            const SizedBox(height: 24),

            // 🧮 Calculate Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.calculate),
                label: const Text('मुआवज़ा गणना करें'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                ),
                onPressed: _calculateCompensation,
              ),
            ),

            const SizedBox(height: 24),

            // 📊 Result Section
            if (_totalAmount > 0)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(
                        'परिणाम – $_selectedCrop / $_selectedCause',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'नुकसान: ${_damagePercent.toStringAsFixed(1)} %',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'पीएमएफबीवाई मुआवज़ा (अनुमानित): '
                        '₹${_pmfbyAmount.toStringAsFixed(2)}',
                      ),
                      Text(
                        'एसडीआरएफ / राज्य राहत (अनुमानित): '
                        '₹${_sdrfAmount.toStringAsFixed(2)}',
                      ),
                      const Divider(),
                      Text(
                        'कुल अनुमानित मुआवज़ा: ₹${_totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // ℹ️ Disclaimer
            Text(
              'नोट: यह केवल एक अनुमान है। वास्तविक मुआवज़ा '
              'आधिकारिक सर्वेक्षण, जिला अधिसूचना और बीमा रिकॉर्ड पर निर्भर करता है।',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: Colors.grey),
            ),
          ],
        ),
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
      ),
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
}
