# SIMPEG-KPI Mobile (Flutter)

Aplikasi mobile untuk pegawai KPI Pusat — presensi (GPS + selfie), pengajuan cuti bertahap (atasan → HR), riwayat pendidikan/diklat, dan pengajuan perubahan data. Terhubung ke backend Laravel `simpeg-kpi-web` yang sudah dibuat sebelumnya lewat API Sanctum.

## Fitur

- **Login** — autentikasi token (Sanctum), sesi tersimpan otomatis.
- **Dashboard** — status presensi hari ini, saldo cuti, total JP diklat, grafik kehadiran bulan ini, cuti terbaru.
- **Absensi** — presensi masuk (GPS + selfie kamera depan, validasi radius kantor) dan presensi pulang, riwayat presensi bulanan.
- **Cuti & Izin** (gaya kartu saldo + timeline persetujuan) — kartu saldo cuti dengan progress bar, filter status, form pengajuan dengan date range picker & hitung hari kerja otomatis, detail pengajuan dengan timeline visual (Diajukan → Atasan → HR).
- **Pendidikan & Diklat** — riwayat pendidikan dan pelatihan (read-only, dikelola Admin di web), rekap total JP tahun berjalan.
- **Profil** — info pegawai, ajukan perubahan data (No. HP/Alamat/Email) yang perlu disetujui Admin, riwayat pengajuan, logout.

Desain: Material 3, font Plus Jakarta Sans, palet warna identitas KPI Pusat (merah `#C1272D`, emas `#C9A227`, krem `#FAF6EF`), animasi halus (fade/slide masuk berjenjang, shimmer loading, transisi halaman, progress bar animasi).

## Prasyarat

- Flutter SDK >= 3.24 (Dart >= 3.5) — `flutter --version` untuk cek
- Android Studio / Xcode untuk emulator atau device fisik
- Backend `simpeg-kpi-web` sudah jalan (lihat README backend) dengan `composer install` sudah mencakup `laravel/sanctum`

## Instalasi

Proyek ini berisi kode `lib/` dan `pubspec.yaml` saja (tanpa folder `android/` `ios/` bawaan `flutter create`, supaya ringan dan tidak terikat versi toolchain tertentu). Langkah setup:

```bash
# 1. Masuk ke folder proyek ini
cd simpeg_kpi_mobile

# 2. Generate boilerplate platform (android/ios/dst) — aman dijalankan
#    di folder yang sudah berisi pubspec.yaml & lib/, tidak akan menimpa keduanya
flutter create --platforms=android,ios .

# 3. Install dependencies
flutter pub get

# 4. Jalankan
flutter run
```

### Menyambungkan ke backend

Secara default aplikasi memanggil `http://10.0.2.2:8000/api` (alias `localhost` dari emulator Android ke mesin host). Sesuaikan sesuai kondisi:

```bash
# Emulator Android, Laravel jalan di localhost:8000 (default) — tidak perlu diubah

# Device fisik / emulator iOS, cari IP LAN laptop (ipconfig / ifconfig), lalu:
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000/api

# Build produksi ke server sungguhan:
flutter build apk --dart-define=API_BASE_URL=https://simpeg.kpi.go.id/api
```

### Wajib: tambahkan izin Kamera & Lokasi

Setelah `flutter create --platforms=android,ios .` membuat folder `android/` dan `ios/`, tambahkan izin berikut (dibutuhkan untuk fitur presensi selfie + GPS):

**Android** — edit `android/app/src/main/AndroidManifest.xml`, tambahkan di dalam tag `<manifest>` (sebelum `<application>`):

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

Pastikan juga `minSdkVersion` di `android/app/build.gradle` minimal **21** (geolocator & image_picker mensyaratkan ini).

**iOS** — edit `ios/Runner/Info.plist`, tambahkan sebelum `</dict>` penutup terakhir:

```xml
<key>NSCameraUsageDescription</key>
<string>Aplikasi memerlukan kamera untuk foto selfie saat presensi.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Aplikasi memerlukan lokasi untuk memvalidasi presensi berada di area kantor.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Aplikasi memerlukan akses galeri untuk melampirkan dokumen pendukung cuti.</string>
```

Tanpa langkah ini, fitur presensi (kamera/GPS) akan menampilkan error izin ditolak saat dicoba, bukan error kode.

## Akun untuk Uji Coba

Pakai akun `pegawai` dari seeder backend:

| Email | Password |
|---|---|
| pegawai@kpi.go.id | password |

> Catatan: seeder awal hanya menautkan satu user dengan role `pegawai` (`Siti Aminah`) ke data induk pegawai. Untuk pegawai lain di seeder, Admin perlu membuatkan akun login (`role: pegawai`) yang ditautkan ke `pegawai_id` masing-masing lewat Tinker/database langsung, karena form "Tambah Pegawai" di web saat ini belum punya opsi generate akun login otomatis — bisa ditambahkan menyusul kalau diperlukan.

## Struktur Proyek

```
lib/
  core/
    api/        — Dio client, penyimpanan token, exception handling
    models/     — model data (Pegawai, Cuti, Absensi, dst.)
    theme/      — warna & tema Material 3
    utils/      — formatter tanggal & label
    widgets/    — komponen bersama (badge status, empty state, shimmer, animasi masuk)
  features/
    splash/     — splash screen animasi
    auth/       — login + AuthProvider (state sesi)
    home/       — shell dengan bottom navigation animasi
    dashboard/  — ringkasan & grafik
    absensi/    — presensi GPS+selfie & riwayat
    cuti/       — saldo, daftar, form pengajuan, detail+timeline
    riwayat/    — riwayat pendidikan & pelatihan
    profile/    — profil, pengajuan perubahan data, logout
```

State management pakai **Provider** (`ChangeNotifier` per fitur, dibuat lokal di tiap screen) — ringan dan cukup untuk skala aplikasi ini.

## Catatan Pengembangan Lanjutan

- Modul **Absensi & Cuti untuk role `atasan`** (approval cepat dari HP) belum dibuat di aplikasi ini — saat ini aplikasi difokuskan untuk role `pegawai` sesuai cakupan PRD. Endpoint API untuk atasan bisa ditambahkan kalau nanti dibutuhkan.
- Notifikasi push (misal saat cuti disetujui) belum diimplementasikan — bisa ditambahkan dengan Firebase Cloud Messaging di iterasi berikutnya.
- Upload lampiran cuti saat ini pakai `image_picker` (galeri) untuk kesederhanaan; kalau butuh upload PDF juga, bisa ganti ke package `file_picker`.
