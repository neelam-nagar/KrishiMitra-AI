import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/app_export.dart';
import 'package:provider/provider.dart';
import '../../../core/language_provider.dart';

/// Product card widget displaying crop information
/// Shows crop image, name, quantity, price, location, and contact options
class ProductCardWidget extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onTap;

  const ProductCardWidget({
    super.key,
    required this.product,
    required this.onTap,
  });

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _openChat(BuildContext context) {
    final lang = context.read<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isHindi
              ? 'चैट सुविधा जल्द उपलब्ध होगी (Firebase के साथ)।'
              : 'Chat feature will be enabled with backend (Firebase).',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              child: Stack(
                children: [
                  CustomImageWidget(
                    imageUrl: product['image'] as String,
                    width: double.infinity,
                    height: 25.h,
                    fit: BoxFit.cover,
                    semanticLabel: product['semanticLabel'] as String,
                  ),
                  if (product['isOrganic'] == true)
                    Positioned(
                      top: 2.w,
                      right: 2.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF388E3C),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName: 'eco',
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              isHindi ? 'जैविक' : 'Organic',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Crop Name (Hindi/English)
                  Text(
                    isHindi ? product['nameHindi'] : product['nameEnglish'],
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 1.h),
                  // Quantity and Price
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'inventory_2',
                              color: theme.colorScheme.primary,
                              size: 18,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              '${product['quantity']} ${product['unit']}',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹${product['pricePerUnit']}/${product['unit']}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  // Location and Distance
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'location_on',
                        color: theme.brightness == Brightness.light
                            ? const Color(0xFF757575)
                            : const Color(0xFFB0B0B0),
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Expanded(
                        child: Text(
                          isHindi
                              ? '${product['location']} • ${product['distance']} किमी दूर'
                              : '${product['location']} • ${product['distance']} km away',
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  // Seller Rating and Harvest Date
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'star',
                        color: const Color(0xFFFF6F00),
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '${product['sellerRating']}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      CustomIconWidget(
                        iconName: 'calendar_today',
                        color: theme.brightness == Brightness.light
                            ? const Color(0xFF757575)
                            : const Color(0xFFB0B0B0),
                        size: 14,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        isHindi
                            ? 'कटाई: ${product['harvestDate']}'
                            : 'Harvested: ${product['harvestDate']}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'person',
                        color: theme.colorScheme.primary,
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        isHindi
                            ? 'विक्रेता: ${product['sellerName'] ?? 'स्थानीय किसान'}'
                            : 'Seller: ${product['sellerName'] ?? 'Local Farmer'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.8.h),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 6.h,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              _makePhoneCall(product['contactNumber'] as String);
                            },
                            icon: CustomIconWidget(
                              iconName: 'phone',
                              color: theme.colorScheme.onPrimary,
                              size: 18,
                            ),
                            label: Text(
                              isHindi ? 'कॉल करें' : 'Call',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: SizedBox(
                          height: 6.h,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              _openChat(context);
                            },
                            icon: CustomIconWidget(
                              iconName: 'chat',
                              color: theme.colorScheme.primary,
                              size: 18,
                            ),
                            label: Text(
                              isHindi ? 'संदेश' : 'Message',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: theme.colorScheme.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
