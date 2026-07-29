/// Konfigurasi endpoint backend SIMPEG-KPI.
///
/// PENTING — sesuaikan sebelum menjalankan aplikasi:
/// - Emulator Android: gunakan `http://10.0.2.2:8000/api` (alias localhost host).
/// - Emulator iOS / device fisik di jaringan sama: gunakan IP LAN laptop,
///   contoh `http://192.168.1.10:8000/api`.
/// - Produksi: ganti dengan domain server yang sebenarnya, contoh
///   `https://simpeg.kpi.go.id/api`.
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://nanny-clatter-upstage.ngrok-free.dev/api',
  );

  /// Base URL tanpa suffix /api, dipakai untuk mengakses file (foto, dsb).
  static String get storageBaseUrl =>
      baseUrl.replaceFirst(RegExp(r'/api/?$'), '');
}
