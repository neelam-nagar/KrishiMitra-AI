import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../core/config/app_config.dart';

class CropDiseaseScreen extends StatefulWidget {
  const CropDiseaseScreen({super.key});
  @override
  State<CropDiseaseScreen> createState() => _CropDiseaseScreenState();
}

class _CropDiseaseScreenState extends State<CropDiseaseScreen>
    with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  Uint8List? _webImage;
  bool _isLoading = false;

  String plant = '';
  String disease = '';
  double confidenceValue = 0;
  bool isHealthy = false;
  String severity = '';
  List<dynamic> pesticides = [];
  String spray = '';
  String savdhani = '';
  List<dynamic> helplines = [];

  late AnimationController _resultController;
  late AnimationController _confidenceController;
  late Animation<double> _resultAnim;
  late Animation<double> _confidenceAnim;

  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color midGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF4CAF50);
  static const Color bgColor = Color(0xFFF8FBF8);

  @override
  void initState() {
    super.initState();
    _resultController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _resultAnim = CurvedAnimation(parent: _resultController, curve: Curves.easeOutBack);
    _confidenceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _confidenceAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _confidenceController, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _resultController.dispose();
    _confidenceController.dispose();
    super.dispose();
  }

  Future<void> pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source, imageQuality: 90);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedImage = image;
        _webImage = bytes;
        plant = '';
        disease = '';
        confidenceValue = 0;
      });
    }
  }

  Future<void> predictDisease() async {
    if (_selectedImage == null || _webImage == null) return;
    setState(() => _isLoading = true);
    try {
      final request = http.MultipartRequest(
        'POST', Uri.parse('${AppConfig.diseaseApiBase}/api/disease/predict'));
      request.files.add(http.MultipartFile.fromBytes(
          'image', _webImage!, filename: _selectedImage!.name));
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        final data = jsonDecode(responseData) as Map<String, dynamic>;
        final label = data['label']?.toString() ?? '';
        final parts = label.split('_');
        setState(() {
          plant = data['hindi']?.toString().split(' - ').first ?? parts.first;
          disease = data['hindi']?.toString().contains('स्वस्थ') == true
              ? 'स्वस्थ'
              : (parts.length > 1 ? parts.sublist(1).join(' ') : label);
          confidenceValue = double.tryParse(data['confidence']?.toString() ?? '0') ?? 0;
          isHealthy = data['is_healthy'] as bool? ?? false;
          severity = data['severity']?.toString() ?? '';
          pesticides = data['pesticides'] as List<dynamic>? ?? [];
          spray = data['spray']?.toString() ?? '';
          savdhani = data['savdhani']?.toString() ?? '';
          helplines = data['helpline'] as List<dynamic>? ?? [];
        });
        _resultController.forward(from: 0);
        _confidenceController.forward(from: 0);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('कनेक्शन त्रुटि। पुनः प्रयास करें।')));
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),
                _buildStepCards(),
                const SizedBox(height: 24),
                _buildImageSection(),
                const SizedBox(height: 16),
                _buildSourceButtons(),
                const SizedBox(height: 20),
                _buildAnalyzeButton(),
                const SizedBox(height: 24),
                if (plant.isNotEmpty) _buildResultSection(),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      backgroundColor: primaryGreen,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.biotech_rounded, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 14),
                    const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('फसल रोग पहचान',
                          style: TextStyle(color: Colors.white, fontSize: 22,
                              fontWeight: FontWeight.w800, letterSpacing: 0.3)),
                      Text('AI से तुरंत जांच करें',
                          style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ]),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: const Row(children: [
                        Icon(Icons.circle, color: Color(0xFF69F0AE), size: 8),
                        SizedBox(width: 6),
                        Text('Live AI', style: TextStyle(color: Colors.white, fontSize: 12,
                            fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepCards() {
    return Row(children: [
      _stepCard('1', Icons.photo_camera_outlined, 'फोटो लें', Colors.blue),
      const SizedBox(width: 10),
      _stepCard('2', Icons.biotech_outlined, 'AI जांच', Colors.orange),
      const SizedBox(width: 10),
      _stepCard('3', Icons.medication_outlined, 'उपचार पाएं', Colors.green),
    ]);
  }

  Widget _stepCard(String step, IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.12),
              blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text('Step $step',
              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
              color: Color(0xFF2E2E2E)), textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  Widget _buildImageSection() {
    return GestureDetector(
      onTap: () => _showSourceSheet(),
      child: Container(
        height: 260,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _webImage != null ? lightGreen : Colors.grey.shade200,
            width: _webImage != null ? 2.5 : 1.5,
          ),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: _webImage == null ? _emptyState() : _imagePreview(),
      ),
    );
  }

  Widget _emptyState() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.green.shade50, Colors.green.shade100]),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.add_photo_alternate_rounded, size: 48, color: midGreen),
      ),
      const SizedBox(height: 16),
      const Text('फसल की फोटो यहाँ डालें',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
              color: Color(0xFF1B5E20))),
      const SizedBox(height: 6),
      Text('पत्ती की साफ फोटो लें', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text('🌱 आलू • टमाटर • मक्का • मिर्च • सोयाबीन',
            style: TextStyle(color: Color(0xFF2E7D32), fontSize: 12, fontWeight: FontWeight.w500)),
      ),
    ]);
  }

  Widget _imagePreview() {
    return Stack(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Image.memory(_webImage!, fit: BoxFit.cover,
            width: double.infinity, height: double.infinity),
      ),
      Positioned(top: 12, right: 12,
        child: GestureDetector(
          onTap: () => _showSourceSheet(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(children: [
              Icon(Icons.edit_rounded, color: Colors.white, size: 16),
              SizedBox(width: 6),
              Text('बदलें', style: TextStyle(color: Colors.white, fontSize: 13,
                  fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      ),
      Positioned(bottom: 12, left: 12,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: lightGreen,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 14),
            SizedBox(width: 6),
            Text('फोटो तैयार', style: TextStyle(color: Colors.white, fontSize: 12,
                fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    ]);
  }

  Widget _buildSourceButtons() {
    return Row(children: [
      Expanded(child: _sourceBtn(Icons.camera_alt_rounded, 'कैमरा से लें',
          Colors.blue, () => pickImage(ImageSource.camera))),
      const SizedBox(width: 12),
      Expanded(child: _sourceBtn(Icons.photo_library_rounded, 'गैलरी से चुनें',
          midGreen, () => pickImage(ImageSource.gallery))),
    ]);
  }

  Widget _sourceBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14)),
        ]),
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        onPressed: _isLoading || _webImage == null ? null : predictDisease,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _webImage == null
                  ? [Colors.grey.shade300, Colors.grey.shade300]
                  : [const Color(0xFF1B5E20), const Color(0xFF4CAF50)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Container(
            alignment: Alignment.center,
            child: _isLoading
                ? const SizedBox(width: 24, height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(_webImage == null ? Icons.photo_camera_outlined : Icons.biotech_rounded,
                        color: Colors.white, size: 22),
                    const SizedBox(width: 10),
                    Text(_webImage == null ? 'पहले फोटो चुनें' : 'AI से रोग पहचानें',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                            color: Colors.white, letterSpacing: 0.3)),
                  ]),
          ),
        ),
      ),
    );
  }

  Widget _buildResultSection() {
    return ScaleTransition(
      scale: _resultAnim,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Divider(height: 1),
        const SizedBox(height: 20),
        Row(children: [
          const Icon(Icons.analytics_rounded, color: primaryGreen, size: 22),
          const SizedBox(width: 8),
          const Text('विश्लेषण परिणाम',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: primaryGreen)),
        ]),
        const SizedBox(height: 16),
        _buildResultBanner(),
        const SizedBox(height: 14),
        _buildInfoRow(),
        const SizedBox(height: 14),
        _buildConfidenceCard(),
        if (!isHealthy && pesticides.isNotEmpty) ...[
          const SizedBox(height: 14),
          _buildPesticides(),
        ],
        if (spray.isNotEmpty || savdhani.isNotEmpty) ...[
          const SizedBox(height: 14),
          _buildSpraySavdhani(),
        ],
        if (helplines.isNotEmpty) ...[
          const SizedBox(height: 14),
          _buildHelplines(),
        ],
      ]),
    );
  }

  Widget _buildResultBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isHealthy
              ? [const Color(0xFF1B5E20), const Color(0xFF43A047)]
              : [const Color(0xFFBF360C), const Color(0xFFE64A19)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
          color: (isHealthy ? midGreen : Colors.deepOrange).withValues(alpha: 0.35),
          blurRadius: 16, offset: const Offset(0, 6),
        )],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(isHealthy ? '✅' : '⚠️', style: const TextStyle(fontSize: 28)),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(isHealthy ? 'फसल बिल्कुल स्वस्थ है!' : 'रोग पाया गया',
              style: const TextStyle(color: Colors.white, fontSize: 18,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(plant, style: TextStyle(color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14)),
          if (severity.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(severity, style: const TextStyle(color: Colors.white,
                  fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ],
        ])),
      ]),
    );
  }

  Widget _buildInfoRow() {
    return Row(children: [
      Expanded(child: _infoCard('🌱 फसल', plant, Colors.green.shade50, midGreen)),
      const SizedBox(width: 12),
      Expanded(child: _infoCard('🦠 रोग', disease, Colors.red.shade50, Colors.red.shade700)),
    ]);
  }

  Widget _infoCard(String label, String value, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withValues(alpha: 0.15)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textColor),
            maxLines: 2, overflow: TextOverflow.ellipsis),
      ]),
    );
  }

  Widget _buildConfidenceCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('AI सटीकता',
              style: TextStyle(fontWeight: FontWeight.w700, color: primaryGreen, fontSize: 15)),
          AnimatedBuilder(
            animation: _confidenceAnim,
            builder: (_, __) => Text(
              '${(confidenceValue * _confidenceAnim.value).toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800,
                  color: _confColor(confidenceValue)),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AnimatedBuilder(
            animation: _confidenceAnim,
            builder: (_, __) => LinearProgressIndicator(
              value: (confidenceValue / 100) * _confidenceAnim.value,
              minHeight: 12,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation(_confColor(confidenceValue)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(children: [
          Icon(Icons.circle, size: 8, color: _confColor(confidenceValue)),
          const SizedBox(width: 6),
          Text(
            confidenceValue >= 85 ? 'उच्च सटीकता — परिणाम विश्वसनीय'
                : confidenceValue >= 65 ? 'मध्यम सटीकता — बेहतर फोटो लें'
                : 'कम सटीकता — साफ फोटो से पुनः प्रयास करें',
            style: TextStyle(fontSize: 12, color: _confColor(confidenceValue),
                fontWeight: FontWeight.w500),
          ),
        ]),
      ]),
    );
  }

  Color _confColor(double v) {
    if (v >= 85) return const Color(0xFF2E7D32);
    if (v >= 65) return const Color(0xFFF57C00);
    return const Color(0xFFC62828);
  }

  Widget _buildPesticides() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.science_rounded, color: Colors.orange.shade700, size: 20)),
          const SizedBox(width: 10),
          const Text('अनुशंसित कीटनाशक',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: primaryGreen)),
        ]),
        const SizedBox(height: 14),
        ...pesticides.asMap().entries.map((e) {
          final p = e.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.orange.shade100),
            ),
            child: Row(children: [
              Container(width: 30, height: 30,
                decoration: BoxDecoration(color: Colors.orange.shade700, shape: BoxShape.circle),
                child: Center(child: Text('${e.key + 1}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p['naam'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: primaryGreen)),
                const SizedBox(height: 3),
                Text('मात्रा: ${p['matra'] ?? ''}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ])),
              Text(p['kimat'] ?? '',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: midGreen)),
            ]),
          );
        }),
      ]),
    );
  }

  Widget _buildSpraySavdhani() {
    return Row(children: [
      if (spray.isNotEmpty)
        Expanded(child: _chipCard('💧', 'स्प्रे समय', spray,
            Colors.blue.shade50, Colors.blue.shade200)),
      if (spray.isNotEmpty && savdhani.isNotEmpty) const SizedBox(width: 12),
      if (savdhani.isNotEmpty)
        Expanded(child: _chipCard('⚠️', 'सावधानी', savdhani,
            Colors.amber.shade50, Colors.amber.shade200)),
    ]);
  }

  Widget _chipCard(String emoji, String title, String value, Color bg, Color border) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 8),
        Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 11,
            fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
            color: primaryGreen)),
      ]),
    );
  }

  Widget _buildHelplines() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.green.shade50, Colors.teal.shade50]),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.support_agent_rounded, color: primaryGreen, size: 22),
          SizedBox(width: 8),
          Text('किसान हेल्पलाइन',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: primaryGreen)),
        ]),
        const SizedBox(height: 14),
        ...helplines.map((h) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: midGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.phone_rounded, color: midGreen, size: 18)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(h['naam'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13,
                      color: primaryGreen)),
              Text(h['number'] ?? '',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: midGreen, borderRadius: BorderRadius.circular(12)),
              child: const Text('कॉल करें',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ]),
        )),
      ]),
    );
  }

  void _showSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          const Text('फोटो का स्रोत चुनें',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: primaryGreen)),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _sheetBtn(Icons.camera_alt_rounded, 'कैमरा', Colors.blue,
                () { Navigator.pop(context); pickImage(ImageSource.camera); }),
            _sheetBtn(Icons.photo_library_rounded, 'गैलरी', midGreen,
                () { Navigator.pop(context); pickImage(ImageSource.gallery); }),
          ]),
          const SizedBox(height: 28),
        ]),
      ),
    );
  }

  Widget _sheetBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          width: 70, height: 70,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 10),
        Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: color, fontSize: 14)),
      ]),
    );
  }
}
