import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/app_config.dart';

/// CropPriceApi — connects to the unified KrishiMitra backend.
/// All base URLs come from AppConfig so they can be overridden at build time.
class CropPriceApi {
  static String get _base => AppConfig.cropPriceApiBase;

  static Future<Map<String, dynamic>> fetchCropPrice({
    required String district,
    required String mandi,
    required String crop,
  }) async {
    try {
      final uri = Uri.parse('$_base/api/mandi').replace(
        queryParameters: {'district': district, 'mandi': mandi, 'crop': crop},
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return decoded is List ? {'prices': decoded} : decoded as Map<String, dynamic>;
      }
      throw Exception('Failed to load crop price (\${response.statusCode})');
    } on Exception {
      rethrow;
    }
  }

  static Future<List<String>> getDistricts() async {
    final response = await http
        .get(Uri.parse('$_base/api/mandi/districts'))
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return List<String>.from(data['districts'] as List);
    }
    throw Exception('Failed to load districts');
  }

  static Future<List<String>> getMandis(String district) async {
    final uri = Uri.parse('$_base/api/mandi/mandis')
        .replace(queryParameters: {'district': district});
    final response =
        await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return List<String>.from(data['mandis'] as List);
    }
    throw Exception('Failed to load mandis');
  }

  static Future<List<String>> getCrops(String district, String mandi) async {
    final uri = Uri.parse('$_base/api/mandi/crops')
        .replace(queryParameters: {'district': district, 'mandi': mandi});
    final response =
        await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return List<String>.from(data['crops'] as List);
    }
    throw Exception('Failed to load crops');
  }
}
