import 'package:flutter/material.dart';

class AirQuality {
  final String cityName;
  final int aqi;
  final String dominantPollutant;
  final double? pm25;
  final double? pm10;
  final double? o3;
  final double? no2;
  final double? so2;
  final double? co;
  final double? temperature;
  final double? humidity;
  final double? wind;
  final String timeString;

  AirQuality({
    required this.cityName,
    required this.aqi,
    required this.dominantPollutant,
    this.pm25,
    this.pm10,
    this.o3,
    this.no2,
    this.so2,
    this.co,
    this.temperature,
    this.humidity,
    this.wind,
    required this.timeString,
  });

  factory AirQuality.fromWaqiJson(Map<String, dynamic> data, String fallbackCity) {
    final cityData = data['city'] as Map<String, dynamic>?;
    final String city = (cityData != null && cityData['name'] != null && (cityData['name'] as String).isNotEmpty)
        ? cityData['name'] as String
        : fallbackCity;

    final int aqiVal = (data['aqi'] is int)
        ? data['aqi'] as int
        : int.tryParse(data['aqi']?.toString() ?? '0') ?? 0;

    final iaqi = data['iaqi'] as Map<String, dynamic>? ?? {};

    double? parseVal(dynamic field) {
      if (field == null) return null;
      if (field is Map && field['v'] != null) {
        return (field['v'] is num) ? (field['v'] as num).toDouble() : double.tryParse(field['v'].toString());
      }
      if (field is num) return field.toDouble();
      return double.tryParse(field.toString());
    }

    final timeData = data['time'] as Map<String, dynamic>?;
    final timeStr = timeData?['s']?.toString() ?? DateTime.now().toLocal().toString().substring(0, 16);

    return AirQuality(
      cityName: city,
      aqi: aqiVal,
      dominantPollutant: _formatPollutant(data['dominentpol']?.toString()),
      pm25: parseVal(iaqi['pm25']),
      pm10: parseVal(iaqi['pm10']),
      o3: parseVal(iaqi['o3']),
      no2: parseVal(iaqi['no2']),
      so2: parseVal(iaqi['so2']),
      co: parseVal(iaqi['co']),
      temperature: parseVal(iaqi['t']),
      humidity: parseVal(iaqi['h']),
      wind: parseVal(iaqi['w']),
      timeString: timeStr,
    );
  }

  static String _formatPollutant(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'pm25':
        return 'PM2.5';
      case 'pm10':
        return 'PM10';
      case 'o3':
        return 'O₃';
      case 'no2':
        return 'NO₂';
      case 'so2':
        return 'SO₂';
      case 'co':
        return 'CO';
      default:
        return raw?.toUpperCase() ?? 'PM2.5';
    }
  }

  // Klasifikasi berdasarkan standar US AQI / EPA
  String get status {
    if (aqi <= 50) return 'Baik (Good)';
    if (aqi <= 100) return 'Sedang (Moderate)';
    if (aqi <= 150) return 'Tidak Sehat untuk Sensitif';
    if (aqi <= 200) return 'Tidak Sehat (Unhealthy)';
    if (aqi <= 300) return 'Sangat Tidak Sehat';
    return 'Berbahaya (Hazardous)';
  }

  Color get color {
    if (aqi <= 50) return const Color(0xFF00E400); // Hijau
    if (aqi <= 100) return const Color(0xFFFF7E00); // Kuning / Kuning Emas
    if (aqi <= 150) return const Color(0xFFFF5200); // Oranye
    if (aqi <= 200) return const Color(0xFFFF0000); // Merah
    if (aqi <= 300) return const Color(0xFF8F3F97); // Ungu
    return const Color(0xFF7E0023); // Coklat Marun
  }

  Color get textColor {
    if (aqi <= 100) return const Color(0xFF1E293B);
    return Colors.white;
  }

  String get recommendation {
    if (aqi <= 50) {
      return 'Kualitas udara sangat baik. Sangat aman dan ideal untuk beraktivitas di luar ruangan.';
    } else if (aqi <= 100) {
      return 'Kualitas udara dapat diterima. Orang yang sangat sensitif disarankan mengurangi aktivitas berat di luar ruangan.';
    } else if (aqi <= 150) {
      return 'Penderita asma, anak-anak, dan lansia sebaiknya mengurangi aktivitas di luar ruangan yang berkepanjangan.';
    } else if (aqi <= 200) {
      return 'Setiap orang mulai merasakan efek buruk kesehatan. Dianjurkan memakai masker dan menyalakan air purifier.';
    } else if (aqi <= 300) {
      return 'Peringatan darurat kesehatan. Seluruh populasi disarankan menghindari aktivitas di luar ruangan.';
    } else {
      return 'Bahaya tingkat tinggi! Tetap berada di dalam ruangan, tutup pintu dan jendela rapat-rapat.';
    }
  }

  IconData get icon {
    if (aqi <= 50) return Icons.sentiment_very_satisfied_rounded;
    if (aqi <= 100) return Icons.sentiment_satisfied_rounded;
    if (aqi <= 150) return Icons.sentiment_neutral_rounded;
    if (aqi <= 200) return Icons.sentiment_dissatisfied_rounded;
    if (aqi <= 300) return Icons.sentiment_very_dissatisfied_rounded;
    return Icons.warning_amber_rounded;
  }
}
