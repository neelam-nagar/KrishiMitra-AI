import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationProvider with ChangeNotifier {
  String district = '';
  String tehsil = '';
  String village = '';
  double? latitude;
  double? longitude;

  bool get hasLocation => latitude != null && longitude != null;

  String get fullLocation {
    final parts = [village, tehsil, district]
        .where((e) => e.trim().isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'Select Location';
    return parts.join(', ');
  }

  // Load saved location on app start
  Future<void> loadSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    district = prefs.getString('loc_district') ?? '';
    tehsil = prefs.getString('loc_tehsil') ?? '';
    village = prefs.getString('loc_village') ?? '';
    final lat = prefs.getDouble('loc_lat');
    final lng = prefs.getDouble('loc_lng');
    if (lat != null && lng != null) {
      latitude = lat;
      longitude = lng;
    }
    notifyListeners();
  }

  void updateLocation({
    String district = '',
    String tehsil = '',
    String village = '',
    double? latitude,
    double? longitude,
  }) {
    this.district = district;
    this.tehsil = tehsil;
    this.village = village;
    this.latitude = latitude;
    this.longitude = longitude;
    notifyListeners();
    _saveLocation();
  }

  Future<void> _saveLocation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('loc_district', district);
    await prefs.setString('loc_tehsil', tehsil);
    await prefs.setString('loc_village', village);
    if (latitude != null) await prefs.setDouble('loc_lat', latitude!);
    if (longitude != null) await prefs.setDouble('loc_lng', longitude!);
  }

  void clearLocation() {
    district = '';
    tehsil = '';
    village = '';
    latitude = null;
    longitude = null;
    notifyListeners();
    _clearSaved();
  }

  Future<void> _clearSaved() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('loc_district');
    await prefs.remove('loc_tehsil');
    await prefs.remove('loc_village');
    await prefs.remove('loc_lat');
    await prefs.remove('loc_lng');
  }
}
