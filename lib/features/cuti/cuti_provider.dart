import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import '../../core/models/cuti.dart';

class CutiProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient.instance;

  bool isLoadingList = true;
  bool isLoadingSaldo = true;
  bool isLoadingKalender = false;
  bool isLoadingAtasanList = false;
  bool isSubmitting = false;
  Map<DateTime, List<dynamic>> kalenderTim = {};

  List<Cuti> _all = [];
  String filter = 'semua'; // semua | menunggu | disetujui | ditolak
  SaldoCuti? saldo;

  // State untuk Atasan Approval
  List<Cuti> _atasanAll = [];
  String atasanFilter = 'menunggu'; // menunggu | disetujui | ditolak | semua

  List<Cuti> get filtered {
    if (filter == 'semua') return _all;
    if (filter == 'menunggu') {
      return _all.where((c) => c.status == 'menunggu_atasan' || c.status == 'menunggu_hr').toList();
    }
    return _all.where((c) => c.status == filter).toList();
  }

  int countFor(String key) {
    if (key == 'semua') return _all.length;
    if (key == 'menunggu') {
      return _all.where((c) => c.status == 'menunggu_atasan' || c.status == 'menunggu_hr').length;
    }
    return _all.where((c) => c.status == key).length;
  }

  void setFilter(String value) {
    filter = value;
    notifyListeners();
  }

  // --- Atasan Getters & Helpers ---
  List<Cuti> get atasanFiltered {
    if (atasanFilter == 'semua') return _atasanAll;
    return _atasanAll.where((c) => c.statusAtasan == atasanFilter).toList();
  }

  int get pendingAtasanCount => _atasanAll.where((c) => c.statusAtasan == 'menunggu').length;

  int countAtasanFor(String key) {
    if (key == 'semua') return _atasanAll.length;
    return _atasanAll.where((c) => c.statusAtasan == key).length;
  }

  void setAtasanFilter(String value) {
    atasanFilter = value;
    notifyListeners();
  }

  Future<void> loadAll({bool isAtasan = false}) async {
    final futures = <Future<void>>[loadList(), loadSaldo()];
    if (isAtasan) {
      futures.add(loadAtasanCutiList());
    }
    await Future.wait(futures);
  }

  Future<void> loadList() async {
    isLoadingList = true;
    notifyListeners();
    try {
      final res = await _api.request('/cuti');
      _all = (res.data['data'] as List).map((e) => Cuti.fromJson(e)).toList();
    } catch (_) {
      // Biarkan list kosong, UI menampilkan empty state.
    }
    isLoadingList = false;
    notifyListeners();
  }

  Future<void> loadAtasanCutiList() async {
    isLoadingAtasanList = true;
    notifyListeners();
    try {
      final res = await _api.request('/atasan/cuti-tim', query: {'status': 'semua'});
      _atasanAll = (res.data['data'] as List).map((e) => Cuti.fromJson(e)).toList();
    } catch (_) {
      _atasanAll = [];
    }
    isLoadingAtasanList = false;
    notifyListeners();
  }

  Future<void> loadSaldo() async {
    isLoadingSaldo = true;
    notifyListeners();
    try {
      final res = await _api.request('/cuti/saldo');
      saldo = SaldoCuti.fromJson(res.data);
    } catch (_) {
      // opsional
    }
    isLoadingSaldo = false;
    notifyListeners();
  }

  Future<Cuti> loadDetail(int id) async {
    final res = await _api.request('/cuti/$id');
    return Cuti.fromJson(res.data['data']);
  }

  Future<void> setujuiCutiAtasan(int id, {String? catatan}) async {
    isSubmitting = true;
    notifyListeners();
    try {
      await _api.request(
        '/atasan/cuti/$id/setujui',
        method: 'PATCH',
        data: {'catatan': catatan},
      );
      await loadAtasanCutiList();
    } on ApiException {
      rethrow;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> tolakCutiAtasan(int id, {required String catatan}) async {
    isSubmitting = true;
    notifyListeners();
    try {
      await _api.request(
        '/atasan/cuti/$id/tolak',
        method: 'PATCH',
        data: {'catatan': catatan},
      );
      await loadAtasanCutiList();
    } on ApiException {
      rethrow;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> ajukanCuti({
    required String jenisCuti,
    required DateTime tanggalMulai,
    required DateTime tanggalSelesai,
    required String alasan,
    String? alamatCuti,
    String? lampiranPath,
  }) async {
    isSubmitting = true;
    notifyListeners();
    try {
      final map = {
        'jenis_cuti': jenisCuti,
        'tanggal_mulai': tanggalMulai.toIso8601String().split('T').first,
        'tanggal_selesai': tanggalSelesai.toIso8601String().split('T').first,
        'alasan': alasan,
        if (alamatCuti != null && alamatCuti.isNotEmpty) 'alamat_cuti': alamatCuti,
      };

      dynamic data = map;
      if (lampiranPath != null) {
        data = FormData.fromMap({
          ...map,
          'lampiran': await MultipartFile.fromFile(lampiranPath),
        });
      }

      await _api.request('/cuti', method: 'POST', data: data);
      await loadAll();
    } on ApiException {
      rethrow;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> loadKalenderTim(String bulan) async {
    isLoadingKalender = true;
    notifyListeners();
    try {
      final res = await _api.request('/cuti/kalender-tim', query: {'bulan': bulan});
      final List list = res.data['data'] ?? [];
      
      final Map<DateTime, List<dynamic>> map = {};
      for (final item in list) {
        final start = DateTime.parse(item['tanggal_mulai']);
        final end = DateTime.parse(item['tanggal_selesai']);
        
        DateTime cursor = DateTime(start.year, start.month, start.day);
        final endDay = DateTime(end.year, end.month, end.day);
        
        while (!cursor.isAfter(endDay)) {
          final dateKey = DateTime(cursor.year, cursor.month, cursor.day);
          map[dateKey] = (map[dateKey] ?? [])..add(item);
          cursor = cursor.add(const Duration(days: 1));
        }
      }
      kalenderTim = map;
    } catch (_) {}
    isLoadingKalender = false;
    notifyListeners();
  }
}
