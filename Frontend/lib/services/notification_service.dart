import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/config/app_config.dart';
import '../core/location_provider.dart';

/// NotificationService — generates REAL notifications based on:
/// 1. Live weather data (heat wave, rain alerts)
/// 2. Mandi price changes
/// 3. Government scheme updates
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _db = FirebaseFirestore.instance;

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Refresh all notifications for current user.
  /// Call this on app startup and when user opens notification screen.
  Future<void> refreshNotifications(LocationProvider location) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Run all checks in parallel
    await Future.wait([
      _checkWeatherAlerts(user.uid, location),
      _checkMandiPrices(user.uid, location),
      _ensureSchemeNotifications(user.uid),
    ]);
  }

  /// Get all notifications for current user, ordered newest first.
  Stream<List<Map<String, dynamic>>> notificationsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = Map<String, dynamic>.from(d.data());
              data['id'] = d.id;
              if (data['timestamp'] is Timestamp) {
                data['timestamp'] = (data['timestamp'] as Timestamp).toDate();
              }
              return data;
            }).toList());
  }

  /// Mark a notification as read.
  Future<void> markRead(String notificationId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _db
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .doc(notificationId)
        .update({'read': true});
  }

  /// Mark all notifications as read.
  Future<void> markAllRead() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final snap = await _db
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .where('read', isEqualTo: false)
        .get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }

  /// Delete a notification.
  Future<void> deleteNotification(String notificationId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _db
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  Future<void> _checkWeatherAlerts(
      String uid, LocationProvider location) async {
    try {
      if (!location.hasLocation) return;

      final url =
          '${AppConfig.weatherApiBase}/api/weather'
          '?district=${Uri.encodeComponent(location.district)}'
          '&tehsil=${Uri.encodeComponent(location.tehsil)}'
          '&village=${Uri.encodeComponent(location.village)}';

      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return;

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final current = data['current'] as Map<String, dynamic>? ?? {};
      final temp = (current['temperature'] as num?)?.toDouble() ?? 0;
      final rain = (current['rain'] as num?)?.toDouble() ?? 0;
      final wind = (current['wind'] as num?)?.toDouble() ?? 0;
      final humidity = (current['humidity'] as num?)?.toDouble() ?? 0;

      // Heat wave alert
      if (temp >= 42) {
        await _saveNotification(uid, {
          'title': '🌡️ भीषण गर्मी चेतावनी',
          'message': 'आपके क्षेत्र ${location.village} में तापमान ${temp.toStringAsFixed(0)}°C है। '
              'दोपहर 12-4 बजे खेत में न जाएं, पशुओं को छाया में रखें।',
          'type': 'Weather',
          'priority': 'high',
          'icon': 'thermostat',
          'color': 0xFFD32F2F,
        });
      } else if (temp >= 38) {
        await _saveNotification(uid, {
          'title': '☀️ अत्यधिक गर्मी',
          'message': '${location.village} में तापमान ${temp.toStringAsFixed(0)}°C। '
              'फसलों की सिंचाई सुबह या शाम करें।',
          'type': 'Weather',
          'priority': 'medium',
          'icon': 'wb_sunny',
          'color': 0xFFF57C00,
        });
      }

      // Heavy rain alert
      if (rain >= 10) {
        await _saveNotification(uid, {
          'title': '🌧️ भारी बारिश की चेतावनी',
          'message': '${location.village} में ${rain.toStringAsFixed(1)} mm बारिश हो रही है। '
              'फसल कटाई टालें, जल निकासी सुनिश्चित करें।',
          'type': 'Weather',
          'priority': 'high',
          'icon': 'water_drop',
          'color': 0xFF1565C0,
        });
      }

      // Strong wind alert
      if (wind >= 40) {
        await _saveNotification(uid, {
          'title': '💨 तेज हवा की चेतावनी',
          'message': '${location.village} में ${wind.toStringAsFixed(0)} km/h की हवा चल रही है। '
              'नाजुक फसलों को सहारा दें।',
          'type': 'Weather',
          'priority': 'medium',
          'icon': 'air',
          'color': 0xFF00838F,
        });
      }

      // Low humidity — irrigation needed
      if (humidity < 30 && temp > 35) {
        await _saveNotification(uid, {
          'title': '💧 सिंचाई की जरूरत',
          'message': 'नमी ${humidity.toStringAsFixed(0)}% और तापमान ${temp.toStringAsFixed(0)}°C — '
              'फसलों को आज सिंचाई करें।',
          'type': 'Weather',
          'priority': 'low',
          'icon': 'opacity',
          'color': 0xFF2E7D32,
        });
      }
    } catch (_) {
      // Weather check failed silently
    }
  }

  Future<void> _checkMandiPrices(
      String uid, LocationProvider location) async {
    try {
      if (!location.hasLocation) return;

      // Get districts list
      final distRes = await http
          .get(Uri.parse('${AppConfig.cropPriceApiBase}/api/mandi/districts'))
          .timeout(const Duration(seconds: 8));
      if (distRes.statusCode != 200) return;

      final districts = List<String>.from(
          (jsonDecode(distRes.body) as Map)['districts'] ?? []);

      // Find matching district
      final matchDist = districts.firstWhere(
        (d) => d.toLowerCase().contains(location.district.toLowerCase()) ||
            location.district.toLowerCase().contains(d.toLowerCase()),
        orElse: () => districts.isNotEmpty ? districts.first : '',
      );
      if (matchDist.isEmpty) return;

      // Get mandis
      final mandiRes = await http
          .get(Uri.parse(
              '${AppConfig.cropPriceApiBase}/api/mandi/mandis?district=${Uri.encodeComponent(matchDist)}'))
          .timeout(const Duration(seconds: 8));
      if (mandiRes.statusCode != 200) return;

      final mandis = List<String>.from(
          (jsonDecode(mandiRes.body) as Map)['mandis'] ?? []);
      if (mandis.isEmpty) return;

      // Get crops for first mandi
      final cropRes = await http
          .get(Uri.parse(
              '${AppConfig.cropPriceApiBase}/api/mandi/crops?district=${Uri.encodeComponent(matchDist)}&mandi=${Uri.encodeComponent(mandis.first)}'))
          .timeout(const Duration(seconds: 8));
      if (cropRes.statusCode != 200) return;

      final crops = List<String>.from(
          (jsonDecode(cropRes.body) as Map)['crops'] ?? []);
      if (crops.isEmpty) return;

      // Get price for first available crop
      final priceRes = await http
          .get(Uri.parse(
              '${AppConfig.cropPriceApiBase}/api/mandi?district=${Uri.encodeComponent(matchDist)}&mandi=${Uri.encodeComponent(mandis.first)}&crop=${Uri.encodeComponent(crops.first)}'))
          .timeout(const Duration(seconds: 8));
      if (priceRes.statusCode != 200) return;

      final priceData = jsonDecode(priceRes.body) as Map<String, dynamic>;
      final avgPrice = priceData['avgPrice'] ?? 0;
      final maxPrice = priceData['maxPrice'] ?? 0;

      await _saveNotification(uid, {
        'title': '💰 ${crops.first} — आज का भाव',
        'message': '${mandis.first} मंडी, $matchDist: '
            'औसत ₹$avgPrice — अधिकतम ₹$maxPrice प्रति क्विंटल।',
        'type': 'Prices',
        'priority': 'low',
        'icon': 'trending_up',
        'color': 0xFF1B5E20,
      });
    } catch (_) {
      // Price check failed silently
    }
  }

  Future<void> _ensureSchemeNotifications(String uid) async {
    // Check if scheme notifications exist for this month
    final monthKey = DateTime.now().toIso8601String().substring(0, 7);
    final existing = await _db
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .where('type', isEqualTo: 'Schemes')
        .where('monthKey', isEqualTo: monthKey)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) return; // Already sent this month

    final schemes = [
      {
        'title': '📋 PM-KISAN किस्त — जांचें',
        'message': 'PM-KISAN की अगली किस्त आने वाली है। '
            'pmkisan.gov.in पर अपना स्टेटस जांचें।',
        'color': 0xFF1565C0,
      },
      {
        'title': '🌾 फसल बीमा आवेदन खुले',
        'message': 'खरीफ 2025 के लिए PMFBY आवेदन शुरू। '
            'अंतिम तारीख से पहले अपनी फसल का बीमा कराएं।',
        'color': 0xFF6A1B9A,
      },
      {
        'title': '💧 सिंचाई अनुदान उपलब्ध',
        'message': 'Pradhan Mantri Krishi Sinchayee Yojana के तहत '
            'ड्रिप-स्प्रिंकलर पर 90% तक सब्सिडी।',
        'color': 0xFF00695C,
      },
    ];

    for (final s in schemes) {
      await _saveNotification(uid, {
        ...s,
        'type': 'Schemes',
        'priority': 'low',
        'icon': 'description',
        'monthKey': monthKey,
      });
    }
  }

  Future<void> _saveNotification(
      String uid, Map<String, dynamic> data) async {
    // Avoid duplicate notifications (same title within 24 hours)
    final since = Timestamp.fromDate(
        DateTime.now().subtract(const Duration(hours: 24)));
    final existing = await _db
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .where('title', isEqualTo: data['title'])
        .where('timestamp', isGreaterThan: since)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) return; // Already exists

    await _db
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .add({
      ...data,
      'read': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
