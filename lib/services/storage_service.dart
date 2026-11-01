import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyLastCity = 'last_searched_city';
  static const String _keySearchHistory = 'search_history';
  static const String _keyWaqiToken = 'waqi_token';

  // Mendapatkan kota terakhir yang dicari
  static Future<String> getLastCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastCity) ?? 'Jakarta';
  }

  // Menyimpan kota terakhir yang dicari
  static Future<void> saveLastCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastCity, city.trim());
    await addToSearchHistory(city.trim());
  }

  // Mengambil daftar riwayat pencarian
  static Future<List<String>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_keySearchHistory);
    if (history == null || history.isEmpty) {
      return ['Jakarta', 'Makassar', 'Surabaya', 'Bandung'];
    }
    return history;
  }

  // Menambahkan kota ke riwayat pencarian (maksimal 8 kota terakhir, unik)
  static Future<void> addToSearchHistory(String city) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_keySearchHistory) ?? ['Jakarta', 'Makassar', 'Surabaya', 'Bandung'];
    
    // Hapus jika sudah ada agar posisinya pindah ke paling atas
    history.removeWhere((item) => item.toLowerCase() == city.toLowerCase());
    history.insert(0, city);

    if (history.length > 8) {
      history = history.sublist(0, 8);
    }

    await prefs.setStringList(_keySearchHistory, history);
  }

  // Menghapus 1 kota dari riwayat
  static Future<void> removeFromSearchHistory(String city) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_keySearchHistory) ?? [];
    history.removeWhere((item) => item.toLowerCase() == city.toLowerCase());
    await prefs.setStringList(_keySearchHistory, history);
  }

  // Menghapus seluruh riwayat pencarian
  static Future<void> clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySearchHistory);
  }

  // Menyimpan custom WAQI Token (jika user punya token pribadi)
  static Future<String?> getCustomToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyWaqiToken);
  }

  static Future<void> saveCustomToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyWaqiToken, token.trim());
  }

  // Menyimpan preferensi Dark Mode
  static const String _keyDarkMode = 'dark_mode';

  static Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkMode) ?? false;
  }

  static Future<void> saveDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, isDark);
  }
}
