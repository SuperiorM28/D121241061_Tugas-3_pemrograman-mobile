# Air Quality App (Aplikasi Pengecek Kualitas Udara)

Aplikasi mobile berbasis **Flutter** untuk memantau indeks kualitas udara (Air Quality Index / AQI) secara *real-time* di berbagai kota, baik di Indonesia maupun seluruh dunia.

Dibuat untuk memenuhi evaluasi tugas:
**Mata Kuliah: Pemrograman Mobile (Tugas 3)**

---

## 📋 Pemenuhan Kriteria Tugas

| Kriteria | Implementasi di Aplikasi | Lokasi File |
| :--- | :--- | :--- |
| **1. REST API** | Mengambil data kualitas udara dari public API (**WAQI** / World Air Quality Index) dengan fallback otomatis ke **Open-Meteo Air Quality REST API**. | [`lib/services/api_service.dart`](lib/services/api_service.dart) |
| **2. Asynchronous UI** | Menggunakan widget **`FutureBuilder<AirQuality>`** untuk mengelola 3 state UI secara eksplisit: **Loading** (`ConnectionState.waiting`), **Error** (`snapshot.hasError`), dan **Success** (`snapshot.hasData`). | [`lib/screens/home_screen.dart`](lib/screens/home_screen.dart), [`lib/widgets/loading_state.dart`](lib/widgets/loading_state.dart), [`lib/widgets/error_state.dart`](lib/widgets/error_state.dart) |
| **3. Local Storage** | Menggunakan **`shared_preferences`** untuk menyimpan **kota terakhir yang dicari** sehingga otomatis dimuat saat aplikasi dibuka kembali, dilengkapi riwayat pencarian (Search History). | [`lib/services/storage_service.dart`](lib/services/storage_service.dart) |

---

## ✨ Fitur Unggulan

1. **Pencarian Kota Dinamis**: Pengguna dapat mencari kota manapun (misal: *Makassar*, *Jakarta*, *Surabaya*, *Bandung*, *Tokyo*, *London*, dll.).
2. **Indikator AQI Berwarna Otomatis**:
   * 🟢 **0 – 50**: Baik (Good)
   * 🟡 **51 – 100**: Sedang (Moderate)
   * 🟠 **101 – 150**: Tidak Sehat untuk Kelompok Sensitif
   * 🔴 **151 – 200**: Tidak Sehat (Unhealthy)
   * 🟣 **201 – 300**: Sangat Tidak Sehat (Very Unhealthy)
   * 🟤 **300+**: Berbahaya (Hazardous)
3. **Detail Parameter Polutan**: Menampilkan nilai partikel PM2.5, PM10, O3 (Ozon), NO2, SO2, dan CO.
4. **Saran Kesehatan Pintar**: Menampilkan rekomendasi aktivitas luar ruangan, anjuran pemakaian masker, dan ventilasi udara berdasarkan skor AQI.
5. **Riwayat Pencarian (Chips)**: Daftar pencarian sebelumnya tersimpan secara lokal dan dapat langsung ditekan untuk mencari kembali.
6. **Tarik untuk Memperbarui (Pull to Refresh)**: Mendukung gestur swipe down untuk memuat ulang data terbaru.
7. **Pengaturan Token API WAQI**: Tersedia dialog pengaturan untuk memasukkan token pribadi dari [aqicn.org](https://aqicn.org/data-platform/token/).

---

## 📁 Struktur Direktori Project

```text
lib/
├── main.dart                      # Entry point aplikasi & konfigurasi tema
├── models/
│   └── air_quality.dart           # Model data AQI, status warna, dan rekomendasi
├── services/
│   ├── api_service.dart           # Pemanggilan REST API (WAQI & Open-Meteo)
│   └── storage_service.dart       # Penyimpanan lokal SharedPreferences
├── screens/
│   └── home_screen.dart           # Layar utama dengan FutureBuilder
└── widgets/
    ├── aqi_card.dart              # Kartu skor AQI dan indikator visual
    ├── pollutant_grid.dart        # Grid rincian polutan (PM2.5, PM10, dll.)
    ├── health_advice_card.dart    # Rekomendasi kesehatan
    ├── loading_state.dart         # Tampilan saat status Loading
    └── error_state.dart           # Tampilan saat status Error & tombol Retry
```

---

## 🚀 Cara Menjalankan Aplikasi

1. **Pastikan dependencies terpasang**:
   ```bash
   flutter pub get
   ```

2. **Jalankan pada perangkat / emulator**:
   ```bash
   flutter run
   ```