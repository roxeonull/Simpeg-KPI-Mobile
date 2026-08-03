import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import '../../core/models/riwayat.dart';
import '../../core/models/pelatihan_options.dart';

class RiwayatProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient.instance;

  bool isLoadingPendidikan = true;
  bool isLoadingPelatihan = true;
  bool isLoadingOptions = false;
  bool isSubmitting = false;
  List<RiwayatPendidikan> pendidikan = [];
  List<RiwayatPelatihan> pelatihan = [];
  PelatihanOptions? pelatihanOptions;
  int totalJpTahunIni = 0;

  Future<void> loadAll() async {
    await Future.wait([loadPendidikan(), loadPelatihan()]);
  }

  Future<void> loadPendidikan() async {
    isLoadingPendidikan = true;
    notifyListeners();
    try {
      final res = await _api.request('/riwayat/pendidikan');
      debugPrint('[RiwayatProvider] RAW /riwayat/pendidikan response: ${res.data}');
      pendidikan = (res.data['data'] as List).map((e) => RiwayatPendidikan.fromJson(e)).toList();
    } catch (e, stack) {
      debugPrint('[RiwayatProvider] Error loading pendidikan: $e\n$stack');
    }
    isLoadingPendidikan = false;
    notifyListeners();
  }

  Future<void> loadPelatihan() async {
    isLoadingPelatihan = true;
    notifyListeners();
    try {
      final res = await _api.request('/riwayat/pelatihan');
      pelatihan = (res.data['data'] as List).map((e) => RiwayatPelatihan.fromJson(e)).toList();
      totalJpTahunIni = res.data['total_jp_tahun_ini'] ?? 0;
    } catch (_) {}
    isLoadingPelatihan = false;
    notifyListeners();
  }

  Future<void> loadPelatihanOptions() async {
    isLoadingOptions = true;
    notifyListeners();
    try {
      final res = await _api.request('/riwayat/pelatihan/options');
      pelatihanOptions = PelatihanOptions.fromJson(res.data);
    } catch (_) {}
    isLoadingOptions = false;
    notifyListeners();
  }

  Future<void> submitPelatihan({
    required String namaPelatihan,
    required String penyelenggara,
    required DateTime tanggalMulai,
    required DateTime tanggalAkhir,
    required int durasiJp,
    required int bentukPelatihanId,
    required int tipeKursusId,
    required int jenisKursusId,
    required int instansiId,
    required String noSertifikat,
    required DateTime tanggalSertifikat,
    String? bidangSdmSpbe,
    required String sertifikatPath,
  }) async {
    isSubmitting = true;
    notifyListeners();
    try {
      final map = {
        'nama_pelatihan': namaPelatihan,
        'penyelenggara': penyelenggara,
        'tanggal': tanggalMulai.toIso8601String().split('T').first,
        'tanggal_akhir': tanggalAkhir.toIso8601String().split('T').first,
        'durasi_jp': durasiJp,
        'bentuk_pelatihan_id': bentukPelatihanId,
        'tipe_kursus_id': tipeKursusId,
        'jenis_kursus_id': jenisKursusId,
        'instansi_id': instansiId,
        'no_sertifikat': noSertifikat,
        'tanggal_sertifikat': tanggalSertifikat.toIso8601String().split('T').first,
      };
      if (bidangSdmSpbe != null && bidangSdmSpbe.trim().isNotEmpty) {
        map['bidang_sdm_spbe'] = bidangSdmSpbe;
      }

      final data = FormData.fromMap({
        ...map,
        'sertifikat': await MultipartFile.fromFile(sertifikatPath),
      });

      await _api.request('/riwayat/pelatihan', method: 'POST', data: data);
      await loadPelatihan();
    } on ApiException {
      rethrow;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
