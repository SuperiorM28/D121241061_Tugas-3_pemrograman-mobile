import 'package:flutter/material.dart';
import '../services/storage_service.dart';

/// Controller global untuk mode tema (terang / gelap).
/// Nilainya disimpan di SharedPreferences agar tetap diingat.
class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.light);

  bool get isDark => value == ThemeMode.dark;

  Future<void> load() async {
    final dark = await StorageService.getDarkMode();
    value = dark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggle() async {
    value = isDark ? ThemeMode.light : ThemeMode.dark;
    await StorageService.saveDarkMode(isDark);
  }
}

final themeController = ThemeController();
