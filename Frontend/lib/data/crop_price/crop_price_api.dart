import 'dart:convert';
import 'package:http/http.dart' as http;

class CropPriceApi {
  static Future<Map<String, dynamic>> fetchCropPrice({
    required String district,
    required String mandi,
    required String crop,
  }) async {
    final uri = Uri.http(
      '127.0.0.1:5000',
      '/mandi',
      {
        'district': district,
        'mandi': mandi,
        'crop': crop,
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      // Ensure always Map format for frontend
      if (decoded is List) {
        return {'prices': decoded};
      } else {
        return decoded;
      }
    } else {
      throw Exception('Failed to load crop price');
    }
  }

  static Future<List<String>> getDistricts() async {
    final response = await http.get(
      Uri.parse("http://127.0.0.1:5000/districts"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data['districts']);
    } else {
      throw Exception('Failed to load districts');
    }
  }

  static Future<List<String>> getMandis(String district) async {
    final uri = Uri.http(
      '127.0.0.1:5000',
      '/mandis',
      {
        'district': district,
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data['mandis']);
    } else {
      throw Exception('Failed to load mandis');
    }
  }

  static Future<List<String>> getCrops(String district, String mandi) async {
    final uri = Uri.http(
      '127.0.0.1:5000',
      '/crops',
      {
        'district': district,
        'mandi': mandi,
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data['crops']);
    } else {
      throw Exception('Failed to load crops');
    }
  }
}