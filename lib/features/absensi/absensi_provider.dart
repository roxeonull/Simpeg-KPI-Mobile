import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import '../../core/models/absensi.dart';
import '../../core/models/jadwal_shift.dart';
import '../../core/services/shift_reminder_service.dart';

class AbsensiProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient.instance;
  final ImagePicker _picker = ImagePicker();

  bool isLoadingToday = true;
  bool isSubmitting = false;
  String? error;

  Absensi? today;
  JadwalShiftItem? shiftHariIni;
  String jamMasukKantor = '08:00';
  String jamPulangKantor = '16:30';

  // Geofencing & Location State
  Position? currentPosition;
  double? distanceToOfficeMeters;
  bool isFetchingLocation = false;

  // Dynamic Office Location & Geofence Radius (Synced from backend Pengaturan)
  double officeLat = -6.167034493339591;
  double officeLng = 106.82246468208389;
  double officeRadiusMeters = 100.0;

  bool get isInsideGeofence =>
      distanceToOfficeMeters != null && distanceToOfficeMeters! <= officeRadiusMeters;

  bool get isWeekendNonShift {
    final now = DateTime.now();
    final isWeekend = now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;
    return isWeekend && shiftHariIni == null;
  }

  List<Absensi> history = [];
  bool isLoadingHistory = true;

  Future<void> updateCurrentLocation() async {
    isFetchingLocation = true;
    notifyListeners();
    try {
      final pos = await _ambilLokasi();
      currentPosition = pos;
      distanceToOfficeMeters = Geolocator.distanceBetween(
        pos.latitude,
        pos.longitude,
        officeLat,
        officeLng,
      );
    } catch (_) {
      // Jika izin lokasi belum diberikan / GPS mati, abaikan secara halus untuk visual awal
    } finally {
      isFetchingLocation = false;
      notifyListeners();
    }
  }

  Future<void> loadToday() async {
    isLoadingToday = true;
    notifyListeners();
    try {
      final res = await _api.request('/absensi/hari-ini');
      today = res.data['data'] != null ? Absensi.fromJson(res.data['data']) : null;
      jamMasukKantor = res.data['jam_masuk_kantor'] ?? '08:00';
      jamPulangKantor = res.data['jam_pulang_kantor'] ?? '16:30';

      if (res.data['office_lat'] != null) {
        officeLat = (res.data['office_lat'] as num).toDouble();
      }
      if (res.data['office_lng'] != null) {
        officeLng = (res.data['office_lng'] as num).toDouble();
      }
      if (res.data['office_radius_meters'] != null) {
        officeRadiusMeters = (res.data['office_radius_meters'] as num).toDouble();
      }

      updateCurrentLocation();

      try {
        final shiftRes = await _api.request('/jadwal-shift/hari-ini');
        if (shiftRes.data['has_shift'] == true && shiftRes.data['data'] != null) {
          shiftHariIni = JadwalShiftItem.fromJson(shiftRes.data['data']);
        } else {
          shiftHariIni = null;
        }
      } catch (_) {
        shiftHariIni = null;
      }

      _syncShiftReminder();
    } catch (_) {
      error = 'Gagal memuat status presensi hari ini.';
    }
    isLoadingToday = false;
    notifyListeners();
  }

  void _syncShiftReminder() {
    final jamMasuk = shiftHariIni?.jamMulai ?? jamMasukKantor;
    final jamKeluar = shiftHariIni?.jamSelesai ?? jamPulangKantor;
    final shiftName = shiftHariIni?.statusShift?.nama ?? shiftHariIni?.shiftLabel;

    ShiftReminderService.instance.syncShiftReminders(
      jamMasuk: jamMasuk,
      jamKeluar: jamKeluar,
      hasAbsenMasuk: today?.jamMasuk != null,
      hasAbsenKeluar: today?.jamKeluar != null,
      shiftName: shiftName,
    );
  }

  Future<void> loadHistory({String? bulan}) async {
    isLoadingHistory = true;
    notifyListeners();
    try {
      final res = await _api.request('/absensi', query: bulan != null ? {'bulan': bulan} : null);
      history = (res.data['data'] as List).map((e) => Absensi.fromJson(e)).toList();
    } catch (_) {
      // Diam-diam gagal, riwayat opsional untuk ditampilkan.
    }
    isLoadingHistory = false;
    notifyListeners();
  }

  /// Alur presensi: ambil lokasi GPS -> ambil selfie -> kirim ke server.
  /// Melempar [ApiException]/String pesan kalau gagal, ditangkap UI.
  Future<void> presensiMasuk() async {
    isSubmitting = true;
    notifyListeners();
    try {
      final position = await _ambilLokasi();
      final foto = await _ambilSelfie();
      if (foto == null) {
        throw ApiException('Foto selfie dibatalkan.');
      }

      // Baca data deteksi GPS dari Position (berjalan transparan di background)
      // position.isMocked: true jika OS melaporkan posisi ini dari mock provider
      // position.accuracy: margin error GPS dalam meter
      final formData = FormData.fromMap({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'foto': await MultipartFile.fromFile(foto.path, filename: 'selfie.jpg'),
        'is_mock_location': position.isMocked ? 1 : 0,  // kirim sebagai int agar form-data kompatibel
        'accuracy': position.accuracy,
      });

      await _api.request('/absensi/masuk', method: 'POST', data: formData);

      await loadToday();
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> presensiKeluar() async {
    isSubmitting = true;
    notifyListeners();
    try {
      final position = await _ambilLokasi();
      await _api.request(
        '/absensi/keluar',
        method: 'POST',
        data: {
          'latitude': position.latitude,
          'longitude': position.longitude,
          // Data deteksi GPS (berjalan transparan, tidak mengubah UX)
          'is_mock_location': position.isMocked ? 1 : 0,
          'accuracy': position.accuracy,
        },
      );
      await loadToday();
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<Position> _ambilLokasi() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw ApiException('Aktifkan layanan lokasi (GPS) terlebih dahulu.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw ApiException('Izin lokasi diperlukan untuk presensi.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw ApiException('Izin lokasi ditolak permanen. Aktifkan lewat pengaturan aplikasi.');
    }

    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    currentPosition = pos;
    distanceToOfficeMeters = Geolocator.distanceBetween(
      pos.latitude,
      pos.longitude,
      officeLat,
      officeLng,
    );
    notifyListeners();
    return pos;
  }

  Future<File?> _ambilSelfie() async {
    final photo = await _picker.pickImage(source: ImageSource.camera, preferredCameraDevice: CameraDevice.front, imageQuality: 75);
    if (photo == null) return null;
    return File(photo.path);
  }
}
