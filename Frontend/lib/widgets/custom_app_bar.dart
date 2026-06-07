import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/language_provider.dart';

enum CustomAppBarVariant { standard, dashboard, search, detail }

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final CustomAppBarVariant variant;
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBackButton;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final String? locationText;
  final String? searchHint;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;

  const CustomAppBar({
    super.key,
    this.variant = CustomAppBarVariant.standard,
    this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.showBackButton = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.locationText,
    this.searchHint,
    this.onSearchChanged,
    this.onSearchSubmitted,
  });

  factory CustomAppBar.dashboard({Key? key, required String locationText, List<Widget>? actions}) =>
      CustomAppBar(key: key, variant: CustomAppBarVariant.dashboard, locationText: locationText, actions: actions);

  factory CustomAppBar.search({Key? key, String? searchHint, ValueChanged<String>? onSearchChanged, ValueChanged<String>? onSearchSubmitted, List<Widget>? actions}) =>
      CustomAppBar(key: key, variant: CustomAppBarVariant.search, searchHint: searchHint, onSearchChanged: onSearchChanged, onSearchSubmitted: onSearchSubmitted, actions: actions);

  factory CustomAppBar.detail({Key? key, required String title, String? subtitle, List<Widget>? actions, bool showBackButton = true}) =>
      CustomAppBar(key: key, variant: CustomAppBarVariant.detail, title: title, subtitle: subtitle, actions: actions, showBackButton: showBackButton);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final colorScheme = Theme.of(context).colorScheme;

    final effectiveBackground = backgroundColor ?? colorScheme.primary;
    final effectiveForeground = foregroundColor ??
        (backgroundColor != null
            ? (ThemeData.estimateBrightnessForColor(backgroundColor!) == Brightness.light ? Colors.black : Colors.white)
            : colorScheme.onPrimary);

    // FIX: removed unreachable default case — enum is exhaustive
    switch (variant) {
      case CustomAppBarVariant.dashboard:
        return _buildDashboardAppBar(context, effectiveBackground, effectiveForeground, lang);
      case CustomAppBarVariant.search:
        return _buildSearchAppBar(context, effectiveBackground, effectiveForeground, lang);
      case CustomAppBarVariant.detail:
        return _buildDetailAppBar(context, effectiveBackground, effectiveForeground, lang);
      case CustomAppBarVariant.standard:
        return _buildStandardAppBar(context, effectiveBackground, effectiveForeground, lang);
    }
  }

  Widget _buildStandardAppBar(BuildContext context, Color bg, Color fg, String lang) {
    return AppBar(
      backgroundColor: bg, foregroundColor: fg, elevation: elevation,
      leading: leading ?? (showBackButton && Navigator.canPop(context)
          ? IconButton(icon: const Icon(Icons.arrow_back), iconSize: 24,
              onPressed: () => Navigator.pop(context), tooltip: lang == 'en' ? 'Back' : 'वापस')
          : null),
      title: title != null
          ? Text(title!, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: fg, letterSpacing: 0.15))
          : null,
      actions: actions,
    );
  }

  Widget _buildDashboardAppBar(BuildContext context, Color bg, Color fg, String lang) {
    return AppBar(
      backgroundColor: bg, foregroundColor: fg, elevation: elevation,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Icon(Icons.location_on, size: 20, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lang == 'en' ? 'Location' : 'स्थान',
                    style: GoogleFonts.openSans(fontSize: 12, fontWeight: FontWeight.w400, color: fg.withValues(alpha: 0.8))),
                Text(locationText ?? (lang == 'en' ? 'Select Location' : 'स्थान चुनें'),
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: fg),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
      actions: actions ?? [
        IconButton(icon: const Icon(Icons.notifications_outlined), iconSize: 24, onPressed: () {}, tooltip: lang == 'en' ? 'Notifications' : 'सूचनाएं'),
        IconButton(icon: const Icon(Icons.account_circle_outlined), iconSize: 24, onPressed: () {}, tooltip: lang == 'en' ? 'Profile' : 'प्रोफ़ाइल'),
      ],
    );
  }

  Widget _buildSearchAppBar(BuildContext context, Color bg, Color fg, String lang) {
    return AppBar(
      backgroundColor: bg, foregroundColor: fg, elevation: elevation,
      leading: IconButton(icon: const Icon(Icons.arrow_back), iconSize: 24,
          onPressed: () => Navigator.pop(context), tooltip: lang == 'en' ? 'Back' : 'वापस'),
      title: TextField(
        autofocus: true,
        style: GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.w400, color: fg),
        decoration: InputDecoration(
          hintText: searchHint ?? (lang == 'en' ? 'Search...' : 'खोजें...'),
          hintStyle: GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.w300, color: fg.withValues(alpha: 0.6)),
          border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
        ),
        onChanged: onSearchChanged,
        onSubmitted: onSearchSubmitted,
      ),
      actions: actions ?? [
        IconButton(icon: const Icon(Icons.clear), iconSize: 24, onPressed: () {}, tooltip: lang == 'en' ? 'Clear' : 'हटाएं'),
      ],
    );
  }

  Widget _buildDetailAppBar(BuildContext context, Color bg, Color fg, String lang) {
    // FIX: removed unused 'theme' local variable
    return AppBar(
      backgroundColor: bg, foregroundColor: fg, elevation: elevation,
      leading: leading ?? (showBackButton && Navigator.canPop(context)
          ? IconButton(icon: const Icon(Icons.arrow_back), iconSize: 24,
              onPressed: () => Navigator.pop(context), tooltip: lang == 'en' ? 'Back' : 'वापस')
          : null),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Text(title!, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: fg, letterSpacing: 0.15)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!, style: GoogleFonts.openSans(fontSize: 12, fontWeight: FontWeight.w400, color: fg.withValues(alpha: 0.8))),
          ],
        ],
      ),
      actions: actions,
    );
  }
}