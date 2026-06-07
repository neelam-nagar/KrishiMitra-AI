

import 'dart:convert';
import 'package:flutter/services.dart';

/// Service class to load Organic Guide JSON data from assets
/// This connects backend-style JSON data with Flutter UI
class OrganicGuideService {
  /// Load Organic Awareness content (language-based)
  /// lang = 'en' or 'hi'
  static Future<Map<String, dynamic>> loadAwareness(String lang) async {
    final String jsonString = await rootBundle.loadString(
      'assets/organic_guide/language/organic_awareness_$lang.json',
    );
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  /// Load region-specific organic farming data
  /// regionKey example:
  /// 'eastern_rajasthan', 'hadoti_region', 'shekhawati_region',
  /// 'southern_rajasthan', 'western_rajasthan'
  static Future<Map<String, dynamic>> loadRegion(String regionKey) async {
    final String jsonString = await rootBundle.loadString(
      'assets/organic_guide/regions/$regionKey.json',
    );
    return json.decode(jsonString) as Map<String, dynamic>;
  }
}