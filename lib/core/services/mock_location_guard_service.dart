import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:safe_device/safe_device.dart';
import 'package:url_launcher/url_launcher.dart';

/// Service khusus untuk deteksi status Developer Mode / Mock Location App di Android.
///
/// Layanan ini berjalan tanpa menggunakan lokasi GPS (zero location request),
/// hanya mengecek indikator setting sistem di level OS Android.
class MockLocationGuardService {
  MockLocationGuardService._();

  /// Mengecek apakah "Allow mock location" / Mock Location App aktif di Android.
  ///
  /// Mengembalikan [false] pada iOS atau jika terjadi kegagalan pembacaan sistem.
  static Future<bool> isMockLocationActive() async {
    if (!Platform.isAndroid) return false;
    try {
      final bool isMock = await SafeDevice.isMockLocation;
      return isMock;
    } catch (e) {
      return false;
    }
  }

  /// Membuka halaman Pengaturan Developer Options pada Android.
  ///
  /// Menggunakan intent `android.settings.APPLICATION_DEVELOPMENT_SETTINGS`
  /// dengan fallback ke halaman pengaturan umum jika intent spesifik tidak didukung ROM.
  static Future<void> openDeveloperSettings() async {
    if (!Platform.isAndroid) return;

    try {
      const intent = AndroidIntent(
        action: 'android.settings.APPLICATION_DEVELOPMENT_SETTINGS',
      );
      await intent.launch();
    } catch (_) {
      try {
        const generalSettingsIntent = AndroidIntent(
          action: 'android.settings.SETTINGS',
        );
        await generalSettingsIntent.launch();
      } catch (_) {
        final Uri url = Uri.parse('app-settings:');
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      }
    }
  }
}
