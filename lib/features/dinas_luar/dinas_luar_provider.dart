import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import '../../core/models/dinas_luar.dart';
import '../../core/models/jenis_ketidakhadiran.dart';

class DinasLuarProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient.instance;

  List<DinasLuarItem> myRequests = [];
  List<DinasLuarItem> teamRequests = [];
  List<JenisKetidakhadiran> jenisOptions = [];

  bool isLoading = false;
  bool isSubmitting = false;
  String? error;

  Future<void> loadAll({bool isAtasan = false}) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await Future.wait([
        loadOptions(),
        loadMine(),
        if (isAtasan) loadTeamRequests(),
      ]);
    } catch (e) {
      debugPrint("Error loading dinas luar data: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadOptions() async {
    try {
      final res = await _api.request('/jenis-ketidakhadiran');
      final rawList = res.data['data'] as List? ?? [];
      if (rawList.isNotEmpty) {
        jenisOptions = rawList.map((e) => JenisKetidakhadiran.fromJson(e)).toList();
      } else {
        _setFallbackOptions();
      }
    } catch (_) {
      _setFallbackOptions();
    }
  }

  void _setFallbackOptions() {
    jenisOptions = [
      JenisKetidakhadiran(id: 1, nama: 'Dinas Luar'),
      JenisKetidakhadiran(id: 2, nama: 'Rapat, Seminar, Konferensi'),
      JenisKetidakhadiran(id: 3, nama: 'Pendidikan, Pelatihan'),
      JenisKetidakhadiran(id: 7, nama: 'Force Majeur'),
      JenisKetidakhadiran(id: 10, nama: 'Tugas Belajar Alih Ke Izin Belajar'),
      JenisKetidakhadiran(id: 11, nama: 'Tugas Belajar Dengan Tunjangan Hidup'),
    ];
  }

  Future<void> loadMine() async {
    try {
      final res = await _api.request('/dinas-luar');
      final rawList = res.data['data'] as List? ?? [];
      myRequests = rawList.map((e) => DinasLuarItem.fromJson(e)).toList();
    } catch (e) {
      // If endpoint not built yet, fallback gracefully
      myRequests = [];
    }
  }

  Future<void> loadTeamRequests() async {
    try {
      final res = await _api.request('/atasan/dinas-luar-tim');
      final rawList = res.data['data'] as List? ?? [];
      teamRequests = rawList.map((e) => DinasLuarItem.fromJson(e)).toList();
    } catch (_) {
      teamRequests = [];
    }
  }

  Future<void> submitDinasLuar({
    required int jenisKetidakhadiranId,
    required String tanggalMulai,
    required String tanggalSelesai,
    required String lokasiTugas,
    required String alasan,
    File? fileSpt,
  }) async {
    isSubmitting = true;
    error = null;
    notifyListeners();

    try {
      final formData = FormData.fromMap({
        'jenis_ketidakhadiran_id': jenisKetidakhadiranId,
        'tanggal_mulai': tanggalMulai,
        'tanggal_selesai': tanggalSelesai,
        'lokasi_tugas': lokasiTugas,
        'alasan': alasan,
        if (fileSpt != null)
          'file_spt': await MultipartFile.fromFile(
            fileSpt.path,
            filename: fileSpt.path.split('/').last,
          ),
      });

      await _api.request(
        '/dinas-luar',
        method: 'POST',
        data: formData,
      );

      await loadMine();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Gagal mengirim pengajuan dinas luar: $e');
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> setujuiDinasLuar(int id, {String? catatan}) async {
    try {
      await _api.request(
        '/atasan/dinas-luar/$id/setujui',
        method: 'PATCH',
        data: {'catatan_atasan': catatan},
      );
      await loadAll(isAtasan: true);
    } on ApiException {
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> tolakDinasLuar(int id, {String? catatan}) async {
    try {
      await _api.request(
        '/atasan/dinas-luar/$id/tolak',
        method: 'PATCH',
        data: {'catatan_atasan': catatan},
      );
      await loadAll(isAtasan: true);
    } on ApiException {
      rethrow;
    } finally {
      notifyListeners();
    }
  }
}
