import 'package:flutter/material.dart';
import '../../../widgets/custom_icon_widget.dart';
import 'package:provider/provider.dart';
import '../../../core/language_provider.dart';

class ModuleCardWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final String iconName;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const ModuleCardWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconName,
    required this.onTap,
    this.onLongPress,
  });

  @override
  State<ModuleCardWidget> createState() => _ModuleCardWidgetState();
}

class _ModuleCardWidgetState extends State<ModuleCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      onLongPress: widget.onLongPress,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.75),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.25),
                      theme.colorScheme.primary.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: CustomIconWidget(
                  iconName: widget.iconName,
                  size: 30,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isHindi ? _hindiTitle(widget.title) : widget.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isHindi ? _hindiSubtitle(widget.subtitle) : widget.subtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF374151),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _hindiTitle(String title) {
    switch (title) {
      case 'Weather':
        return 'मौसम';
      case 'Crop Prices':
        return 'फसल भाव';
      case 'Govt Schemes':
        return 'सरकारी योजनाएं';
      case 'Organic Farming':
        return 'जैविक खेती';
      case 'Marketplace':
        return 'बाजार';
      case 'AI Assistant':
        return 'कृषि मित्र AI';
      case 'Compensation':
        return 'मुआवजा';
      case 'Land Record':
        return 'भूमि रिकॉर्ड';
      default:
        return title;
    }
  }

  String _hindiSubtitle(String subtitle) {
    switch (subtitle) {
      case 'Latest Mandi Rates':
        return 'ताज़ा मंडी भाव';
      case 'View all schemes':
        return 'सभी योजनाएं देखें';
      case 'Regional Guide':
        return 'क्षेत्रीय मार्गदर्शिका';
      case 'Buy & Sell Crops':
        return 'खरीदें और बेचें';
      case 'KrishiMitra AI':
        return 'कृषि मित्र AI';
      case 'Crop loss & relief':
        return 'फसल नुकसान सहायता';
      case 'Bhulekh / Apna Khata':
        return 'भूलेख / अपना खाता';
      default:
        return subtitle;
    }
  }
}
