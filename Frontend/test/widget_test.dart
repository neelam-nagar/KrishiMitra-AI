// KrishiMitra AI — Widget Tests
// Run with: flutter test

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:krishimitra_ai/core/language_provider.dart';
import 'package:krishimitra_ai/core/location_provider.dart';

void main() {
  // ── LanguageProvider ───────────────────────────────────────────────────────
  group('LanguageProvider', () {
    test('defaults to Hindi', () {
      final provider = LanguageProvider();
      expect(provider.currentLanguage, equals('hi'));
    });

    test('changeLanguage switches to English', () {
      final provider = LanguageProvider();
      provider.changeLanguage('en');
      expect(provider.currentLanguage, equals('en'));
    });

    test('changeLanguage switches back to Hindi', () {
      final provider = LanguageProvider();
      provider.changeLanguage('en');
      provider.changeLanguage('hi');
      expect(provider.currentLanguage, equals('hi'));
    });

    test('rejects unknown language codes', () {
      final provider = LanguageProvider();
      final before = provider.currentLanguage;
      // Should either ignore or keep current — must not crash
      try {
        provider.changeLanguage('fr');
      } catch (_) {}
      // Language must remain valid (en or hi)
      expect(['en', 'hi'], contains(provider.currentLanguage));
      // Verify it didn't silently change to unsupported language
      expect(provider.currentLanguage, anyOf(equals('en'), equals('hi')));
    });
  });

  // ── LocationProvider ───────────────────────────────────────────────────────
  group('LocationProvider', () {
    test('starts with no location', () {
      final provider = LocationProvider();
      expect(provider.hasLocation, isFalse);
      expect(provider.district, equals(''));
      expect(provider.tehsil, equals(''));
      expect(provider.village, equals(''));
    });

    test('updateLocation sets values', () {
      final provider = LocationProvider();
      provider.updateLocation(
        district: 'Jaipur',
        tehsil: 'Amber',
        village: 'Chomu',
        latitude: 26.9124,
        longitude: 75.7873,
      );
      expect(provider.district, equals('Jaipur'));
      expect(provider.tehsil, equals('Amber'));
      expect(provider.village, equals('Chomu'));
      expect(provider.hasLocation, isTrue);
    });

    test('fullLocation formats correctly', () {
      final provider = LocationProvider();
      provider.updateLocation(
        district: 'Kota',
        tehsil: 'Kota North',
        village: 'Kheda',
      );
      expect(provider.fullLocation, contains('Kheda'));
      expect(provider.fullLocation, contains('Kota'));
    });

    test('clearLocation resets all fields', () {
      final provider = LocationProvider();
      provider.updateLocation(
          district: 'Ajmer', tehsil: 'Nasirabad', village: 'Bhinai',
          latitude: 26.12, longitude: 74.63);
      provider.clearLocation();
      expect(provider.hasLocation, isFalse);
      expect(provider.fullLocation, equals('Select Location'));
    });

    test('fullLocation shows Select Location when empty', () {
      final provider = LocationProvider();
      expect(provider.fullLocation, equals('Select Location'));
    });
  });

  // ── Widget smoke tests ─────────────────────────────────────────────────────
  group('Widget rendering', () {
    Widget _wrap(Widget child) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
          ChangeNotifierProvider(create: (_) => LocationProvider()),
        ],
        child: MaterialApp(home: child),
      );
    }

    testWidgets('LocationProvider widget integration', (tester) async {
      await tester.pumpWidget(_wrap(
        Builder(builder: (ctx) {
          final loc = ctx.watch<LocationProvider>();
          return Text(loc.fullLocation);
        }),
      ));
      expect(find.text('Select Location'), findsOneWidget);
    });

    testWidgets('LanguageProvider widget integration', (tester) async {
      await tester.pumpWidget(_wrap(
        Builder(builder: (ctx) {
          final lang = ctx.watch<LanguageProvider>();
          return Text(lang.currentLanguage);
        }),
      ));
      // Should display current language code
      expect(find.textContaining(RegExp(r'en|hi')), findsOneWidget);
    });
  });
}
