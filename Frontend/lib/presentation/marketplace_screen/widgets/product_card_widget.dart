import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/app_export.dart';
import 'package:provider/provider.dart';
import '../../../core/language_provider.dart';
import '../chat_screen.dart'; // NEW

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

  // UPDATED: opens real chat screen
  void _openChat(BuildContext context) {
    final currentUserId = product['sellerId'] as String? ?? '';
    // Don't open chat with yourself
    final myUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (currentUserId == myUid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('यह आपका अपना उत्पाद है')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          otherUserId: currentUserId,
          otherUserName: (product['sellerName'] ?? 'विक्रेता') as String,
          productId: (product['id'] ?? '') as String,
          productName: (product['nameHindi'] ?? product['nameEnglish'] ?? '') as String,
        ),
      ),
    );
  }

  Widget _buildImage(String? imageUrl, double height) {
    final url = (imageUrl ?? '').trim();
    if (url.isEmpty) {
      return Container(
        width: double.infinity,
        height: height,
        color: const Color(0xFFE8F5E9),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.grass, color: Color(0xFF388E3C), size: 40),
            const SizedBox(height: 8),
            Text('No Image', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          ],
        ),
      );
    }
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return Image.network(
        url,
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: double.infinity,
          height: height,
          color: const Color(0xFFE8F5E9),
          child: const Icon(Icons.grass, color: Color(0xFF388E3C), size: 40),
        ),
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Container(
            width: double.infinity,
            height: height,
            color: const Color(0xFFE8F5E9),
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
      );
    }
    return Image.asset(
      url,
      width: double.infinity,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: double.infinity,
        height: height,
        color: const Color(0xFFE8F5E9),
        child: const Icon(Icons.grass, color: Color(0xFF388E3C), size: 40),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';
    final imageUrl = (product['image'] ?? '') as String;

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
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              child: Stack(
                children: [
                  _buildImage(imageUrl, 25.h),
                  if (product['isOrganic'] == true)
                    Positioned(
                      top: 2.w,
                      right: 2.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF388E3C),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.eco, color: Colors.white, size: 14),
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
                  Text(
                    isHindi
                        ? (product['nameHindi'] ?? product['nameEnglish'] ?? '')
                        : (product['nameEnglish'] ?? ''),
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.inventory_2, color: theme.colorScheme.primary, size: 18),
                            SizedBox(width: 1.w),
                            Text('${product['quantity'] ?? 0} ${product['unit'] ?? 'kg'}',
                                style: theme.textTheme.bodyMedium),
                          ],
                        ),
                      ),
                      Text(
                        '₹${product['pricePerUnit'] ?? 0}/${product['unit'] ?? 'kg'}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.grey[600], size: 16),
                      SizedBox(width: 1.w),
                      Expanded(
                        child: Text(
                          isHindi
                              ? '${product['location'] ?? ''} • ${product['distance'] ?? 0} किमी दूर'
                              : '${product['location'] ?? ''} • ${product['distance'] ?? 0} km away',
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFFF6F00), size: 16),
                      SizedBox(width: 1.w),
                      Text('${product['sellerRating'] ?? 0}',
                          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                      SizedBox(width: 3.w),
                      Icon(Icons.calendar_today, color: Colors.grey[600], size: 14),
                      SizedBox(width: 1.w),
                      Text(
                        isHindi
                            ? 'कटाई: ${product['harvestDate'] ?? ''}'
                            : 'Harvested: ${product['harvestDate'] ?? ''}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Icon(Icons.person, color: theme.colorScheme.primary, size: 16),
                      SizedBox(width: 1.w),
                      Text(
                        isHindi
                            ? 'विक्रेता: ${product['sellerName'] ?? 'स्थानीय किसान'}'
                            : 'Seller: ${product['sellerName'] ?? 'Local Farmer'}',
                        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
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
                              _makePhoneCall((product['contactNumber'] ?? '').toString());
                            },
                            icon: const Icon(Icons.phone, color: Colors.white, size: 18),
                            label: Text(
                              isHindi ? 'कॉल करें' : 'Call',
                              style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                              _openChat(context); // NOW OPENS REAL CHAT
                            },
                            icon: Icon(Icons.chat, color: theme.colorScheme.primary, size: 18),
                            label: Text(
                              isHindi ? 'संदेश' : 'Message',
                              style: theme.textTheme.labelLarge?.copyWith(
                                  color: theme.colorScheme.primary),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: theme.colorScheme.primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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