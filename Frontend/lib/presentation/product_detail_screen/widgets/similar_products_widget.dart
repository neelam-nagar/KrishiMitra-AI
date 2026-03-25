import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';

import '../../../core/app_export.dart';
import '../../../core/language_provider.dart';

/// Similar products carousel widget
class SimilarProductsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> products;

  const SimilarProductsWidget({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              lang == 'en' ? 'Similar Products' : 'मिलते-जुलते उत्पाद',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
          ),
          SizedBox(height: 2.h),

          // Horizontal scrollable list
          SizedBox(
            height: 28.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: products.length,
              separatorBuilder: (context, index) => SizedBox(width: 3.w),
              itemBuilder: (context, index) {
                final product = products[index];
                return _SimilarProductCard(product: product);
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Similar product card widget
class _SimilarProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const _SimilarProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/product-detail-screen',
          arguments: product,
        );
      },
      child: Container(
        width: 40.w,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.brightness == Brightness.light
                ? const Color(0xFFE0E0E0)
                : const Color(0xFF424242),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: CustomImageWidget(
                imageUrl: product['image'] as String,
                width: 40.w,
                height: 15.h,
                fit: BoxFit.cover,
                semanticLabel: product['imageSemanticLabel'] as String,
              ),
            ),

            // Product details
            Padding(
              padding: EdgeInsets.all(2.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang == 'en'
                        ? product['cropName'] as String
                        : (product['cropNameHindi'] ?? product['cropName']) as String,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    lang == 'en'
                        ? '₹${product['price']} per ${product['unit']}'
                        : '₹${product['price']} प्रति ${product['unit']}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 11.sp,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'location_on',
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 12,
                      ),
                      SizedBox(width: 1.w),
                      Flexible(
                        child: Text(
                          product['distance'] as String,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 10.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
