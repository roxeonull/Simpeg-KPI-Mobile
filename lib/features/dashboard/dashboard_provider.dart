import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/models/dashboard_summary.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient.instance;

  bool isLoading = true;
  String? error;
  DashboardSummary? summary;

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _api.request('/dashboard');
      summary = DashboardSummary.fromJson(response.data);
    } catch (e) {
      error = 'Gagal memuat data dashboard. Tarik ke bawah untuk mencoba lagi.';
    }

    isLoading = false;
    notifyListeners();
  }
}
