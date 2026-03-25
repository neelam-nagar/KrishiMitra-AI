import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/language_provider.dart';

/// App bar variant types for different screen contexts
enum CustomAppBarVariant {
  /// Standard app bar with back button and title
  standard,

  /// Dashboard app bar with location and profile
  dashboard,

  /// Search app bar with search field
  search,

  /// Detail app bar with actions
  detail,
}

/// Custom app bar widget for agricultural application
/// Implements clean, authoritative design with proper touch targets
/// Supports multiple variants for different screen contexts
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// App bar variant type
  final CustomAppBarVariant variant;

  /// Title text (required for standard, detail variants)
  final String? title;

  /// Subtitle text (optional)
  final String? subtitle;

  /// Leading widget (overrides default back button)
  final Widget? leading;

  /// Action widgets
  final List<Widget>? actions;

  /// Whether to show back button (default: true for standard variant)
  final bool showBackButton;

  /// Custom background color (overrides theme)
  final Color? backgroundColor;

  /// Custom foreground color (overrides theme)
  final Color? foregroundColor;

  /// Elevation (default: 0 for flat design)
  final double elevation;

  /// Location text for dashboard variant
  final String? locationText;

  /// Search hint text for search variant
  final String? searchHint;

  /// Search callback for search variant
  final ValueChanged<String>? onSearchChanged;

  /// Search submit callback for search variant
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

  /// Factory constructor for dashboard variant
  factory CustomAppBar.dashboard({
    Key? key,
    required String locationText,
    List<Widget>? actions,
  }) {
    return CustomAppBar(
      key: key,
      variant: CustomAppBarVariant.dashboard,
      locationText: locationText,
      actions: actions,
    );
  }

  /// Factory constructor for search variant
  factory CustomAppBar.search({
    Key? key,
    String? searchHint,
    ValueChanged<String>? onSearchChanged,
    ValueChanged<String>? onSearchSubmitted,
    List<Widget>? actions,
  }) {
    return CustomAppBar(
      key: key,
      variant: CustomAppBarVariant.search,
      searchHint: searchHint,
      onSearchChanged: onSearchChanged,
      onSearchSubmitted: onSearchSubmitted,
      actions: actions,
    );
  }

  /// Factory constructor for detail variant
  factory CustomAppBar.detail({
    Key? key,
    required String title,
    String? subtitle,
    List<Widget>? actions,
    bool showBackButton = true,
  }) {
    return CustomAppBar(
      key: key,
      variant: CustomAppBarVariant.detail,
      title: title,
      subtitle: subtitle,
      actions: actions,
      showBackButton: showBackButton,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final colorScheme = theme.colorScheme;

    final effectiveBackgroundColor = backgroundColor ?? colorScheme.primary;
    final effectiveForegroundColor =
        foregroundColor ??
        (backgroundColor != null
            ? (ThemeData.estimateBrightnessForColor(backgroundColor!) ==
                      Brightness.light
                  ? Colors.black
                  : Colors.white)
            : colorScheme.onPrimary);

    switch (variant) {
      case CustomAppBarVariant.dashboard:
        return _buildDashboardAppBar(
          context,
          effectiveBackgroundColor,
          effectiveForegroundColor,
          lang,
        );
      case CustomAppBarVariant.search:
        return _buildSearchAppBar(
          context,
          effectiveBackgroundColor,
          effectiveForegroundColor,
          lang,
        );
      case CustomAppBarVariant.detail:
        return _buildDetailAppBar(
          context,
          effectiveBackgroundColor,
          effectiveForegroundColor,
          lang,
        );
      case CustomAppBarVariant.standard:
      default:
        return _buildStandardAppBar(
          context,
          effectiveBackgroundColor,
          effectiveForegroundColor,
          lang,
        );
    }
  }

  /// Builds standard app bar with title and optional back button
  Widget _buildStandardAppBar(
    BuildContext context,
    Color backgroundColor,
    Color foregroundColor,
    String lang,
  ) {
    return AppBar(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      leading:
          leading ??
          (showBackButton && Navigator.canPop(context)
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  iconSize: 24,
                  onPressed: () => Navigator.pop(context),
                  tooltip: lang == 'en' ? 'Back' : 'वापस',
                )
              : null),
      title: title != null
          ? Text(
              title!,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: foregroundColor,
                letterSpacing: 0.15,
              ),
            )
          : null,
      actions: actions,
    );
  }

  /// Builds dashboard app bar with location and profile
  Widget _buildDashboardAppBar(
    BuildContext context,
    Color backgroundColor,
    Color foregroundColor,
    String lang,
  ) {
    return AppBar(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Icon(Icons.location_on, size: 20, color: foregroundColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang == 'en' ? 'Location' : 'स्थान',
                  style: GoogleFonts.openSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: foregroundColor.withValues(alpha: 0.8),
                  ),
                ),
                Text(
                  locationText ?? (lang == 'en' ? 'Select Location' : 'स्थान चुनें'),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: foregroundColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      actions:
          actions ??
          [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              iconSize: 24,
              onPressed: () {
                // Handle notifications
              },
              tooltip: lang == 'en' ? 'Notifications' : 'सूचनाएं',
            ),
            IconButton(
              icon: const Icon(Icons.account_circle_outlined),
              iconSize: 24,
              onPressed: () {
                // Handle profile
              },
              tooltip: lang == 'en' ? 'Profile' : 'प्रोफ़ाइल',
            ),
          ],
    );
  }

  /// Builds search app bar with search field
  Widget _buildSearchAppBar(
    BuildContext context,
    Color backgroundColor,
    Color foregroundColor,
    String lang,
  ) {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        iconSize: 24,
        onPressed: () => Navigator.pop(context),
        tooltip: lang == 'en' ? 'Back' : 'वापस',
      ),
      title: TextField(
        autofocus: true,
        style: GoogleFonts.openSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: foregroundColor,
        ),
        decoration: InputDecoration(
          hintText: searchHint ?? (lang == 'en' ? 'Search...' : 'खोजें...'),
          hintStyle: GoogleFonts.openSans(
            fontSize: 16,
            fontWeight: FontWeight.w300,
            color: foregroundColor.withValues(alpha: 0.6),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        onChanged: onSearchChanged,
        onSubmitted: onSearchSubmitted,
      ),
      actions:
          actions ??
          [
            IconButton(
              icon: const Icon(Icons.clear),
              iconSize: 24,
              onPressed: () {
                // Clear search
              },
              tooltip: lang == 'en' ? 'Clear' : 'हटाएं',
            ),
          ],
    );
  }

  /// Builds detail app bar with title, subtitle, and actions
  Widget _buildDetailAppBar(
    BuildContext context,
    Color backgroundColor,
    Color foregroundColor,
    String lang,
  ) {
    return AppBar(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      leading:
          leading ??
          (showBackButton && Navigator.canPop(context)
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  iconSize: 24,
                  onPressed: () => Navigator.pop(context),
                  tooltip: lang == 'en' ? 'Back' : 'वापस',
                )
              : null),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Text(
              title!,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: foregroundColor,
                letterSpacing: 0.15,
              ),
            ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: GoogleFonts.openSans(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: foregroundColor.withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      ),
      actions: actions,
    );
  }
}
