/// Model untuk saran kota (autocomplete) dari Open-Meteo Geocoding API.
class CitySuggestion {
  final String name;
  final String? admin1; // Provinsi / negara bagian
  final String? country;
  final String? countryCode;
  final double latitude;
  final double longitude;

  CitySuggestion({
    required this.name,
    this.admin1,
    this.country,
    this.countryCode,
    required this.latitude,
    required this.longitude,
  });

  factory CitySuggestion.fromJson(Map<String, dynamic> json) {
    return CitySuggestion(
      name: json['name']?.toString() ?? '-',
      admin1: json['admin1']?.toString(),
      country: json['country']?.toString(),
      countryCode: json['country_code']?.toString(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  /// Contoh: "Sulawesi Selatan, Indonesia"
  String get subtitle => [admin1, country]
      .where((e) => e != null && e.isNotEmpty)
      .join(', ');

  /// Contoh: "Makassar, Indonesia"
  String get displayName =>
      (country != null && country!.isNotEmpty) ? '$name, $country' : name;

  /// Emoji bendera dari kode negara (ID -> 🇮🇩)
  String get flag {
    final code = countryCode?.toUpperCase();
    if (code == null || code.length != 2) return '🌍';
    return String.fromCharCodes(code.codeUnits.map((c) => c + 127397));
  }
}
