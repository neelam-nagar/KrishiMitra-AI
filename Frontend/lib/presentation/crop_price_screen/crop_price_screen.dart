import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';
import '../../core/language_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/price_card_widget.dart';
import '../../data/crop_price/crop_price_api.dart';

class CropPriceScreen extends StatefulWidget {
  const CropPriceScreen({super.key});

  @override
  State<CropPriceScreen> createState() => _CropPriceScreenState();
}

class _CropPriceScreenState extends State<CropPriceScreen> {
  String? _selectedDistrict;
  String? _selectedMandi;
  String _selectedCrop = '';
  bool _isLoading = false;
  List<Map<String, dynamic>> _backendPrices = [];
  List<String> _availableDistricts = [];
  List<String> _availableMandis = [];
  List<String> _availableCrops = [];

  @override
  void initState() {
    super.initState();
    _loadDistricts();
  }

  Future<void> _loadDistricts() async {
    try {
      final d = await CropPriceApi.getDistricts();
      setState(() => _availableDistricts = d);
    } catch (_) {}
  }

  Future<void> _loadMandis() async {
    try {
      if (_selectedDistrict == null) return;
      final m = await CropPriceApi.getMandis(_selectedDistrict!);
      setState(() => _availableMandis = m);
    } catch (_) {}
  }

  Future<void> _loadCrops() async {
    try {
      if (_selectedDistrict == null || _selectedMandi == null) return;
      final c = await CropPriceApi.getCrops(_selectedDistrict!, _selectedMandi!);
      setState(() => _availableCrops = c);
    } catch (_) {}
  }

  Future<void> _loadPriceData() async {
    if (_selectedCrop.isEmpty || _selectedDistrict == null || _selectedMandi == null) return;
    setState(() { _isLoading = true; _backendPrices = []; });
    try {
      final r = await CropPriceApi.fetchCropPrice(
        district: _selectedDistrict!,
        mandi: _selectedMandi!,
        crop: _selectedCrop,
      );
      final raw = (r is List) ? r : List<dynamic>.from(r['prices'] ?? r['data'] ?? []);
      final minP = r['minPrice'] ?? 0;
      final maxP = r['maxPrice'] ?? 0;
      final avgP = r['avgPrice'] ?? 0;
      setState(() {
        _backendPrices = raw.map<Map<String, dynamic>>((item) => {
          'price': item['price'] ?? 0,
          'minPrice': minP,
          'maxPrice': maxP,
          'avgPrice': avgP,
          'date': item['date'] ?? '',
        }).toList();
      });
    } catch (_) {
      setState(() => _backendPrices = []);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().currentLanguage;

    return Scaffold(
      appBar: CustomAppBar(
        title: lang == 'en' ? 'Crop Prices' : 'फसल मूल्य',
      ),
      bottomNavigationBar: CustomBottomBar(
        currentItem: CustomBottomBarItem.marketplace,
        onItemTapped: (_) {},
      ),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // District
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: lang == 'en' ? 'District' : 'जिला',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              value: _availableDistricts.contains(_selectedDistrict) ? _selectedDistrict : null,
              items: _availableDistricts
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (v) async {
                setState(() {
                  _selectedDistrict = v;
                  _selectedMandi = null;
                  _selectedCrop = '';
                  _availableMandis = [];
                  _availableCrops = [];
                  _backendPrices = [];
                });
                await _loadMandis();
              },
            ),
            const SizedBox(height: 12),

            // Mandi
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: lang == 'en' ? 'Mandi' : 'मंडी',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              value: _availableMandis.contains(_selectedMandi) ? _selectedMandi : null,
              items: _availableMandis
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (v) async {
                setState(() {
                  _selectedMandi = v;
                  _selectedCrop = '';
                  _availableCrops = [];
                  _backendPrices = [];
                });
                await _loadCrops();
              },
            ),
            const SizedBox(height: 12),

            // Crop
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: lang == 'en' ? 'Crop' : 'फसल',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              value: _selectedCrop.isEmpty ? null : _selectedCrop,
              items: _availableCrops
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) {
                setState(() => _selectedCrop = v ?? '');
                _loadPriceData();
              },
            ),
            const SizedBox(height: 16),

            // Results
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _selectedCrop.isEmpty
                      ? Center(
                          child: Text(
                            lang == 'en'
                                ? 'Select district, mandi and crop'
                                : 'जिला, मंडी और फसल चुनें',
                            style: TextStyle(color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : _backendPrices.isEmpty
                          ? Center(
                              child: Text(
                                lang == 'en' ? 'No data available' : 'कोई डेटा उपलब्ध नहीं',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _backendPrices.length,
                              itemBuilder: (context, index) {
                                final item = _backendPrices[index];
                                return PriceCardWidget(
                                  onTap: () {},
                                  cropData: {
                                    'name': _selectedCrop,
                                    'nameHindi': _selectedCrop,
                                    'minPrice': item['minPrice'],
                                    'maxPrice': item['maxPrice'],
                                    'avgPrice': item['avgPrice'],
                                    'currentPrice': item['price'],
                                    'lastUpdated': item['date'],
                                    'trend': 'stable',
                                    'change': 0,
                                  },
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
