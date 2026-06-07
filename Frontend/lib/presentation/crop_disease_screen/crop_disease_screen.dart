import 'dart:convert';
import 'dart:typed_data';
// FIX: removed unused 'dart:math' import

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

  late AnimationController _gradientController;
  late AnimationController _resultController;
  late AnimationController _pulseController;
  late Animation<double> _gradientAnim;
  late Animation<double> _resultAnim;
  late Animation<double> _pulseAnim;
  late Animation<double> _confidenceAnim;
  late AnimationController _confidenceController;

  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color midGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF4CAF50);
  // FIX: removed unused 'accentGold' constant
  static const Color bgColor = Color(0xFFF1F8E9);

  @override
  void initState() {
    super.initState();

    _gradientController = AnimationController(
      vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _gradientAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _gradientController, curve: Curves.easeInOut));

    _resultController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700));
    _resultAnim = CurvedAnimation(parent: _resultController, curve: Curves.easeOutBack);

    _pulseController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _confidenceController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200));
    _confidenceAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _confidenceController, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _resultController.dispose();
    _pulseController.dispose();
    _confidenceController.dispose();
    super.dispose();
  }

  Future<void> pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
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
        'POST',
        Uri.parse('${AppConfig.diseaseApiBase}/predict'),
      );
      request.files.add(http.MultipartFile.fromBytes(
        'file', _webImage!, filename: _selectedImage!.name));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseData) as Map<String, dynamic>;
        // Backend returns: label (e.g. "टमाटर_Late_Blight"), hindi, confidence,
        // severity, pesticides, spray, savdhani, helpline, is_healthy
        final label = data['label']?.toString() ?? '';
        final parts = label.split('_');
        setState(() {
          // Extract plant name (first segment of label) from hindi field
          plant = data['hindi']?.toString().split(' - ').first ?? parts.first;
          disease = data['hindi']?.toString().contains('स्वस्थ') == true
              ? 'स्वस्थ'
              : (parts.length > 1 ? parts.sublist(1).join(' ') : label);
          confidenceValue =
              double.tryParse(data['confidence']?.toString() ?? '0') ?? 0;
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
      debugPrint(e.toString());
    }

    setState(() => _isLoading = false);
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('फोटो का स्रोत चुनें',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: primaryGreen)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _sourceButton(icon: Icons.camera_alt_rounded, label: 'कैमरा',
                  onTap: () { Navigator.pop(context); pickImage(ImageSource.camera); }),
                _sourceButton(icon: Icons.photo_library_rounded, label: 'गैलरी',
                  onTap: () { Navigator.pop(context); pickImage(ImageSource.gallery); }),
              ],
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _sourceButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [midGreen, lightGreen],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [BoxShadow(color: midGreen.withValues(alpha: 0.3), blurRadius: 14, offset: const Offset(0, 6))],
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: primaryGreen, fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildAnimatedHeader(),
              const SizedBox(height: 24),
              _buildHeroBanner(),
              const SizedBox(height: 24),
              _buildImagePicker(),
              const SizedBox(height: 20),
              _buildActionButton(),
              const SizedBox(height: 28),
              if (plant.isNotEmpty) _buildResultSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return AnimatedBuilder(
      animation: _gradientAnim,
      builder: (_, __) {
        final t = _gradientAnim.value;
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Color.lerp(primaryGreen, lightGreen, t)!, Color.lerp(lightGreen, primaryGreen, t)!],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: midGreen.withValues(alpha: 0.3 + t * 0.2), blurRadius: 14 + t * 8, offset: const Offset(0, 6))],
              ),
              child: const Icon(Icons.eco, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 14),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('KrishiMitra AI', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: primaryGreen, letterSpacing: 0.3)),
              SizedBox(height: 3),
              Text('स्मार्ट फसल रोग पहचान', style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 0.2)),
            ]),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: lightGreen.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
              child: Row(children: [
                Container(width: 7, height: 7, decoration: const BoxDecoration(color: lightGreen, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                const Text('Live AI', style: TextStyle(color: midGreen, fontSize: 12, fontWeight: FontWeight.w600)),
              ]),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeroBanner() {
    return AnimatedBuilder(
      animation: _gradientAnim,
      builder: (_, __) {
        final t = _gradientAnim.value;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.lerp(primaryGreen, const Color(0xFF1A5C1A), t)!, Color.lerp(const Color(0xFF388E3C), lightGreen, t)!],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [BoxShadow(color: primaryGreen.withValues(alpha: 0.35), blurRadius: 22, offset: const Offset(0, 10))],
          ),
          child: Row(
            children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                  child: const Text('🌾 AI संचालित', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 10),
                const Text('फसल विश्लेषण\nएक क्लिक में',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, height: 1.3, letterSpacing: 0.2)),
                const SizedBox(height: 8),
                Text('रोग पहचानें, उपचार पाएं',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
              ])),
              const SizedBox(width: 16),
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: const Center(child: Text('🌿', style: TextStyle(fontSize: 42))),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('फसल की फोटो', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: primaryGreen)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _showImageSourceSheet,
          child: AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, child) => Transform.scale(scale: _webImage == null ? _pulseAnim.value : 1.0, child: child),
            child: Container(
              height: 300, width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(28),
                border: Border.all(color: _webImage == null ? Colors.green.shade200 : Colors.green.shade400, width: 2),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 10))],
              ),
              child: _webImage == null ? _emptyPickerContent() : _imageContent(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _miniSourceButton(icon: Icons.camera_alt_rounded, label: 'कैमरा', onTap: () => pickImage(ImageSource.camera))),
          const SizedBox(width: 12),
          Expanded(child: _miniSourceButton(icon: Icons.photo_library_rounded, label: 'गैलरी', onTap: () => pickImage(ImageSource.gallery))),
        ]),
      ],
    );
  }

  Widget _emptyPickerContent() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.green.shade50, Colors.green.shade100]), shape: BoxShape.circle),
        child: Icon(Icons.add_photo_alternate_rounded, size: 52, color: midGreen),
      ),
      const SizedBox(height: 18),
      const Text('फसल की फोटो चुनें', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: primaryGreen)),
      const SizedBox(height: 8),
      Text('कैमरा या गैलरी से अपलोड करें', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: lightGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20),
          border: Border.all(color: lightGreen.withValues(alpha: 0.3))),
        child: const Text('🌱 आलू • टमाटर • मक्का • मिर्च',
          style: TextStyle(color: midGreen, fontSize: 12, fontWeight: FontWeight.w500)),
      ),
    ]);
  }

  Widget _imageContent() {
    return Stack(children: [
      ClipRRect(borderRadius: BorderRadius.circular(26),
        child: Image.memory(_webImage!, fit: BoxFit.cover, width: double.infinity, height: double.infinity)),
      Positioned(top: 12, right: 12,
        child: GestureDetector(onTap: _showImageSourceSheet,
          child: Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.edit, color: Colors.white, size: 18)))),
      Positioned(bottom: 12, left: 12,
        child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(16)),
          child: const Row(children: [
            Icon(Icons.check_circle, color: lightGreen, size: 14), SizedBox(width: 6),
            Text('फोटो तैयार है', style: TextStyle(color: Colors.white, fontSize: 12)),
          ]))),
    ]);
  }

  Widget _miniSourceButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: midGreen, size: 20), const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: midGreen, fontWeight: FontWeight.w600, fontSize: 14)),
        ]),
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity, height: 58,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
          padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
        onPressed: _isLoading ? null : predictDisease,
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [primaryGreen, lightGreen],
              begin: Alignment.centerLeft, end: Alignment.centerRight),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: midGreen.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 8))]),
          child: Container(alignment: Alignment.center,
            child: _isLoading
                ? const SizedBox(width: 24, height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.biotech_rounded, color: Colors.white, size: 22), SizedBox(width: 10),
                    Text('रोग पहचानें', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: Colors.white)),
                  ])),
        ),
      ),
    );
  }

  Widget _buildResultSection() {
    return ScaleTransition(scale: _resultAnim,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('विश्लेषण परिणाम', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: primaryGreen)),
        const SizedBox(height: 14),
        Container(width: double.infinity, padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: isHealthy
                ? [const Color(0xFF1B5E20), const Color(0xFF43A047)]
                : [const Color(0xFFE65100), const Color(0xFFFF8F00)]),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [BoxShadow(color: (isHealthy ? midGreen : Colors.orange).withValues(alpha: 0.35), blurRadius: 18, offset: const Offset(0, 8))]),
          child: Row(children: [
            Text(isHealthy ? '✅' : '⚠️', style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(isHealthy ? 'फसल स्वस्थ है!' : 'रोग पाया गया',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(plant, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
            ]),
          ])),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _infoTile(label: 'फसल', value: plant, icon: Icons.grass_rounded)),
          const SizedBox(width: 12),
          Expanded(child: _infoTile(label: 'रोग', value: disease, icon: Icons.bug_report_rounded)),
        ]),
        const SizedBox(height: 16),
        _buildConfidenceBar(),
        if (!isHealthy && pesticides.isNotEmpty) ...[const SizedBox(height: 16), _buildPesticideSection()],
        if (spray.isNotEmpty || savdhani.isNotEmpty) ...[const SizedBox(height: 16), _buildSpraySavdhani()],
        if (helplines.isNotEmpty) ...[const SizedBox(height: 16), _buildHelplines()],
      ]),
    );
  }

  Widget _infoTile({required String label, required String value, required IconData icon}) {
    return Container(padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8F5E9)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: midGreen, size: 20)),
        const SizedBox(height: 10),
        Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: primaryGreen),
          maxLines: 2, overflow: TextOverflow.ellipsis),
      ]),
    );
  }

  Widget _buildConfidenceBar() {
    return Container(padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8F5E9)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Icon(Icons.analytics_rounded, color: midGreen, size: 20), const SizedBox(width: 8),
            const Text('AI सटीकता', style: TextStyle(fontWeight: FontWeight.w700, color: primaryGreen, fontSize: 14)),
          ]),
          AnimatedBuilder(animation: _confidenceAnim, builder: (_, __) {
            final val = confidenceValue * _confidenceAnim.value;
            return Text('${val.toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _confidenceColor(confidenceValue)));
          }),
        ]),
        const SizedBox(height: 14),
        ClipRRect(borderRadius: BorderRadius.circular(8),
          child: AnimatedBuilder(animation: _confidenceAnim, builder: (_, __) {
            return LinearProgressIndicator(
              value: (confidenceValue / 100) * _confidenceAnim.value, minHeight: 10,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(_confidenceColor(confidenceValue)));
          })),
        const SizedBox(height: 10),
        Text(confidenceValue >= 85 ? '🟢 उच्च सटीकता' : confidenceValue >= 65 ? '🟡 मध्यम सटीकता' : '🔴 कम सटीकता',
          style: TextStyle(fontSize: 12, color: _confidenceColor(confidenceValue), fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Color _confidenceColor(double val) {
    if (val >= 85) return const Color(0xFF2E7D32);
    if (val >= 65) return const Color(0xFFFF8F00);
    return const Color(0xFFC62828);
  }

  Widget _buildPesticideSection() {
    return Container(padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8F5E9)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.science_rounded, color: Colors.orange.shade700, size: 20)),
          const SizedBox(width: 10),
          const Text('अनुशंसित कीटनाशक', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: primaryGreen)),
        ]),
        const SizedBox(height: 16),
        ...pesticides.asMap().entries.map((e) {
          final p = e.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.orange.shade100)),
            child: Row(children: [
              Container(width: 28, height: 28,
                decoration: BoxDecoration(color: Colors.orange.shade700, shape: BoxShape.circle),
                child: Center(child: Text('${e.key + 1}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p['naam'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: primaryGreen)),
                const SizedBox(height: 4),
                Text('📏 ${p['matra'] ?? ''}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ])),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade200)),
                child: Text(p['kimat'] ?? '', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: midGreen))),
            ]),
          );
        }),
      ]),
    );
  }

  Widget _buildSpraySavdhani() {
    return Row(children: [
      if (spray.isNotEmpty) Expanded(child: _infoChip(icon: '💧', title: 'स्प्रे समय', value: spray,
        color: Colors.blue.shade50, borderColor: Colors.blue.shade100)),
      if (spray.isNotEmpty && savdhani.isNotEmpty) const SizedBox(width: 12),
      if (savdhani.isNotEmpty) Expanded(child: _infoChip(icon: '⚠️', title: 'सावधानी', value: savdhani,
        color: Colors.amber.shade50, borderColor: Colors.amber.shade100)),
    ]);
  }

  Widget _infoChip({required String icon, required String title, required String value, required Color color, required Color borderColor}) {
    return Container(padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(icon, style: const TextStyle(fontSize: 22)), const SizedBox(height: 8),
        Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primaryGreen)),
      ]),
    );
  }

  Widget _buildHelplines() {
    return Container(padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.green.shade50, Colors.teal.shade50]),
        borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.green.shade100)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Text('📞', style: TextStyle(fontSize: 20)), SizedBox(width: 8),
          Text('हेल्पलाइन नंबर', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: primaryGreen)),
        ]),
        const SizedBox(height: 14),
        ...helplines.map((h) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: midGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.phone, color: midGreen, size: 16)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(h['naam'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: primaryGreen)),
              Text(h['number'] ?? '', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            ])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: midGreen, borderRadius: BorderRadius.circular(10)),
              child: const Text('कॉल करें', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
          ]),
        )),
      ]),
    );
  }
}