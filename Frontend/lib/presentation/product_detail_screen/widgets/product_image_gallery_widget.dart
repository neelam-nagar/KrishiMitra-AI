import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';
import '../../../core/app_export.dart';
import '../../../core/language_provider.dart';

/// Product image gallery widget with swipe navigation and zoom capability
class ProductImageGalleryWidget extends StatefulWidget {
  final List<Map<String, dynamic>> images;

  const ProductImageGalleryWidget({super.key, required this.images});

  @override
  State<ProductImageGalleryWidget> createState() =>
      _ProductImageGalleryWidgetState();
}

class _ProductImageGalleryWidgetState extends State<ProductImageGalleryWidget> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showFullScreenImage(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullScreenImageViewer(
          images: widget.images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;

    return Container(
      height: 40.h,
      width: double.infinity,
      color: theme.colorScheme.surface,
      child: Stack(
        children: [
          // Image PageView
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final image = widget.images[index];
              return GestureDetector(
                onTap: () => _showFullScreenImage(context, index),
                child: CustomImageWidget(
                  imageUrl: image['url'] as String,
                  width: double.infinity,
                  height: 40.h,
                  fit: BoxFit.cover,
                  semanticLabel: image['semanticLabel'] as String,
                ),
              );
            },
          ),
          // Page indicators
          if (widget.images.length > 1)
            Positioned(
              bottom: 2.h,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.images.length,
                  (index) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 0.5.w),
                    width: _currentImageIndex == index ? 8.w : 2.w,
                    height: 1.h,
                    decoration: BoxDecoration(
                      color: _currentImageIndex == index
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surface.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

          // Zoom hint
          Positioned(
            top: 2.h,
            right: 4.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'zoom_in',
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    lang == 'en' ? 'Tap to zoom' : 'ज़ूम करने के लिए टैप करें',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full screen image viewer with pinch zoom
class _FullScreenImageViewer extends StatefulWidget {
  final List<Map<String, dynamic>> images;
  final int initialIndex;

  const _FullScreenImageViewer({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'close',
            color: Colors.white,
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${_currentIndex + 1} / ${widget.images.length}',
          style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final image = widget.images[index];
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: CustomImageWidget(
                imageUrl: image['url'] as String,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.contain,
                semanticLabel: image['semanticLabel'] as String,
              ),
            ),
          );
        },
      ),
    );
  }
}
