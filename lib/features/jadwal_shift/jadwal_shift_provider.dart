import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/models/jadwal_shift.dart';

class JadwalShiftProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient.instance;

  bool isLoading = true;
  String? error;
  bool hasJadwalShift = false;
  String currentBulan = '';
  List<JadwalShiftItem> entries = [];

  Future<void> loadMonthly([String? bulanStr]) async {
    isLoading = true;
    error = null;
    if (bulanStr != null) {
      currentBulan = bulanStr;
    } else if (currentBulan.isEmpty) {
      final now = DateTime.now();
      currentBulan = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    }
    notifyListeners();

    try {
      final res = await _api.request(
        '/jadwal-shift',
        query: {'bulan': currentBulan},
      );
      hasJadwalShift = res.data['has_jadwal_shift'] as bool? ?? false;
      final rawList = res.data['data'] as List? ?? [];
      entries = rawList.map((e) => JadwalShiftItem.fromJson(e)).toList();
    } catch (e) {
      error = 'Gagal memuat jadwal shift. Tarik ke bawah untuk mencoba lagi.';
    }

    isLoading = false;
    notifyListeners();
  }
}
