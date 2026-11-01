import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/air_quality.dart';
import '../models/city_suggestion.dart';
import 'storage_service.dart';

class ApiService {
  // Token default WAQI (bisa diisi dengan token user atau diatur lewat pengaturan aplikasi)
  static const String defaultWaqiToken = 'demo';

  static const Duration _timeout = Duration(seconds: 8);

  /// Mengambil token WAQI pribadi jika ada. Mengembalikan null jika masih 'demo'.
  /// CATATAN: token 'demo' dari WAQI SELALU mengembalikan data Shanghai
  /// untuk kota apa pun, jadi WAQI hanya dipakai bila user memasang token pribadi.
  static Future<String?> _getRealToken() async {
    final customToken = await StorageService.getCustomToken();
    if (customToken == null || customToken.isEmpty || customToken == defaultWaqiToken) {
      return null;
    }
    return customToken;
  }

  // ---------------------------------------------------------------------------
  // AUTOCOMPLETE: Saran kota saat user mengetik
  // ---------------------------------------------------------------------------
  static Future<List<CitySuggestion>> searchCities(String query) async {
    final q = query.trim();
    if (q.length < 2) return [];

    final url = Uri.parse(
        'https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(q)}&count=6&language=id&format=json');
    final res = await http.get(url).timeout(_timeout);

    if (res.statusCode != 200) return [];

    final json = jsonDecode(res.body);
    final results = json['results'] as List<dynamic>?;
    if (results == null) return [];

    return results
        .map((e) => CitySuggestion.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ---------------------------------------------------------------------------
  // AQI berdasarkan NAMA KOTA (dipakai saat user menekan Enter / chip riwayat)
  // ---------------------------------------------------------------------------
  static Future<AirQuality> fetchAirQuality(String city) async {
    final cleanCity = city.trim();
    if (cleanCity.isEmpty) {
      throw Exception('Nama kota tidak boleh kosong');
    }

    // 1. Coba WAQI REST API (jika ada token pribadi)
    final token = await _getRealToken();
    if (token != null) {
      final result = await _tryWaqi(
        'https://api.waqi.info/feed/${Uri.encodeComponent(cleanCity)}/?token=$token',
        cleanCity,
      );
      if (result != null) return result;
    }

    // 2. Open-Meteo: cari koordinat kota lalu ambil data AQI
    final suggestions = await searchCities(cleanCity);
    if (suggestions.isEmpty) {
      throw Exception('Kota "$cleanCity" tidak ditemukan. Periksa kembali penulisan nama kota.');
    }
    final loc = suggestions.first;
    return _fetchOpenMeteoByCoords(loc.latitude, loc.longitude, loc.displayName);
  }

  // ---------------------------------------------------------------------------
  // AQI berdasarkan KOORDINAT (dipakai saat user memilih saran autocomplete)
  // ---------------------------------------------------------------------------
  static Future<AirQuality> fetchAirQualityByLocation(CitySuggestion loc) async {
    final token = await _getRealToken();
    if (token != null) {
      final result = await _tryWaqi(
        'https://api.waqi.info/feed/geo:${loc.latitude};${loc.longitude}/?token=$token',
        loc.displayName,
      );
      if (result != null) return result;
    }
    return _fetchOpenMeteoByCoords(loc.latitude, loc.longitude, loc.displayName);
  }

  // ---------------------------------------------------------------------------
  // Helper
  // ---------------------------------------------------------------------------
  static Future<AirQuality?> _tryWaqi(String url, String fallbackName) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(_timeout);
      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        if (json['status'] == 'ok' && json['data'] != null) {
          return AirQuality.fromWaqiJson(json['data'], fallbackName);
        }
      }
    } catch (_) {
      // Timeout / error koneksi WAQI -> lanjut ke Open-Meteo
    }
    return null;
  }

  static Future<AirQuality> _fetchOpenMeteoByCoords(
      double lat, double lon, String cityName) async {
    final aqiUrl = Uri.parse(
        'https://air-quality-api.open-meteo.com/v1/air-quality?latitude=$lat&longitude=$lon&current=us_aqi,pm10,pm2_5,carbon_monoxide,nitrogen_dioxide,sulphur_dioxide,ozone');
    final aqiRes = await http.get(aqiUrl).timeout(_timeout);

    if (aqiRes.statusCode != 200) {
      throw Exception('Gagal mengambil data kualitas udara (HTTP ${aqiRes.statusCode})');
    }

    final aqiJson = jsonDecode(aqiRes.body);
    final current = aqiJson['current'] as Map<String, dynamic>?;

    if (current == null) {
      throw Exception('Data kualitas udara tidak tersedia untuk kota ini saat ini.');
    }

    final int usAqi = (current['us_aqi'] is num) ? (current['us_aqi'] as num).toInt() : 50;

    double? toDouble(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString());
    }

    final String timeIso = current['time']?.toString() ?? DateTime.now().toIso8601String();
    final String formattedTime = timeIso.replaceFirst('T', ' ');

    return AirQuality(
      cityName: cityName,
      aqi: usAqi,
      dominantPollutant: 'PM2.5',
      pm25: toDouble(current['pm2_5']),
      pm10: toDouble(current['pm10']),
      co: toDouble(current['carbon_monoxide']),
      no2: toDouble(current['nitrogen_dioxide']),
      so2: toDouble(current['sulphur_dioxide']),
      o3: toDouble(current['ozone']),
      timeString: formattedTime,
    );
  }
}
