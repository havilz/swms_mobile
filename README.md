# SWMS Mobile

Aplikasi Flutter untuk pengguna Smart Waste Management System (SWMS). Aplikasi ini digunakan untuk membuat, melihat, dan memantau laporan sampah melalui perangkat mobile.

## Fitur

- Onboarding pengguna.
- Registrasi, login, logout, dan penyimpanan sesi.
- Dashboard daftar laporan pengguna.
- Pembuatan laporan sampah dengan judul dan deskripsi.
- Penentuan lokasi menggunakan GPS atau pemilihan titik pada peta.
- Penambahan foto sebagai bukti laporan.
- Detail laporan, status laporan, koordinat, dan catatan admin.
- Filter status dan pagination daftar laporan.
- Profil pengguna.

## Teknologi

- Flutter
- Dart 3.13 atau lebih baru
- GetX untuk state management dan routing
- Dio untuk komunikasi HTTP
- `flutter_dotenv` untuk konfigurasi environment
- `flutter_secure_storage` untuk penyimpanan token
- Google Maps Flutter untuk peta
- Geolocator dan Geocoding untuk lokasi
- Image Picker untuk foto laporan

## Persyaratan

Pastikan perangkat development memiliki:

- Flutter SDK yang mendukung Dart 3.13+
- Android Studio dan Android SDK untuk Android
- Xcode untuk iOS dan macOS
- CocoaPods untuk dependency iOS
- Browser yang mendukung Flutter Web jika menjalankan versi web

Periksa instalasi Flutter dengan:

```bash
flutter doctor
```

## Instalasi

Clone project, masuk ke folder aplikasi, lalu install dependency:

```bash
flutter pub get
```

## Konfigurasi Environment

Buat file `.env` berdasarkan `.env.example`:

```env
PRODUCTION_API_URL=https://api.example.com/api/v1
GOOGLE_MAPS_API_KEY=your-google-maps-api-key
```

`PRODUCTION_API_URL` wajib berupa URL HTTP atau HTTPS yang diakhiri dengan `/api/v1`.

`GOOGLE_MAPS_API_KEY` digunakan untuk menampilkan peta. Konfigurasikan API key sesuai platform yang digunakan dan batasi key berdasarkan aplikasi atau domain.

Jangan memasukkan credential atau API key ke source code maupun repository.

## Menjalankan Aplikasi

Tampilkan device yang tersedia:

```bash
flutter devices
```

Jalankan aplikasi pada device atau emulator:

```bash
flutter run
```

Jalankan pada device tertentu:

```bash
flutter run -d <device-id>
```

Untuk menjalankan mode release:

```bash
flutter run --release
```

## Struktur Aplikasi

```text
lib/
├── app/
├── core/
│   ├── config/
│   ├── network/
│   └── storage/
├── features/
│   ├── auth/
│   └── reports/
└── shared/
    ├── theme/
    └── ui/
```

- `app/` berisi konfigurasi aplikasi, session gate, dan routing.
- `core/` berisi konfigurasi, client API, exception handling, dan penyimpanan token.
- `features/auth/` berisi autentikasi dan profil pengguna.
- `features/reports/` berisi data, state, dan halaman laporan.
- `shared/` berisi theme dan komponen UI yang digunakan bersama.

## Alur Pengguna

1. Pengguna membuka aplikasi dan menyelesaikan onboarding.
2. Pengguna masuk atau membuat akun baru.
3. Pengguna melihat laporan pada dashboard.
4. Pengguna membuat laporan dengan lokasi, deskripsi, dan foto jika diperlukan.
5. Pengguna memantau perubahan status dan catatan admin pada detail laporan.

## Pengujian dan Pemeriksaan Kualitas

Jalankan static analysis:

```bash
flutter analyze
```

Jalankan seluruh test:

```bash
flutter test
```

Jalankan test dengan coverage:

```bash
flutter test --coverage
```

Format kode Dart:

```bash
dart format lib test
```

## Build

Build APK Android:

```bash
flutter build apk
```

Build aplikasi web:

```bash
flutter build web
```

Build aplikasi iOS dari macOS:

```bash
flutter build ios
```

## Catatan Platform (self build)

- Izin lokasi diperlukan untuk mengambil koordinat melalui GPS.
- Izin kamera atau galeri diperlukan untuk memilih foto laporan.
- Google Maps API key harus tersedia pada konfigurasi platform yang digunakan.
- Pastikan endpoint API dapat diakses dari device atau emulator.
- Untuk Android emulator, `localhost` mengarah ke emulator, bukan ke komputer host.
