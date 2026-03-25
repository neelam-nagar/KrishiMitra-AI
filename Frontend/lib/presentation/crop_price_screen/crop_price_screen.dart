import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';
import '../../core/language_provider.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/price_card_widget.dart';
import './widgets/price_filter_widget.dart';
import './widgets/market_selector_widget.dart';
import '../../data/crop_price/crop_price_api.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
/// Crop Price Screen - Real-time market prices for crops
/// Displays current prices from different mandis/markets with filtering
class CropPriceScreen extends StatefulWidget {
  const CropPriceScreen({super.key});

  @override
  State<CropPriceScreen> createState() => _CropPriceScreenState();
}

class _CropPriceScreenState extends State<CropPriceScreen>
    with SingleTickerProviderStateMixin {

  // Selected district
  String? _selectedDistrict;

  // Selected mandi
  String? _selectedMandi;

  // Selected crop
  String _selectedCrop = '';

  // Selected category
  String _selectedCategory = 'All';

  // Search query
  String _searchQuery = '';

  // Tab controller
  late TabController _tabController;

  // Loading state
  bool _isLoading = false;
  List<Map<String, dynamic>> _backendPrices = [];
  List<String> _availableDistricts = [];
  List<String> _availableMandis = [];
  List<String> _availableCrops = [];

  // Mock crop price data
  final List<Map<String, dynamic>> _cropPrices = [
    {
      'name': 'Wheat',
      'nameHindi': 'गेहूं',
      'minPrice': 2050,
      'maxPrice': 2150,
      'avgPrice': 2100,
      'unit': 'Quintal',
      'change': 2.5,
      'lastUpdated': '2 hours ago',
      'category': 'Grains',
    },
    {
      'name': 'Rice',
      'nameHindi': 'चावल',
      'minPrice': 2800,
      'maxPrice': 3200,
      'avgPrice': 3000,
      'unit': 'Quintal',
      'change': -1.2,
      'lastUpdated': '1 hour ago',
      'category': 'Grains',
    },
    {
      'name': 'Potato',
      'nameHindi': 'आलू',
      'minPrice': 1200,
      'maxPrice': 1500,
      'avgPrice': 1350,
      'unit': 'Quintal',
      'change': 5.8,
      'lastUpdated': '3 hours ago',
      'category': 'Vegetables',
    },
    {
      'name': 'Tomato',
      'nameHindi': 'टमाटर',
      'minPrice': 800,
      'maxPrice': 1200,
      'avgPrice': 1000,
      'unit': 'Quintal',
      'change': -3.5,
      'lastUpdated': '2 hours ago',
      'category': 'Vegetables',
    },
    {
      'name': 'Onion',
      'nameHindi': 'प्याज',
      'minPrice': 1500,
      'maxPrice': 1800,
      'avgPrice': 1650,
      'unit': 'Quintal',
      'change': 4.2,
      'lastUpdated': '1 hour ago',
      'category': 'Vegetables',
    },
    {
      'name': 'Cotton',
      'nameHindi': 'कपास',
      'minPrice': 6500,
      'maxPrice': 7200,
      'avgPrice': 6850,
      'unit': 'Quintal',
      'change': 1.5,
      'lastUpdated': '4 hours ago',
      'category': 'Cash Crops',
    },
  ];

  // Categories
  final List<String> _categories = [
    'All',
    'Grains',
    'Vegetables',
    'Fruits',
    'Cash Crops',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDistricts();
  }
  Future<void> _loadDistricts() async {
    try {
      final districts = await CropPriceApi.getDistricts();
      setState(() {
        _availableDistricts = districts;
      });
      if (_availableDistricts.isNotEmpty) {
        _selectedDistrict = _availableDistricts.first;
        await _loadMandis();
      }
    } catch (e) {
      _availableDistricts = [];
    }
  }

  Future<void> _loadMandis() async {
    try {
      if (_selectedDistrict == null) return;
      final mandis = await CropPriceApi.getMandis(_selectedDistrict!);
      setState(() {
        _availableMandis = mandis;
      });
    } catch (e) {
      _availableMandis = [];
    }
  }

  Future<void> _loadCrops() async {
    try {
      if (_selectedDistrict == null || _selectedMandi == null) return;
      final crops = await CropPriceApi.getCrops(_selectedDistrict!, _selectedMandi!);
      setState(() {
        _availableCrops = crops;
      });
    } catch (e) {
      _availableCrops = [];
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String normalizeCrop(String crop) {
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

  /// Load price data
  Future<void> _loadPriceData() async {
    if (_selectedCrop.isEmpty) return;
    print("===== DEBUG START =====");
    print("Selected District: $_selectedDistrict");
    print("Selected Mandi: $_selectedMandi");
    print("Selected Crop: $_selectedCrop");
    print("===== DEBUG END =====");

    setState(() {
      _isLoading = true;
      _backendPrices = [];
    });

    try {
      var response = await CropPriceApi.fetchCropPrice(
        district: (_selectedDistrict ?? '').trim(),
        mandi: (_selectedMandi ?? '').trim(),
        crop: (_selectedCrop).trim(),
      );

      // 🔥 Fallback: try with normalized crop (Hindi -> English)
      List tempCheck = (response is List)
          ? response
          : (response['prices'] ?? response['data'] ?? response['result'] ?? []);
      if (tempCheck.isEmpty) {
        print("Retrying with normalized crop...");
        response = await CropPriceApi.fetchCropPrice(
          district: (_selectedDistrict ?? '').trim(),
          mandi: (_selectedMandi ?? '').trim(),
          crop: normalizeCrop(_selectedCrop),
        );
      }

      print("District: $_selectedDistrict");
      print("Mandi: $_selectedMandi");
      print("Crop: $_selectedCrop");
      print("API Response: $response");

      // Debug prints for raw response type and data
      print("RAW RESPONSE TYPE: ${response.runtimeType}");
      print("RAW RESPONSE DATA: $response");

      setState(() {
        final raw = (response is List)
            ? response
            : (response['prices'] ?? response['data'] ?? response['result'] ?? []);
        final rawPrices = List<Map<String, dynamic>>.from(raw);
        print("PARSED RAW PRICES: $rawPrices");

        final int minPrice = response['minPrice'] ?? 0;
        final int maxPrice = response['maxPrice'] ?? 0;
        final int avgPrice = response['avgPrice'] ?? 0;

        _backendPrices = rawPrices.map((item) {
          final int price = item['price'] ?? 0;

          return {
            'price': price,
            'minPrice': minPrice,
            'maxPrice': maxPrice,
            'avgPrice': avgPrice,
            'date': item['date'] ?? '',
          };
        }).toList();
      });
    } catch (e) {
      setState(() {
        _backendPrices = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Handle refresh
  Future<void> _handleRefresh() async {
    await _loadPriceData();
  }

  Future<Map<String, dynamic>> getPrediction() async {
    final url = Uri.parse("http://127.0.0.1:5002/predict");
    print("Calling API: $url with crop: $_selectedCrop");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "crop": _selectedCrop,
        "month": DateTime.now().month,
        "year": DateTime.now().year,
        "rainfall": 100
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("API ERROR: ${response.body}");
      throw Exception("Failed to load prediction");
    }
  }

  /// Filter prices based on search and category
  List<Map<String, dynamic>> get _filteredPrices {
    return _cropPrices.where((crop) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          (crop['name'] as String).toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
          (crop['nameHindi'] as String).contains(_searchQuery);

      final matchesCategory =
          _selectedCategory == 'All' || crop['category'] == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: isHindi ? 'फसल के दाम' : 'Crop Prices',
        showBackButton: true,
        actions: [],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: Column(
          children: [
            // District selector
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              child: DropdownButtonFormField<String>(
                value: _availableDistricts.contains(_selectedDistrict) ? _selectedDistrict : null,
                decoration: InputDecoration(
                  labelText: isHindi ? 'जिला' : 'District',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
                items: _availableDistricts.map((district) {
                  return DropdownMenuItem(
                    value: district,
                    child: Text(
                      district,
                    ),
                  );
                }).toList(),
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
                value: _availableMandis.contains(_selectedMandi) ? _selectedMandi : null,
                decoration: InputDecoration(
                  labelText: isHindi ? 'मंडी' : 'Mandi',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
                items: _availableMandis.map((mandi) {
                  return DropdownMenuItem(
                    value: mandi,
                    child: Text(mandi),
                  );
                }).toList(),
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
                value: _selectedCrop.isEmpty ? null : _selectedCrop,
                decoration: InputDecoration(
                  labelText: isHindi ? 'फसल' : 'Crop',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
                items: _availableCrops.map((crop) {
                  return DropdownMenuItem(
                    value: crop,
                    child: Text(crop),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCrop = value!;
                  });
                  _loadPriceData();
                },
              ),
            ),

            // Search bar
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            //   child: TextField(
            //     onChanged: (value) => setState(() => _searchQuery = value),
            //     decoration: InputDecoration(
            //       hintText: _currentLanguage == 'EN'
            //           ? 'Search crops...'
            //           : 'फसल खोजें...',
            //       prefixIcon: const Icon(Icons.search),
            //       border: OutlineInputBorder(
            //         borderRadius: BorderRadius.circular(12.0),
            //       ),
            //       filled: true,
            //       fillColor: theme.colorScheme.surface,
            //     ),
            //   ),
            // ),

            // Category filter
            // PriceFilterWidget(
            //   categories: _categories,
            //   selectedCategory: _selectedCategory,
            //   currentLanguage: _currentLanguage,
            //   onCategoryChanged: (category) {
            //     setState(() => _selectedCategory = category);
            //   },
            // ),

            // Tab bar
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  text: isHindi ? 'मौजूदा दाम' : 'Current Prices',
                ),
                Tab(
                  text: isHindi ? 'मूल्य रुझान' : 'Price Trends',
                ),
              ],
            ),

            // Tab view
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
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
          )
        : _backendPrices.isEmpty
            ? _buildEmptyState(isHindi: isHindi)
            : ListView(
                padding: EdgeInsets.all(4.w),
                children: [
                  // 🔥 Top Card (अब scroll होगा)
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
                  }).toList(),
                ],
              ),

                  // Price trends tab (placeholder)
                  _selectedCrop.isEmpty
                      ? Center(
                          child: Text(
                            isHindi ? 'पहले फसल चुनें' : 'Please select crop first',
                          ),
                        )
                      : FutureBuilder(
                          future: _selectedCrop.isEmpty ? null : getPrediction(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  "Error: ${snapshot.error}"
                                ),
                              );
                            } else {
                              final data = snapshot.data as Map<String, dynamic>;

                              // --- PATCHED BLOCK START ---
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

                                      TweenAnimationBuilder(
                                        duration: Duration(milliseconds: 800),
                                        tween: Tween<double>(begin: 0, end: 1),
                                        builder: (context, value, child) {
                                          return Opacity(
                                            opacity: value,
                                            child: Transform.translate(
                                              offset: Offset(0, 50 * (1 - value)),
                                              child: child,
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(4.w),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(16),
                                            boxShadow: [
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
                                                  Icon(Icons.show_chart, color: Colors.green, size: 26),
                                                  SizedBox(width: 10),
                                                  Text(
                                                    "Price Prediction",
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 2.h),
                                              _buildSimpleRow("Min Price", data['min_price']),
                                              _buildSimpleRow("Avg Price", data['avg_price']),
                                              _buildSimpleRow("Max Price", data['max_price']),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                              // --- PATCHED BLOCK END ---
                            }
                          },
                        )
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

  /// Build empty state
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

  /// Show price details
  void _showPriceDetails(Map<String, dynamic> cropData, {required bool isHindi}) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Crop name
                    Text(
                      isHindi ? cropData['nameHindi'] : cropData['name'],
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2.h),

                    // Price details
                    _buildDetailRow(
                      isHindi ? 'न्यूनतम मूल्य' : 'Minimum Price',
                      '₹${cropData['minPrice']}/${cropData['unit']}',
                      theme,
                    ),
                    _buildDetailRow(
                      isHindi ? 'अधिकतम मूल्य' : 'Maximum Price',
                      '₹${cropData['maxPrice']}/${cropData['unit']}',
                      theme,
                    ),
                    _buildDetailRow(
                      isHindi ? 'औसत मूल्य' : 'Average Price',
                      '₹${cropData['avgPrice']}/${cropData['unit']}',
                      theme,
                    ),
                    _buildDetailRow(
                      isHindi ? 'अंतिम अपडेट' : 'Last Updated',
                      cropData['lastUpdated'],
                      theme,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Build detail row
  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(179),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildPriceTile(String title, dynamic value) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 1.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16)),
          Text(
            "₹${value.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double value, Color color) {
    double height = (value / 4000) * 60; // scale
    return Container(
      width: 20,
      height: height.clamp(10, 60),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  Widget _buildSimpleRow(String title, dynamic value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 15, color: Colors.black87),
          ),
          Text(
            "₹${value.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
