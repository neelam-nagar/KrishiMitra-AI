import 'package:provider/provider.dart';
import '../../core/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/price_comparison_widget.dart';
import './widgets/product_description_widget.dart';
import './widgets/product_image_gallery_widget.dart';
import './widgets/product_info_widget.dart';
import './widgets/seller_info_widget.dart';
import './widgets/similar_products_widget.dart';
import '../../presentation/main_shell/main_shell_screen.dart';
/// Product Detail Screen - Comprehensive product information for informed buying decisions
class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isBookmarked = false;
  bool _isLoading = false;

  // Mock product data
  final Map<String, dynamic> _productData = {
    'id': 'P001',
    'cropName': 'Organic Wheat',
    'cropNameHindi': 'जैविक गेहूं',
    'variety': 'HD-2967',
    'quantityAvailable': 500,
    'unit': 'kg',
    'pricePerUnit': 25.50,
    'harvestDate': '15 Nov 2024',
    'isOrganic': true,
    'images': [
      {
        'url':
            'https://images.unsplash.com/photo-1554277090-565e6570bc8a',
        'semanticLabel':
            'Golden wheat stalks in agricultural field with clear blue sky background',
      },
      {
        'url':
            'https://images.unsplash.com/photo-1501180536772-5fd6e427968a',
        'semanticLabel':
            'Close-up of wheat grains in farmer hands showing quality and texture',
      },
      {
        'url':
            'https://images.unsplash.com/photo-1716445867588-105a60770e1d',
        'semanticLabel':
            'Wheat field during harvest season with farming equipment in background',
      },
    ],
    'seller': {
      'id': 'S001',
      'name': 'Ramesh Kumar',
      'avatar':
          'https://img.rocket.new/generatedImages/rocket_gen_img_14f1cfca4-1763294024030.png',
      'avatarSemanticLabel':
          'Profile photo of middle-aged Indian farmer with turban and warm smile',
      'location': 'Jaipur, Rajasthan',
      'distance': '12 km away',
      'rating': 4.8,
      'reviewCount': 156,
      'isVerified': true,
      'phone': '+91 98765 43210',
    },
    'description': {
      'farmingMethods':
          'Grown using traditional organic farming methods without any chemical fertilizers or pesticides. Natural compost and cow dung manure used for soil enrichment.',
      'storageConditions':
          'Stored in clean, dry warehouse with proper ventilation. Moisture content maintained below 12% to ensure quality and prevent spoilage.',
      'availabilityTimeline':
          'Available for immediate delivery. Can supply up to 2000 kg within 7 days. Bulk orders accepted with advance notice.',
    },
    'priceComparison': {
      'currentPrice': 25.50,
      'marketAverage': 27.00,
      'mandiPrice': 26.50,
      'trend': 'down',
    },
  };

  // Mock similar products data
  final List<Map<String, dynamic>> _similarProducts = [
    {
      'id': 'P002',
      'cropName': 'Organic Wheat',
      'price': 26.00,
      'unit': 'kg',
      'distance': '8 km away',
      'image':
          'https://images.unsplash.com/photo-1633320882893-069f02daedaf',
      'imageSemanticLabel': 'Golden wheat field with morning sunlight',
    },
    {
      'id': 'P003',
      'cropName': 'Premium Wheat',
      'price': 28.50,
      'unit': 'kg',
      'distance': '15 km away',
      'image':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1addfc585-1766487318277.png',
      'imageSemanticLabel': 'High-quality wheat grains in storage',
    },
    {
      'id': 'P004',
      'cropName': 'Local Wheat',
      'price': 24.00,
      'unit': 'kg',
      'distance': '5 km away',
      'image':
          'https://images.unsplash.com/photo-1707811179851-c1f93698ad46',
      'imageSemanticLabel': 'Fresh wheat harvest in rural farm',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    return MainShellScreen(
      currentItem: CustomBottomBarItem.marketplace,
      child: Scaffold(
      backgroundColor: theme.brightness == Brightness.light
          ? const Color(0xFFFAFAFA)
          : const Color(0xFF121212),
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            CustomScrollView(
              slivers: [
                // App bar
                SliverAppBar(
                  expandedHeight: 40.h,
                  pinned: true,
                  backgroundColor: theme.colorScheme.surface,
                  leading: IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: CustomIconWidget(
                        iconName: 'arrow_back',
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    IconButton(
                      icon: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: CustomIconWidget(
                          iconName: 'share',
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      onPressed: _shareProduct,
                    ),
                    IconButton(
                      icon: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: CustomIconWidget(
                          iconName: _isBookmarked
                              ? 'bookmark'
                              : 'bookmark_border',
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      onPressed: _toggleBookmark,
                    ),
                    SizedBox(width: 2.w),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: ProductImageGalleryWidget(
                      images:
                          _productData['images'] as List<Map<String, dynamic>>,
                    ),
                  ),
                ),

                // Product content
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product information
                      ProductInfoWidget(product: _productData),

                      // Seller information
                      SellerInfoWidget(
                        seller: _productData['seller'] as Map<String, dynamic>,
                      ),

                      // Product description
                      ProductDescriptionWidget(
                        description:
                            _productData['description'] as Map<String, dynamic>,
                      ),

                      // Price comparison
                      PriceComparisonWidget(
                        priceData:
                            _productData['priceComparison']
                                as Map<String, dynamic>,
                      ),

                      // Similar products
                      SimilarProductsWidget(products: _similarProducts),

                      // Bottom spacing for floating button
                      SizedBox(height: 10.h),
                    ],
                  ),
                ),
              ],
            ),

            // Contact seller button
            Positioned(
              bottom: 2.h,
              left: 4.w,
              right: 4.w,
              child: _buildContactButton(theme),
            ),
          ],
        ),
      ),
      ),
    );
  }

  /// Build contact seller button
  Widget _buildContactButton(ThemeData theme) {
    final lang = context.watch<LanguageProvider>().currentLanguage;
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _contactSeller,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          minimumSize: Size(double.infinity, 7.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? SizedBox(
                height: 3.h,
                width: 3.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.onPrimary,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'phone',
                    color: theme.colorScheme.onPrimary,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    lang == 'en' ? 'Contact Seller' : 'विक्रेता से संपर्क करें',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// Contact seller via phone
  Future<void> _contactSeller() async {
    setState(() => _isLoading = true);

    final lang = context.watch<LanguageProvider>().currentLanguage;
    try {
      final seller = _productData['seller'] as Map<String, dynamic>;
      final phoneNumber = seller['phone'] as String;

      // Show contact options dialog
      await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => _buildContactOptionsSheet(phoneNumber),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              lang == 'en'
                  ? 'Unable to contact seller. Please try again.'
                  : 'विक्रेता से संपर्क नहीं हो पाया। कृपया पुनः प्रयास करें।',
            ),
            backgroundColor: const Color(0xFFD32F2F),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Build contact options bottom sheet
  Widget _buildContactOptionsSheet(String phoneNumber) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.all(4.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(height: 2.h),

          // Title
          Text(
            lang == 'en' ? 'Contact Seller' : 'विक्रेता से संपर्क करें',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            phoneNumber,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 3.h),

          // Phone call option
          ListTile(
            leading: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'phone',
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            title: Text(
              lang == 'en' ? 'Call Now' : 'कॉल करें',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
            subtitle: Text(
              lang == 'en'
                  ? 'Direct phone call to seller'
                  : 'विक्रेता को सीधे कॉल करें',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 11.sp,
              ),
            ),
            onTap: () async {
              Navigator.pop(context);
              await _makePhoneCall(phoneNumber);
            },
          ),
          SizedBox(height: 1.h),

          // WhatsApp option
          ListTile(
            leading: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'chat',
                color: const Color(0xFF25D366),
                size: 24,
              ),
            ),
            title: Text(
              'WhatsApp',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
            subtitle: Text(
              lang == 'en'
                  ? 'Message on WhatsApp'
                  : 'व्हाट्सएप पर संदेश भेजें',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 11.sp,
              ),
            ),
            onTap: () async {
              Navigator.pop(context);
              await _openWhatsApp(phoneNumber);
            },
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  /// Make phone call
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        throw 'Could not launch phone dialer';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              lang == 'en'
                  ? 'Unable to make phone call'
                  : 'कॉल नहीं हो पाई',
            ),
            backgroundColor: const Color(0xFFD32F2F),
          ),
        );
      }
    }
  }

  /// Open WhatsApp
  Future<void> _openWhatsApp(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri whatsappUri = Uri.parse('https://wa.me/$cleanNumber');
    final lang = context.watch<LanguageProvider>().currentLanguage;

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch WhatsApp';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              lang == 'en'
                  ? 'WhatsApp not installed'
                  : 'व्हाट्सएप इंस्टॉल नहीं है',
            ),
            backgroundColor: const Color(0xFFD32F2F),
          ),
        );
      }
    }
  }

  /// Share product
  Future<void> _shareProduct() async {
    HapticFeedback.lightImpact();

    final lang = context.watch<LanguageProvider>().currentLanguage;
    final productName = lang == 'en'
        ? _productData['cropName']
        : _productData['cropNameHindi'];
    final price = _productData['pricePerUnit'] as double;
    final unit = _productData['unit'] as String;
    final seller = _productData['seller'] as Map<String, dynamic>;

    final shareText =
        '''
${lang == 'en'
    ? 'Check out this product on KrishiMitra AI:'
    : 'KrishiMitra AI पर यह उत्पाद देखें:'}

$productName
₹$price per $unit

${lang == 'en' ? 'Seller:' : 'विक्रेता:'} ${seller['name']}
${lang == 'en' ? 'Location:' : 'स्थान:'} ${seller['location']}

${lang == 'en' ? 'Contact:' : 'संपर्क:'} ${seller['phone']}
''';

    try {
      await Share.share(shareText);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              lang == 'en'
                  ? 'Unable to share product'
                  : 'उत्पाद साझा नहीं किया जा सका',
            ),
            backgroundColor: const Color(0xFFD32F2F),
          ),
        );
      }
    }
  }

  /// Toggle bookmark
  void _toggleBookmark() {
    HapticFeedback.lightImpact();
    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isBookmarked
              ? (lang == 'en'
                  ? 'Product saved for later'
                  : 'उत्पाद सहेज लिया गया')
              : (lang == 'en'
                  ? 'Product removed from saved'
                  : 'उत्पाद हटाया गया'),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: theme.colorScheme.primary,
      ),
    );
  }
}