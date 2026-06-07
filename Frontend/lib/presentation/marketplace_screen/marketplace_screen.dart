import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/product_card_widget.dart';
import './widgets/search_filter_bar_widget.dart';

import 'package:provider/provider.dart';
import '../../core/language_provider.dart';

/// Marketplace Screen - Connects farmers and buyers through product listings
/// Provides search, filter, and direct contact functionality
class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  Map<String, dynamic> _filters = {
    'category': null,
    'minPrice': 0,
    'maxPrice': 10000,
    'locationRadius': 50,
    'availabilityStatus': null,
  };
  bool _isLoading = false;
  String _userRole = 'Buyer'; // Mock user role: 'Farmer' or 'Buyer'

  // Mock product data
  final List<Map<String, dynamic>> _allProducts = [
    {
      "id": 1,
      "nameHindi": "गेहूं",
      "nameEnglish": "Wheat",
      "category": "Grains",
      "quantity": 500,
      "unit": "kg",
      "pricePerUnit": 25,
      "location": "Jaipur, Rajasthan",
      "distance": 12,
      "contactNumber": "+91 98765 43210",
      "sellerRating": 4.5,
      "harvestDate": "15 Dec 2025",
      "isOrganic": true,
      "availabilityStatus": "Available",
      "image":
          "https://images.unsplash.com/photo-1687230733030-38734dfac30c",
      "semanticLabel":
          "Golden wheat stalks in a field ready for harvest under bright sunlight",
    },
    {
      "id": 2,
      "nameHindi": "टमाटर",
      "nameEnglish": "Tomato",
      "category": "Vegetables",
      "quantity": 200,
      "unit": "kg",
      "pricePerUnit": 30,
      "location": "Ajmer, Rajasthan",
      "distance": 25,
      "contactNumber": "+91 98765 43211",
      "sellerRating": 4.2,
      "harvestDate": "20 Dec 2025",
      "isOrganic": false,
      "availabilityStatus": "Available",
      "image":
          "https://images.unsplash.com/photo-1732348679625-05320604ab24",
      "semanticLabel":
          "Fresh red tomatoes on vine with green leaves in natural lighting",
    },
    {
      "id": 3,
      "nameHindi": "धान",
      "nameEnglish": "Rice",
      "category": "Grains",
      "quantity": 1000,
      "unit": "kg",
      "pricePerUnit": 35,
      "location": "Udaipur, Rajasthan",
      "distance": 45,
      "contactNumber": "+91 98765 43212",
      "sellerRating": 4.8,
      "harvestDate": "10 Dec 2025",
      "isOrganic": true,
      "availabilityStatus": "Limited Stock",
      "image":
          "https://images.unsplash.com/photo-1622213768697-26eca8b4b803",
      "semanticLabel":
          "Green rice paddy field with water reflecting blue sky and clouds",
    },
    {
      "id": 4,
      "nameHindi": "आम",
      "nameEnglish": "Mango",
      "category": "Fruits",
      "quantity": 150,
      "unit": "kg",
      "pricePerUnit": 80,
      "location": "Kota, Rajasthan",
      "distance": 35,
      "contactNumber": "+91 98765 43213",
      "sellerRating": 4.6,
      "harvestDate": "18 Dec 2025",
      "isOrganic": false,
      "availabilityStatus": "Available",
      "image":
          "https://images.unsplash.com/photo-1652018539099-2dc2a809856e",
      "semanticLabel":
          "Ripe yellow mangoes hanging from tree branch with green leaves",
    },
    {
      "id": 5,
      "nameHindi": "प्याज",
      "nameEnglish": "Onion",
      "category": "Vegetables",
      "quantity": 300,
      "unit": "kg",
      "pricePerUnit": 20,
      "location": "Jodhpur, Rajasthan",
      "distance": 55,
      "contactNumber": "+91 98765 43214",
      "sellerRating": 4.3,
      "harvestDate": "22 Dec 2025",
      "isOrganic": true,
      "availabilityStatus": "Available",
      "image":
          "https://images.unsplash.com/photo-1654722371999-365b88acabdc",
      "semanticLabel":
          "Purple and white onions with papery skin arranged on wooden surface",
    },
    {
      "id": 6,
      "nameHindi": "मिर्च",
      "nameEnglish": "Chili",
      "category": "Spices",
      "quantity": 50,
      "unit": "kg",
      "pricePerUnit": 120,
      "location": "Bikaner, Rajasthan",
      "distance": 70,
      "contactNumber": "+91 98765 43215",
      "sellerRating": 4.7,
      "harvestDate": "12 Dec 2025",
      "isOrganic": false,
      "availabilityStatus": "Limited Stock",
      "image":
          "https://images.unsplash.com/photo-1728430161401-639911af4b50",
      "semanticLabel":
          "Bright red chili peppers arranged in rows on dark background",
    },
  ];

  List<Map<String, dynamic>> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _filteredProducts = List.from(_allProducts);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        // Category filter
        if (_filters['category'] != null &&
            product['category'] != _filters['category']) {
          return false;
        }

        // Price filter
        final price = product['pricePerUnit'] as num;
        if (price < (_filters['minPrice'] as num) ||
            price > (_filters['maxPrice'] as num)) {
          return false;
        }

        // Location filter
        final distance = product['distance'] as num;
        if (distance > (_filters['locationRadius'] as num)) {
          return false;
        }

        // Availability filter
        if (_filters['availabilityStatus'] != null &&
            product['availabilityStatus'] != _filters['availabilityStatus']) {
          return false;
        }

        // Search query filter
        if (_searchQuery.isNotEmpty) {
          final nameHindi = (product['nameHindi'] as String).toLowerCase();
          final nameEnglish = (product['nameEnglish'] as String).toLowerCase();
          final query = _searchQuery.toLowerCase();
          if (!nameHindi.contains(query) && !nameEnglish.contains(query)) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        currentFilters: _filters,
        onApplyFilters: (filters) {
          setState(() {
            _filters = filters;
          });
          _applyFilters();
        },
      ),
    );
  }

  Future<void> _refreshProducts() async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildBrowseTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredProducts.isEmpty) {
      final lang = context.watch<LanguageProvider>().currentLanguage;
      final bool isHindi = lang == 'hi';
      return EmptyStateWidget(
        message: isHindi ? 'कोई उत्पाद नहीं मिला' : 'No products found',
        submessage: isHindi
            ? 'फ़िल्टर या खोज बदलकर पुनः प्रयास करें'
            : 'Try adjusting your filters or search query',
        actionLabel: isHindi ? 'फ़िल्टर हटाएं' : 'Clear Filters',
        onActionTapped: () {
          setState(() {
            _filters = {
              'category': null,
              'minPrice': 0,
              'maxPrice': 10000,
              'locationRadius': 50,
              'availabilityStatus': null,
            };
            _searchQuery = '';
            _filteredProducts = List.from(_allProducts);
          });
        },
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshProducts,
      child: ListView.builder(
        padding: EdgeInsets.only(bottom: 10.h),
        itemCount: _filteredProducts.length,
        itemBuilder: (context, index) {
          final product = _filteredProducts[index];
          return ProductCardWidget(
            product: product,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/product-detail-screen',
                arguments: product,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMyListingsTab() {
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';
    return EmptyStateWidget(
      message: isHindi ? 'अभी कोई सूची नहीं है' : 'No listings yet',
      submessage: isHindi
          ? 'अपनी पहली फसल जोड़कर बिक्री शुरू करें'
          : 'Start selling your crops by posting your first product',
      actionLabel: isHindi ? 'फसल जोड़ें' : 'Post Product',
      onActionTapped: () {
        // Navigate to product listing creation
      },
    );
  }

  Widget _buildMessagesTab() {
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';
    return EmptyStateWidget(
      message: isHindi ? 'कोई संदेश नहीं' : 'No messages',
      submessage: isHindi
          ? 'खरीदारों और विक्रेताओं के संदेश यहाँ दिखेंगे'
          : 'Your conversations with buyers and sellers will appear here',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';

    return Scaffold(
  appBar: AppBar(
  backgroundColor: theme.colorScheme.primary,
  systemOverlayStyle: SystemUiOverlayStyle.light,
  elevation: 0,

  iconTheme: const IconThemeData(
    color: Colors.white,
  ),

  title: Text(
    isHindi ? 'बाज़ार' : 'Marketplace',
    style: theme.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  ),

  actions: [
    IconButton(
      icon: CustomIconWidget(
        iconName: 'notifications_outlined',
        color: Colors.white,
      ),
      onPressed: () {},
    ),
  ],

  // ✅ TAB BAR YAHAN AAYEGA
  bottom: TabBar(
    controller: _tabController,
    indicatorColor: Colors.white,
    labelColor: Colors.white,
    unselectedLabelColor: Colors.white70,
    tabs: [
      Tab(text: isHindi ? 'देखें' : 'Browse'),
      Tab(text: isHindi ? 'मेरी सूची' : 'My Listings'),
      Tab(text: isHindi ? 'संदेश' : 'Messages'),
    ],
  ),
),
      body: SafeArea(
        child: Column(
          children: [
            SearchFilterBarWidget(
              searchQuery: _searchQuery,
              onSearchChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
                _applyFilters();
              },
              onFilterTapped: _showFilterBottomSheet,
              onVoiceSearchTapped: () {
                HapticFeedback.lightImpact();
                // Voice search functionality would be implemented here
              },
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBrowseTab(),
                  _buildMyListingsTab(),
                  _buildMessagesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
  onPressed: () {
    HapticFeedback.lightImpact();

    Navigator.pushNamed(
      context,
      '/add-product-screen',
    );
  },
  icon: const Icon(Icons.add, color: Colors.white),
  label: Text(
    isHindi ? 'फसल बेचें' : 'Sell Crop',
    style: const TextStyle(color: Colors.white),
  ),
  backgroundColor: theme.colorScheme.primary,
),
      bottomNavigationBar: CustomBottomBar(
  currentItem: CustomBottomBarItem.marketplace,
  onItemTapped: (item) {
    switch (item) {
      case CustomBottomBarItem.dashboard:
        Navigator.pushReplacementNamed(context, AppRoutes.mainDashboard);
        break;

      case CustomBottomBarItem.marketplace:
        // already on marketplace
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
}
