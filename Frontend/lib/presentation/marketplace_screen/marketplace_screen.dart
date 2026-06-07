import 'package:flutter/material.dart';
import '../../services/storage_service.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
// FIX: removed unnecessary custom_icon_widget import (in app_export)
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/product_card_widget.dart';
import './widgets/search_filter_bar_widget.dart';
import 'package:provider/provider.dart';
import '../../core/language_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
// FIX: removed unnecessary dart:typed_data and flutter/foundation imports
import 'package:firebase_auth/firebase_auth.dart';

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
  // FIX: removed unused _userRole field

  List<Map<String, dynamic>> _allProducts = [];
  List<Map<String, dynamic>> _filteredProducts = [];

  Future<String> _uploadImage() async {
    try {
      return await StorageService.instance.uploadProductImage(
        bytes: await () async {
          final picker = ImagePicker();
          final f = await picker.pickImage(source: ImageSource.gallery);
          if (f == null) return null;
          return await f.readAsBytes();
        }().then((b) => b ?? Uint8List(0)),
        fileName: 'product_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
    } catch (_) {
      return '';
    }
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .orderBy('time', descending: true)
          .limit(50) // FIX: added pagination limit
          .get();

      final data = snapshot.docs.map((doc) {
        final d = doc.data();
        return {
          'id': doc.id,
          'nameHindi': d['nameHindi'] ?? '',
          'nameEnglish': d['nameEnglish'] ?? '',
          'category': d['category'] ?? '',
          'quantity': d['quantity'] ?? 0,
          'unit': d['unit'] ?? '',
          'pricePerUnit': d['pricePerUnit'] ?? 0,
          'location': d['location'] ?? '',
          'distance': d['distance'] ?? 0,
          'contactNumber': d['contactNumber'] ?? '',
          'sellerRating': d['sellerRating'] ?? 0,
          'harvestDate': d['harvestDate'] ?? '',
          'isOrganic': d['isOrganic'] ?? false,
          'availabilityStatus': d['availabilityStatus'] ?? '',
          'image': d['image'] ?? '',
          'semanticLabel': d['semanticLabel'] ?? '',
        };
      }).toList();

      setState(() {
        _allProducts = data;
        _filteredProducts = List.from(_allProducts);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Firestore Error: $e'); // FIX: print → debugPrint
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addProduct(Map<String, dynamic> product) async {
    // FIX: get real username from Firebase Auth
    final user = FirebaseAuth.instance.currentUser;
    try {
      await FirebaseFirestore.instance.collection('products').add({
        ...product,
        'time': FieldValue.serverTimestamp(),
        'sellerId': user?.uid ?? '',
        'sellerName': user?.displayName ?? user?.phoneNumber ?? '',
      });
      _fetchProducts();
    } catch (e) {
      debugPrint('Firestore Error: $e'); // FIX: print → debugPrint
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        if (_filters['category'] != null &&
            product['category'] != _filters['category']) return false;

        final price = product['pricePerUnit'] as num;
        if (price < (_filters['minPrice'] as num) ||
            price > (_filters['maxPrice'] as num)) return false;

        final distance = product['distance'] as num;
        if (distance > (_filters['locationRadius'] as num)) return false;

        if (_filters['availabilityStatus'] != null &&
            product['availabilityStatus'] != _filters['availabilityStatus'])
          return false;

        if (_searchQuery.isNotEmpty) {
          final nameHindi = (product['nameHindi'] as String).toLowerCase();
          final nameEnglish = (product['nameEnglish'] as String).toLowerCase();
          final query = _searchQuery.toLowerCase();
          if (!nameHindi.contains(query) && !nameEnglish.contains(query))
            return false;
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
          setState(() => _filters = filters);
          _applyFilters();
        },
      ),
    );
  }

  Future<void> _refreshProducts() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  Widget _buildBrowseTab() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    final lang = context.watch<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';

    if (_filteredProducts.isEmpty) {
      return EmptyStateWidget(
        message: isHindi ? 'कोई उत्पाद नहीं मिला' : 'No products found',
        submessage: isHindi ? 'फ़िल्टर बदलकर पुनः प्रयास करें' : 'Try adjusting your filters',
        actionLabel: isHindi ? 'फ़िल्टर हटाएं' : 'Clear Filters',
        onActionTapped: () {
          setState(() {
            _filters = {'category': null, 'minPrice': 0, 'maxPrice': 10000, 'locationRadius': 50, 'availabilityStatus': null};
            _searchQuery = '';
            _filteredProducts = List.from(_allProducts);
          });
        },
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshProducts,
      child: ListView(
        padding: EdgeInsets.only(bottom: 10.h),
        children: [
          ..._filteredProducts.where((p) => p['location'] == 'Jaipur').map((product) =>
            ProductCardWidget(product: product, onTap: () =>
              Navigator.pushNamed(context, '/product-detail-screen', arguments: product))),
          ..._filteredProducts.where((p) => p['location'] != 'Jaipur').map((product) =>
            ProductCardWidget(product: product, onTap: () =>
              Navigator.pushNamed(context, '/product-detail-screen', arguments: product))),
        ],
      ),
    );
  }

  Widget _buildMyListingsTab() {
    if (_allProducts.isEmpty) {
      return const EmptyStateWidget(message: 'No listings yet', submessage: 'Start selling your crops');
    }
    return ListView.builder(
      padding: EdgeInsets.only(bottom: 10.h),
      itemCount: _allProducts.length,
      itemBuilder: (context, index) {
        final product = _allProducts[index];
        return ProductCardWidget(
          product: product,
          onTap: () => Navigator.pushNamed(context, '/product-detail-screen', arguments: product),
        );
      },
    );
  }

  Widget _buildMessagesTab() {
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';
    return EmptyStateWidget(
      message: isHindi ? 'कोई संदेश नहीं' : 'No messages',
      submessage: isHindi ? 'खरीदारों और विक्रेताओं के संदेश यहाँ दिखेंगे' : 'Your conversations will appear here',
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
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(isHindi ? 'बाज़ार' : 'Marketplace',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
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
              onSearchChanged: (query) { setState(() => _searchQuery = query); _applyFilters(); },
              onFilterTapped: _showFilterBottomSheet,
              onVoiceSearchTapped: () => HapticFeedback.lightImpact(),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildBrowseTab(), _buildMyListingsTab(), _buildMessagesTab()],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          HapticFeedback.lightImpact();
          final imageUrl = await _uploadImage();
          if (imageUrl.isEmpty) return;
          _addProduct({
            'nameHindi': 'गेहूं', 'nameEnglish': 'Wheat', 'category': 'Grains',
            'quantity': 100, 'unit': 'kg', 'pricePerUnit': 25, 'location': 'Jaipur',
            'distance': 10, 'contactNumber': '9876543210', 'sellerRating': 4.5,
            'harvestDate': '10 March', 'isOrganic': true, 'availabilityStatus': 'Available',
            'image': imageUrl, 'semanticLabel': 'Wheat image',
          });
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(isHindi ? 'फसल बेचें' : 'Sell Crop',
            style: const TextStyle(color: Colors.white)),
        backgroundColor: theme.colorScheme.primary,
      ),
      bottomNavigationBar: CustomBottomBar(
        currentItem: CustomBottomBarItem.marketplace,
        onItemTapped: (item) {
          switch (item) {
            case CustomBottomBarItem.dashboard:
              Navigator.pushReplacementNamed(context, AppRoutes.mainDashboard);
            case CustomBottomBarItem.marketplace:
              break;
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
}