import 'package:flutter/material.dart';

class LocationProvider with ChangeNotifier {
  String district = '';
  String tehsil = '';
  String village = '';
  double? latitude;
  double? longitude;

  // 🔹 Check if any location is selected
  bool get hasLocation =>
      latitude != null && longitude != null;

  // 🔹 Location text for UI (AppBar, cards, etc.)
  String get fullLocation {
    final parts = [village, tehsil, district]
        .where((e) => e.trim().isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return 'Select Location';
    }
    return parts.join(', ');
  }

  // 🔹 Used by BOTH auto-detect & manual dropdown
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
  }

  // 🔹 Optional reset
  void clearLocation() {
    district = '';
    tehsil = '';
    village = '';
    latitude = null;
    longitude = null;
    notifyListeners();
  }
}