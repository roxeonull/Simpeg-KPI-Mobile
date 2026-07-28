import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import '../../core/models/pegawai_detail.dart';

class PengajuanPerubahan {
  final int id;
  final String field;
  final String? nilaiLama;
  final String nilaiBaru;
  final String status;
  final String? catatanAdmin;
  final DateTime createdAt;

  PengajuanPerubahan({
    required this.id,
    required this.field,
    this.nilaiLama,
    required this.nilaiBaru,
    required this.status,
    this.catatanAdmin,
    required this.createdAt,
  });

  factory PengajuanPerubahan.fromJson(Map<String, dynamic> json) => PengajuanPerubahan(
        id: json['id'],
        field: json['field'],
        nilaiLama: json['nilai_lama'],
        nilaiBaru: json['nilai_baru'],
        status: json['status'],
        catatanAdmin: json['catatan_admin'],
        createdAt: DateTime.parse(json['created_at']),
      );
}

class ProfileProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient.instance;

  bool isLoading = true;
  bool isLoadingDetail = true;
  bool isSubmitting = false;
  List<PengajuanPerubahan> pengajuan = [];
  PegawaiDetail? pegawaiDetail;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    try {
      final res = await _api.request('/pengajuan-perubahan');
      pengajuan = (res.data['data'] as List).map((e) => PengajuanPerubahan.fromJson(e)).toList();
    } catch (_) {}
    isLoading = false;
    notifyListeners();
  }

  Future<void> ajukan({required String field, required String nilaiBaru}) async {
    isSubmitting = true;
    notifyListeners();
    try {
      await _api.request('/pengajuan-perubahan', method: 'POST', data: {'field': field, 'nilai_baru': nilaiBaru});
      await load();
    } on ApiException {
      rethrow;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> ubahPassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    isSubmitting = true;
    notifyListeners();
    try {
      await _api.request(
        '/ubah-password',
        method: 'POST',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPasswordConfirmation,
        },
      );
    } on ApiException {
      rethrow;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> loadDetailPegawai() async {
    isLoadingDetail = true;
    notifyListeners();
    try {
      final res = await _api.request('/profil/lengkap');
      pegawaiDetail = PegawaiDetail.fromJson(res.data['data']);
    } catch (_) {}
    isLoadingDetail = false;
    notifyListeners();
  }
}
