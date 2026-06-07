import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';
import '../../core/language_provider.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/price_card_widget.dart';
import '../../data/crop_price/crop_price_api.dart';
import '../../core/config/app_config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

  Future<void> _loadDistricts() async {
    try {
      final districts = await CropPriceApi.getDistricts();
      setState(() => _availableDistricts = districts);
      if (_availableDistricts.isNotEmpty) {
        _selectedDistrict = _availableDistricts.first;
        await _loadMandis();
      }
    } catch (_) {
      _availableDistricts = [];
    }
  }

  Future<void> _loadMandis() async {
    try {
      if (_selectedDistrict == null) return;
      final mandis = await CropPriceApi.getMandis(_selectedDistrict!);
      setState(() => _availableMandis = mandis);
    } catch (_) {
      _availableMandis = [];
    }
  }

  Future<void> _loadCrops() async {
    try {
      if (_selectedDistrict == null || _selectedMandi == null) return;
      final crops = await CropPriceApi.getCrops(_selectedDistrict!, _selectedMandi!);
      setState(() => _availableCrops = crops);
    } catch (_) {
      _availableCrops = [];
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _normalizeCrop(String crop) {
    crop = crop.toLowerCase();
    if (crop.contains('सोयाबीन')) return 'soybean';
    if (crop.contains('सरसों')) return 'mustard';
    if (crop.contains('गेहूं')) return 'wheat';
    if (crop.contains('चना')) return 'gram';
    if (crop.contains('मक्का')) return 'maize';
    if (crop.contains('प्याज')) return 'onion';
    if (crop.contains('आलू')) return 'potato';
    if (crop.contains('टमाटर')) return 'tomato';
    return crop;
  }

  Future<void> _loadPriceData() async {
    if (_selectedCrop.isEmpty) return;

    setState(() {
      _isLoading = true;
      _backendPrices = [];
    });

    try {
      var response = await CropPriceApi.fetchCropPrice(
        district: (_selectedDistrict ?? '').trim(),
        mandi: (_selectedMandi ?? '').trim(),
        crop: _selectedCrop.trim(),
      );

      List tempCheck = (response is List)
          ? response
          : (response['prices'] ?? response['data'] ?? response['result'] ?? []);

      if (tempCheck.isEmpty) {
        response = await CropPriceApi.fetchCropPrice(
          district: (_selectedDistrict ?? '').trim(),
          mandi: (_selectedMandi ?? '').trim(),
          crop: _normalizeCrop(_selectedCrop),
        );
      }

      setState(() {
        final raw = (response is List)
            ? response
            : (response['prices'] ?? response['data'] ?? response['result'] ?? []);
        final rawPrices = List<Map<String, dynamic>>.from(raw);

        final int minPrice = response['minPrice'] ?? 0;
        final int maxPrice = response['maxPrice'] ?? 0;
        final int avgPrice = response['avgPrice'] ?? 0;

        _backendPrices = rawPrices.map((item) {
          return {
            'price': item['price'] ?? 0,
            'minPrice': minPrice,
            'maxPrice': maxPrice,
            'avgPrice': avgPrice,
            'date': item['date'] ?? '',
          };
        }).toList();
      });
    } catch (_) {
      setState(() => _backendPrices = []);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRefresh() async => _loadPriceData();

  Future<Map<String, dynamic>> _getPrediction() async {
    // Price prediction not available in current backend
    return {};
  }/predict');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'crop': _selectedCrop,
        'month': DateTime.now().month,
        'year': DateTime.now().year,
        'rainfall': 100,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load prediction');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isHindi =
        context.watch<LanguageProvider>().currentLanguage == 'hi';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: isHindi ? 'फसल के दाम' : 'Crop Prices',
        showBackButton: true,
        actions: const [],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: Column(
          children: [
            // District selector
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              child: DropdownButtonFormField<String>(
                initialValue: _availableDistricts.contains(_selectedDistrict)
                    ? _selectedDistrict
                    : null,
                decoration: InputDecoration(
                  labelText: isHindi ? 'जिला' : 'District',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
                items: _availableDistricts
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (value) async {
                  if (value == null) return;
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
            ),

            // Mandi selector
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              child: DropdownButtonFormField<String>(
                initialValue: _availableMandis.contains(_selectedMandi)
                    ? _selectedMandi
                    : null,
                decoration: InputDecoration(
                  labelText: isHindi ? 'मंडी' : 'Mandi',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
                items: _availableMandis
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (value) async {
                  if (value == null) return;
                  setState(() {
                    _selectedMandi = value;
                    _selectedCrop = '';
                    _availableCrops = [];
                  });
                  await _loadCrops();
                },
              ),
            ),

            // Crop selector
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              child: DropdownButtonFormField<String>(
                initialValue: _selectedCrop.isEmpty ? null : _selectedCrop,
                decoration: InputDecoration(
                  labelText: isHindi ? 'फसल' : 'Crop',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
                items: _availableCrops
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedCrop = value!);
                  _loadPriceData();
                },
              ),
            ),

            // Tab bar
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: isHindi ? 'मौजूदा दाम' : 'Current Prices'),
                Tab(text: isHindi ? 'मूल्य रुझान' : 'Price Trends'),
              ],
            ),

            // Tab views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Current prices tab
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _selectedCrop.isEmpty
                          ? Center(
                              child: Padding(
                                padding: EdgeInsets.all(6.w),
                                child: Text(
                                  isHindi
                                      ? 'भाव देखने के लिए कृपया फसल चुनें'
                                      : 'Please select a crop to view prices',
                                  style: theme.textTheme.titleMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : _backendPrices.isEmpty
                              ? _buildEmptyState(isHindi: isHindi)
                              : ListView(
                                  padding: EdgeInsets.all(4.w),
                                  children: [
                                    PriceCardWidget(
                                      cropData: {
                                        'name': _selectedCrop,
                                        'nameHindi': _selectedCrop,
                                        'minPrice': _backendPrices[0]['minPrice'],
                                        'maxPrice': _backendPrices[0]['maxPrice'],
                                        'avgPrice': _backendPrices[0]['avgPrice'],
                                        'unit': 'Quintal',
                                        'change': 0,
                                        'lastUpdated': _backendPrices[0]['date'],
                                      },
                                      onTap: () {},
                                    ),
                                    SizedBox(height: 2.h),
                                    ..._backendPrices.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final item = entry.value;
                                      final currentPrice = item['price'] ?? 0;
                                      final prevPrice = index < _backendPrices.length - 1
                                          ? _backendPrices[index + 1]['price'] ?? currentPrice
                                          : currentPrice;
                                      final changeRaw = prevPrice == 0
                                          ? 0
                                          : ((currentPrice - prevPrice) / prevPrice) * 100;
                                      final change = double.parse(changeRaw.toStringAsFixed(2));

                                      return Padding(
                                        padding: EdgeInsets.only(bottom: 1.5.h),
                                        child: PriceCardWidget(
                                          cropData: {
                                            'name': _selectedCrop,
                                            'nameHindi': _selectedCrop,
                                            'avgPrice': currentPrice,
                                            'minPrice': null,
                                            'maxPrice': null,
                                            'unit': 'Quintal',
                                            'change': change,
                                            'lastUpdated': item['date'],
                                          },
                                          onTap: () {},
                                        ),
                                      );
                                    }),
                                  ],
                                ),

                  // Price trends tab
                  _selectedCrop.isEmpty
                      ? Center(
                          child: Text(
                            isHindi ? 'पहले फसल चुनें' : 'Please select crop first',
                          ),
                        )
                      : FutureBuilder<Map<String, dynamic>>(
                          future: _getPrediction(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}'),
                              );
                            }
                            final data = snapshot.data!;
                            return Padding(
                              padding: EdgeInsets.all(4.w),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Text(
                                      isHindi ? 'आने वाला भाव' : 'Predicted Price',
                                      style: theme.textTheme.titleLarge,
                                    ),
                                    SizedBox(height: 2.h),
                                    TweenAnimationBuilder<double>(
                                      duration: const Duration(milliseconds: 800),
                                      tween: Tween(begin: 0, end: 1),
                                      builder: (context, value, child) => Opacity(
                                        opacity: value,
                                        child: Transform.translate(
                                          offset: Offset(0, 50 * (1 - value)),
                                          child: child,
                                        ),
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.all(4.w),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 8,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(Icons.show_chart,
                                                    color: Colors.green, size: 26),
                                                const SizedBox(width: 10),
                                                const Text(
                                                  'Price Prediction',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 2.h),
                                            _buildSimpleRow('Min Price', data['min_price']),
                                            _buildSimpleRow('Avg Price', data['avg_price']),
                                            _buildSimpleRow('Max Price', data['max_price']),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentItem: CustomBottomBarItem.marketplace,
        onItemTapped: (item) {
          switch (item) {
            case CustomBottomBarItem.dashboard:
              Navigator.pushReplacementNamed(context, AppRoutes.mainDashboard);
            case CustomBottomBarItem.marketplace:
              Navigator.pushReplacementNamed(context, AppRoutes.marketplace);
            case CustomBottomBarItem.community:
              Navigator.pushReplacementNamed(context, AppRoutes.communityChat);
            case CustomBottomBarItem.chatbot:
              Navigator.pushReplacementNamed(context, AppRoutes.aiChatbot);
            case CustomBottomBarItem.profile:
              Navigator.pushReplacementNamed(context, AppRoutes.profile);
          }
        },
      ),
    );
  }

  Widget _buildEmptyState({required bool isHindi}) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'search_off',
            size: 64,
            color: theme.colorScheme.onSurface.withAlpha(77),
          ),
          SizedBox(height: 2.h),
          Text(
            isHindi ? 'कोई फसल नहीं मिली' : 'No crops found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(153),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleRow(String title, dynamic value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 15, color: Colors.black87)),
          Text(
            '₹${(value as num).toStringAsFixed(2)}',
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green),
          ),
        ],
      ),
    );
  }
}