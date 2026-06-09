import 'package:flutter/material.dart';
import '../../services/storage_service.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/product_card_widget.dart';
import './widgets/search_filter_bar_widget.dart';
import './widgets/messages_tab_widget.dart'; // NEW
import 'package:provider/provider.dart';
import '../../core/language_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
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
  List<Map<String, dynamic>> _allProducts = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  List<Map<String, dynamic>> _myListings = [];

  Future<Uint8List?> _pickImageBytes() async {
    try {
      final picker = ImagePicker();
      final f = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70, maxWidth: 800);
      if (f == null) return null;
      return await f.readAsBytes();
    } catch (e) {
      debugPrint('Image pick error: $e');
      return null;
    }
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .orderBy('time', descending: true)
          .limit(50)
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
          'sellerId': d['sellerId'] ?? '',
          'sellerName': d['sellerName'] ?? '',
        };
      }).toList();

      setState(() {
        _allProducts = data;
        _filteredProducts = List.from(_allProducts);
        _myListings = user != null
            ? data.where((p) => p['sellerId'] == user.uid).toList()
            : [];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Firestore fetch error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('डेटा लोड नहीं हो सका')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addProduct(Map<String, dynamic> product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first')),
      );
      return;
    }
    try {
      await FirebaseFirestore.instance.collection('products').add({
        ...product,
        'time': FieldValue.serverTimestamp(),
        'sellerId': user.uid,
        'sellerName': user.displayName ?? user.phoneNumber ?? '',
      });
      await _fetchProducts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('उत्पाद सफलतापूर्वक जोड़ा गया! ✓'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Firestore add error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('त्रुटि: $e')),
        );
      }
    }
  }

  Future<void> _showAddProductDialog() async {
    final lang = context.read<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';

    final nameHindiCtrl = TextEditingController();
    final nameEnglishCtrl = TextEditingController();
    final quantityCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    String? selectedCategory;
    bool isOrganic = false;
    Uint8List? selectedImageBytes;
    String uploadedImageUrl = '';

    final categories = ['Grains', 'Vegetables', 'Fruits', 'Spices', 'Pulses'];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isHindi ? 'फसल बेचें' : 'List Your Crop',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final bytes = await _pickImageBytes();
                    if (bytes != null) setModalState(() => selectedImageBytes = bytes);
                  },
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: selectedImageBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(selectedImageBytes!, fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_outlined, color: Colors.grey[500], size: 32),
                              const SizedBox(height: 8),
                              Text(
                                isHindi ? 'फोटो जोड़ें (वैकल्पिक)' : 'Add Photo (optional)',
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                _field(nameHindiCtrl, isHindi ? 'फसल का नाम (हिन्दी)' : 'Crop name in Hindi'),
                _field(nameEnglishCtrl, isHindi ? 'फसल का नाम (English)*' : 'Crop name (English)*'),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: _inputDecoration(isHindi ? 'श्रेणी' : 'Category'),
                  items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setModalState(() => selectedCategory = v),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _field(quantityCtrl, isHindi ? 'मात्रा (kg)' : 'Quantity (kg)', isNumber: true)),
                    const SizedBox(width: 12),
                    Expanded(child: _field(priceCtrl, isHindi ? 'मूल्य/kg (₹)*' : 'Price/kg (₹)*', isNumber: true)),
                  ],
                ),
                _field(locationCtrl, isHindi ? 'स्थान' : 'Location'),
                _field(contactCtrl, isHindi ? 'संपर्क नंबर' : 'Contact Number', isNumber: true),
                Row(
                  children: [
                    Checkbox(
                      value: isOrganic,
                      onChanged: (v) => setModalState(() => isOrganic = v ?? false),
                      activeColor: Theme.of(context).colorScheme.primary,
                    ),
                    Text(isHindi ? 'जैविक उत्पाद' : 'Organic product'),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      if (nameEnglishCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(isHindi ? 'कृपया फसल का नाम भरें' : 'Please enter crop name')),
                        );
                        return;
                      }
                      if (priceCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(isHindi ? 'कृपया मूल्य भरें' : 'Please enter price')),
                        );
                        return;
                      }
                      Navigator.pop(ctx);
                      if (selectedImageBytes != null) {
                        try {
                          uploadedImageUrl = await StorageService.instance.uploadProductImage(
                            bytes: selectedImageBytes!,
                            fileName: '${nameEnglishCtrl.text}_${DateTime.now().millisecondsSinceEpoch}.jpg',
                          );
                        } catch (e) {
                          debugPrint('Image upload failed: $e');
                        }
                      }
                      await _addProduct({
                        'nameHindi': nameHindiCtrl.text.trim(),
                        'nameEnglish': nameEnglishCtrl.text.trim(),
                        'category': selectedCategory ?? 'Grains',
                        'quantity': int.tryParse(quantityCtrl.text) ?? 0,
                        'unit': 'kg',
                        'pricePerUnit': double.tryParse(priceCtrl.text) ?? 0,
                        'location': locationCtrl.text.trim(),
                        'distance': 0,
                        'contactNumber': contactCtrl.text.trim(),
                        'sellerRating': 0.0,
                        'harvestDate': '',
                        'isOrganic': isOrganic,
                        'availabilityStatus': 'Available',
                        'image': uploadedImageUrl,
                        'semanticLabel': '${nameEnglishCtrl.text.trim()} image',
                      });
                    },
                    child: Text(
                      isHindi ? 'उत्पाद जोड़ें' : 'Add Product',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: _inputDecoration(label),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      );

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
        if (_filters['category'] != null && product['category'] != _filters['category']) return false;
        final price = product['pricePerUnit'] as num;
        if (price < (_filters['minPrice'] as num) || price > (_filters['maxPrice'] as num)) return false;
        final distance = product['distance'] as num;
        if (distance > (_filters['locationRadius'] as num)) return false;
        if (_filters['availabilityStatus'] != null &&
            product['availabilityStatus'] != _filters['availabilityStatus']) return false;
        if (_searchQuery.isNotEmpty) {
          final nameHindi = (product['nameHindi'] as String).toLowerCase();
          final nameEnglish = (product['nameEnglish'] as String).toLowerCase();
          final query = _searchQuery.toLowerCase();
          if (!nameHindi.contains(query) && !nameEnglish.contains(query)) return false;
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

  Future<void> _refreshProducts() async => await _fetchProducts();

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
      child: ListView.builder(
        padding: EdgeInsets.only(bottom: 10.h),
        itemCount: _filteredProducts.length,
        itemBuilder: (context, index) {
          final product = _filteredProducts[index];
          return ProductCardWidget(
            product: product,
            onTap: () => Navigator.pushNamed(context, '/product-detail-screen', arguments: product),
          );
        },
      ),
    );
  }

  Widget _buildMyListingsTab() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';

    if (_myListings.isEmpty) {
      return EmptyStateWidget(
        message: isHindi ? 'अभी कोई लिस्टिंग नहीं' : 'No listings yet',
        submessage: isHindi ? 'अपनी फसल बेचना शुरू करें' : 'Start selling your crops',
        actionLabel: isHindi ? 'फसल बेचें' : 'Sell Crop',
        onActionTapped: _showAddProductDialog,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(bottom: 10.h),
      itemCount: _myListings.length,
      itemBuilder: (context, index) {
        final product = _myListings[index];
        return ProductCardWidget(
          product: product,
          onTap: () => Navigator.pushNamed(context, '/product-detail-screen', arguments: product),
        );
      },
    );
  }

  // UPDATED: uses real MessagesTabWidget
  Widget _buildMessagesTab() => const MessagesTabWidget();

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
        title: Text(
          isHindi ? 'बाज़ार' : 'Marketplace',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
        ),
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
              onSearchChanged: (query) {
                setState(() => _searchQuery = query);
                _applyFilters();
              },
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
        onPressed: () {
          HapticFeedback.lightImpact();
          _showAddProductDialog();
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(isHindi ? 'फसल बेचें' : 'Sell Crop', style: const TextStyle(color: Colors.white)),
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