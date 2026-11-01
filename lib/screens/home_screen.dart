import 'dart:async';
import 'package:flutter/material.dart';
import '../models/air_quality.dart';
import '../models/city_suggestion.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../widgets/aqi_card.dart';
import '../widgets/pollutant_grid.dart';
import '../widgets/health_advice_card.dart';
import '../widgets/loading_state.dart';
import '../widgets/error_state.dart';
import '../widgets/city_suggestion_list.dart';
import '../widgets/search_history_dropdown.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late Future<AirQuality> _airQualityFuture;
  String _currentCity = 'Jakarta';
  List<String> _history = [];
  bool _isInit = false;

  // State untuk saran kota (autocomplete) & riwayat
  Timer? _debounceTimer;
  List<CitySuggestion> _suggestions = [];
  bool _isSearchingSuggestions = false;
  bool _noSuggestions = false;
  String _searchQuery = '';
  bool _showSearchDropdown = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus) {
        setState(() {
          _showSearchDropdown = true;
        });
      }
    });
    _loadInitialCityAndData();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // 1. Memuat kota terakhir yang tersimpan di SharedPreferences & inisialisasi Future
  Future<void> _loadInitialCityAndData() async {
    final lastCity = await StorageService.getLastCity();
    final historyList = await StorageService.getSearchHistory();

    setState(() {
      _currentCity = lastCity;
      _history = historyList;
      _airQualityFuture = ApiService.fetchAirQuality(_currentCity);
      _isInit = true;
    });
  }

  // Handler saat user mengetik di search bar (dengan debounce 280ms)
  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    final q = value.trim();
    setState(() {
      _searchQuery = q;
      _showSearchDropdown = true;
    });

    if (q.length < 2) {
      setState(() {
        _suggestions = [];
        _isSearchingSuggestions = false;
        _noSuggestions = false;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 280), () async {
      setState(() {
        _isSearchingSuggestions = true;
        _noSuggestions = false;
      });

      try {
        final results = await ApiService.searchCities(q);
        if (!mounted) return;
        // Pastikan input belum berubah saat response tiba
        if (_searchController.text.trim() != q) return;
        setState(() {
          _suggestions = results;
          _isSearchingSuggestions = false;
          _noSuggestions = results.isEmpty;
        });
      } catch (_) {
        if (mounted) {
          setState(() {
            _isSearchingSuggestions = false;
            _noSuggestions = true;
          });
        }
      }
    });
  }

  // Handler saat user memilih salah satu saran kota dari daftar tebakan
  void _selectSuggestion(CitySuggestion suggestion) {
    _debounceTimer?.cancel();
    _searchFocusNode.unfocus();
    _searchController.clear();

    setState(() {
      _showSearchDropdown = false;
      _suggestions = [];
      _searchQuery = '';
      _isSearchingSuggestions = false;
      _noSuggestions = false;
      _currentCity = suggestion.displayName;
      _airQualityFuture = ApiService.fetchAirQualityByLocation(suggestion);
    });

    StorageService.saveLastCity(suggestion.name).then((_) {
      _loadHistoryOnly();
    });
  }

  // 2. Fungsi pencarian kota baru manual (Enter / tombol panah)
  void _searchCity(String city) {
    final trimmed = city.trim();
    if (trimmed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ketikkan nama kota terlebih dahulu'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    _debounceTimer?.cancel();
    _searchFocusNode.unfocus();
    _searchController.clear();

    setState(() {
      _showSearchDropdown = false;
      _suggestions = [];
      _searchQuery = '';
      _isSearchingSuggestions = false;
      _noSuggestions = false;
      _currentCity = trimmed;
      // Memperbarui FutureBuilder dengan request baru
      _airQualityFuture = ApiService.fetchAirQuality(_currentCity);
    });

    // Simpan ke SharedPreferences
    StorageService.saveLastCity(trimmed).then((_) {
      _loadHistoryOnly();
    });
  }

  Future<void> _loadHistoryOnly() async {
    final historyList = await StorageService.getSearchHistory();
    setState(() {
      _history = historyList;
    });
  }

  void _deleteHistoryItem(String city) async {
    // 1. Langsung hapus dari state agar item segera lenyap dari layar
    setState(() {
      _history.removeWhere((item) => item.toLowerCase() == city.toLowerCase());
      if (_history.isEmpty) {
        _showSearchDropdown = false;
      }
    });
    // 2. Simpan perubahan ke storage
    await StorageService.removeFromSearchHistory(city);
  }

  void _clearAllHistory() async {
    setState(() {
      _history.clear();
      _showSearchDropdown = false;
    });
    await StorageService.clearSearchHistory();
  }

  // 3. Refresh data kota saat ini
  void _refresh() {
    setState(() {
      _airQualityFuture = ApiService.fetchAirQuality(_currentCity);
    });
  }

  // 4. Dialog Pengaturan Token API WAQI
  void _showTokenSettingsDialog() async {
    final currentToken = await StorageService.getCustomToken() ?? '';
    final tokenController = TextEditingController(text: currentToken);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.vpn_key_rounded, color: Colors.blueAccent),
            SizedBox(width: 8),
            Text('Pengaturan API WAQI', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Masukkan token API pribadi Anda dari aqicn.org jika ada. Kosongkan untuk menggunakan mode demo/publik.',
              style: TextStyle(fontSize: 13, color: AppColors.of(ctx).textSecondary),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: tokenController,
              decoration: InputDecoration(
                hintText: 'Contoh: 8a1b2c3d4e5f...',
                labelText: 'WAQI API Token',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(ctx);
              final messenger = ScaffoldMessenger.of(context);
              await StorageService.saveCustomToken(tokenController.text);
              if (!mounted) return;
              navigator.pop();
              _refresh();
              messenger.showSnackBar(
                const SnackBar(content: Text('Pengaturan token API disimpan!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isDark = themeController.isDark;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: c.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.air_rounded,
                color: c.accent,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Air Quality App',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: c.textPrimary,
                    ),
                  ),
                  Text(
                    'Pengecek Kualitas Udara Real-Time',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: c.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: isDark ? 'Mode Terang' : 'Mode Gelap',
            onPressed: () => themeController.toggle(),
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => RotationTransition(
                turns: Tween<double>(begin: 0.75, end: 1).animate(anim),
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                key: ValueKey(isDark),
                color: isDark ? Colors.amber.shade300 : c.textSecondary,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Pengaturan API Key',
            icon: Icon(Icons.settings_outlined, color: c.textSecondary),
            onPressed: _showTokenSettingsDialog,
          ),
          IconButton(
            tooltip: 'Muat Ulang',
            icon: Icon(Icons.refresh_rounded, color: c.textSecondary),
            onPressed: _refresh,
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          _searchFocusNode.unfocus();
          setState(() {
            _showSearchDropdown = false;
          });
        },
        behavior: HitTestBehavior.translucent,
        child: SafeArea(
          child: Column(
            children: [
              // Search Bar & Search History Container
              Container(
                color: c.surface,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Form Pencarian Kota
                    Container(
                      decoration: BoxDecoration(
                        color: c.surfaceAlt,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        onTap: () {
                          setState(() {
                            _showSearchDropdown = true;
                          });
                        },
                        textInputAction: TextInputAction.search,
                        onChanged: _onSearchChanged,
                        onSubmitted: _searchCity,
                        style: TextStyle(color: c.textPrimary),
                        cursorColor: c.accent,
                        decoration: InputDecoration(
                          hintText: 'Cari kota (misal: Jakarta, Makassar, Tokyo)...',
                          hintStyle: TextStyle(fontSize: 14, color: c.textMuted),
                          prefixIcon: Icon(Icons.search_rounded, color: c.textMuted),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_searchQuery.isNotEmpty)
                                IconButton(
                                  icon: Icon(Icons.close_rounded, size: 18, color: c.textMuted),
                                  onPressed: () {
                                    _searchController.clear();
                                    _onSearchChanged('');
                                    setState(() {
                                      _showSearchDropdown = true;
                                    });
                                  },
                                ),
                              IconButton(
                                icon: Icon(Icons.arrow_forward_rounded, color: c.accent),
                                onPressed: () => _searchCity(_searchController.text),
                              ),
                            ],
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),

                    // 1. Dropdown Riwayat Pencarian bergaya Google Search
                    // Tampil saat user klik kolom pencarian tapi belum mengetikkan apa-apa
                    if (_showSearchDropdown && _searchQuery.isEmpty && _history.isNotEmpty)
                      SearchHistoryDropdown(
                        history: _history,
                        onSelect: (city) {
                          _searchCity(city);
                        },
                        onDeleteItem: _deleteHistoryItem,
                        onClearAll: _clearAllHistory,
                      ),

                    // 2. Daftar Tebakan / Saran Kota (Autocomplete)
                    // Tampil saat user mulai mengetik nama kota
                    if (_showSearchDropdown && _searchQuery.isNotEmpty)
                      CitySuggestionList(
                        query: _searchQuery,
                        suggestions: _suggestions,
                        isLoading: _isSearchingSuggestions,
                        noResult: _noSuggestions,
                        onSelected: _selectSuggestion,
                      ),

                  ],
                ),
              ),
              Divider(height: 1, color: c.border),

            // Konten Utama: FutureBuilder Menangani State Loading, Success, dan Error
            Expanded(
              child: !_isInit
                  ? const LoadingStateWidget()
                  : FutureBuilder<AirQuality>(
                      future: _airQualityFuture,
                      builder: (context, snapshot) {
                        // 1. STATE LOADING
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const LoadingStateWidget();
                        }

                        // 2. STATE ERROR
                        if (snapshot.hasError) {
                          final errorMsg = snapshot.error.toString().replaceFirst('Exception: ', '');
                          return RefreshIndicator(
                            onRefresh: () async => _refresh(),
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: ErrorStateWidget(
                                errorMessage: errorMsg,
                                onRetry: _refresh,
                              ),
                            ),
                          );
                        }

                        // 3. STATE SUCCESS
                        if (snapshot.hasData && snapshot.data != null) {
                          final airQuality = snapshot.data!;
                          return RefreshIndicator(
                            onRefresh: () async => _refresh(),
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Kartu AQI Utama
                                  AqiCard(airQuality: airQuality),
                                  const SizedBox(height: 18),

                                  // Rekomendasi Kesehatan
                                  HealthAdviceCard(airQuality: airQuality),
                                  const SizedBox(height: 20),

                                  // Grid Parameter Polutan (PM2.5, PM10, CO, dll.)
                                  PollutantGrid(airQuality: airQuality),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          );
                        }

                        // Fallback jika tidak ada data
                        return const Center(
                          child: Text('Tidak ada data kualitas udara.'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
