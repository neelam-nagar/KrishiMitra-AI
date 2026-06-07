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

class _CropPriceScreenState extends State<CropPriceScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedDistrict;
  String? _selectedMandi;
  String _selectedCrop = '';
  late TabController _tabController;
  bool _isLoading = false;
  List<Map<String, dynamic>> _backendPrices = [];
  List<String> _availableDistricts = [];
  List<String> _availableMandis = [];
  List<String> _availableCrops = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDistricts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDistricts() async {
    try {
      final districts = await CropPriceApi.getDistricts();
      setState(() => _availableDistricts = districts);
      if (_availableDistricts.isNotEmpty) {
        _selectedDistrict = _availableDistricts.first;
        await _loadMandis();
      }
    } catch (_) {
      setState(() => _availableDistricts = []);
    }
  }

  Future<void> _loadMandis() async {
    try {
      if (_selectedDistrict == null) return;
      final mandis = await CropPriceApi.getMandis(_selectedDistrict!);
      setState(() => _availableMandis = mandis);
    } catch (_) {
      setState(() => _availableMandis = []);
    }
  }

  Future<void> _loadCrops() async {
    try {
      if (_selectedDistrict == null || _selectedMandi == null) return;
      final crops =
          await CropPriceApi.getCrops(_selectedDistrict!, _selectedMandi!);
      setState(() => _availableCrops = crops);
    } catch (_) {
      setState(() => _availableCrops = []);
    }
  }

  Future<void> _loadPriceData() async {
    if (_selectedCrop.isEmpty || _selectedDistrict == null || _selectedMandi == null) return;
    setState(() {
      _isLoading = true;
      _backendPrices = [];
    });
    try {
      final response = await CropPriceApi.fetchCropPrice(
        district: _selectedDistrict!.trim(),
        mandi: _selectedMandi!.trim(),
        crop: _selectedCrop.trim(),
      );
      final raw = (response is List)
          ? response
          : (response['prices'] ?? response['data'] ?? []);
      final rawPrices = List<Map<String, dynamic>>.from(raw);
      final int minPrice = response['minPrice'] ?? 0;
      final int maxPrice = response['maxPrice'] ?? 0;
      final int avgPrice = response['avgPrice'] ?? 0;
      setState(() {
        _backendPrices = rawPrices.map((item) => {
          'price': item['price'] ?? 0,
          'minPrice': minPrice,
          'maxPrice': maxPrice,
          'avgPrice': avgPrice,
          'date': item['date'] ?? '',
        }).toList();
      });
    } catch (_) {
      setState(() => _backendPrices = []);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRefresh() async => _loadPriceData();

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: lang == 'en' ? 'Crop Prices' : 'फसल मूल्य',
      ),
      bottomNavigationBar: const CustomBottomBar(
        currentItem: CustomBottomBarItem.market,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // District dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: lang == 'en' ? 'District' : 'जिला',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                value: _availableDistricts.contains(_selectedDistrict)
                    ? _selectedDistrict
                    : null,
                items: _availableDistricts
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (value) async {
                  setState(() {
                    _selectedDistrict = value;
                    _selectedMandi = null;
                    _selectedCrop = '';
                    _availableMandis = [];
                    _availableCrops = [];
                  });
                  await _loadMandis();
                },
              ),
              const SizedBox(height: 12),

              // Mandi dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: lang == 'en' ? 'Mandi' : 'मंडी',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                value: _availableMandis.contains(_selectedMandi)
                    ? _selectedMandi
                    : null,
                items: _availableMandis
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (value) async {
                  setState(() {
                    _selectedMandi = value;
                    _selectedCrop = '';
                    _availableCrops = [];
                  });
                  await _loadCrops();
                },
              ),
              const SizedBox(height: 12),

              // Crop dropdown
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
                onChanged: (value) {
                  setState(() => _selectedCrop = value ?? '');
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
                                  ? 'Select district, mandi and crop to see prices'
                                  : 'जिला, मंडी और फसल चुनें',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          )
                        : _backendPrices.isEmpty
                            ? Center(
                                child: Text(
                                  lang == 'en'
                                      ? 'No price data available'
                                      : 'कोई डेटा उपलब्ध नहीं',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _backendPrices.length,
                                itemBuilder: (context, index) {
                                  final item = _backendPrices[index];
                                  return PriceCardWidget(
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
      ),
    );
  }
}
