import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';
import '../../../core/app_export.dart';
import '../../../core/language_provider.dart';

/// Seller information card widget
class SellerInfoWidget extends StatelessWidget {
  final Map<String, dynamic> seller;

  const SellerInfoWidget({super.key, required this.seller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
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
          Text(
            lang == 'en' ? 'Seller Information' : 'विक्रेता की जानकारी',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 2.h),

          // Seller profile
          Row(
            children: [
              // Avatar
              Container(
                width: 15.w,
                height: 15.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: CustomImageWidget(
                    imageUrl: seller['avatar'] as String,
                    width: 15.w,
                    height: 15.w,
                    fit: BoxFit.cover,
                    semanticLabel: seller['avatarSemanticLabel'] as String,
                  ),
                ),
              ),
              SizedBox(width: 3.w),

              // Seller details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            seller['name'] as String,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (seller['isVerified'] == true) ...[
                          SizedBox(width: 1.w),
                          CustomIconWidget(
                            iconName: 'verified',
                            color: theme.colorScheme.primary,
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'location_on',
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 14,
                        ),
                        SizedBox(width: 1.w),
                        Flexible(
                          child: Text(
                            '${seller['location']} • ${seller['distance']}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 11.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'star',
                          color: const Color(0xFFFF6F00),
                          size: 14,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          lang == 'en'
                            ? '${seller['rating']} (${seller['reviewCount']} reviews)'
                            : '${seller['rating']} (${seller['reviewCount']} समीक्षाएं)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
