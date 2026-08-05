import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_item.dart';
import 'notification_storage.dart';

class ShiftReminderService {
  ShiftReminderService._internal();
  static final ShiftReminderService instance = ShiftReminderService._internal();

  static const String _keyReminderEnabled = 'shift_reminder_enabled';
  static const String _keyLeadMinutes = 'shift_reminder_lead_minutes';
  static const String _keyLastMasukDate = 'last_masuk_reminder_date';
  static const String _keyLastKeluarDate = 'last_keluar_reminder_date';

  /// Check if reminders are enabled by user (default: true)
  Future<bool> isReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyReminderEnabled) ?? true;
  }

  /// Toggle reminder enabled
  Future<void> setReminderEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyReminderEnabled, enabled);
  }

  /// Get lead minutes before shift start (15 or 30 mins)
  Future<int> getLeadMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyLeadMinutes) ?? 15;
  }

  /// Set lead minutes
  Future<void> setLeadMinutes(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLeadMinutes, minutes);
  }

  /// Synchronize & check if an automated presensi reminder should fire
  Future<void> syncShiftReminders({
    required String jamMasuk,
    required String jamKeluar,
    required bool hasAbsenMasuk,
    required bool hasAbsenKeluar,
    String? shiftName,
  }) async {
    try {
      final enabled = await isReminderEnabled();
      if (!enabled) return;

      final now = DateTime.now();
      final todayStr = DateFormat('yyyy-MM-dd').format(now);
      final prefs = await SharedPreferences.getInstance();

      final leadMinutes = await getLeadMinutes();

      // Parse shift times
      final masukParts = jamMasuk.split(':');
      final keluarParts = jamKeluar.split(':');

      if (masukParts.length < 2 || keluarParts.length < 2) return;

      final masukTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(masukParts[0]),
        int.parse(masukParts[1]),
      );

      final keluarTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(keluarParts[0]),
        int.parse(keluarParts[1]),
      );

      // 1. Remind Absen Masuk (if not checked in yet and current time is near shift start)
      if (!hasAbsenMasuk) {
        final lastMasukDate = prefs.getString(_keyLastMasukDate);
        if (lastMasukDate != todayStr) {
          final reminderWindowStart = masukTime.subtract(Duration(minutes: leadMinutes + 5));
          final reminderWindowEnd = masukTime.add(const Duration(minutes: 60)); // Up to 1 hr late

          if (now.isAfter(reminderWindowStart) && now.isBefore(reminderWindowEnd)) {
            final shiftText = shiftName != null ? ' ($shiftName)' : '';
            final item = NotificationItem(
              id: 'masuk_$todayStr',
              title: '⏰ Pengingat Absen Masuk',
              body: 'Jadwal shift Anda$shiftText dimulai pukul $jamMasuk. Jangan lupa catat kehadiran tepat waktu!',
              type: 'absensi',
              payload: {'type': 'absensi', 'action': 'masuk'},
              timestamp: now,
            );

            await NotificationStorage().saveNotification(item);
            await prefs.setString(_keyLastMasukDate, todayStr);
          }
        }
      }

      // 2. Remind Absen Keluar (if checked in, but not checked out yet and shift has ended)
      if (hasAbsenMasuk && !hasAbsenKeluar) {
        final lastKeluarDate = prefs.getString(_keyLastKeluarDate);
        if (lastKeluarDate != todayStr) {
          final reminderWindowStart = keluarTime.subtract(const Duration(minutes: 5));
          final reminderWindowEnd = keluarTime.add(const Duration(hours: 3));

          if (now.isAfter(reminderWindowStart) && now.isBefore(reminderWindowEnd)) {
            final item = NotificationItem(
              id: 'keluar_$todayStr',
              title: '🔔 Pengingat Absen Keluar',
              body: 'Jam shift Anda ($jamKeluar) telah selesai. Silakan lakukan Absen Keluar sebelum meninggalkan lokasi!',
              type: 'absensi',
              payload: {'type': 'absensi', 'action': 'keluar'},
              timestamp: now,
            );

            await NotificationStorage().saveNotification(item);
            await prefs.setString(_keyLastKeluarDate, todayStr);
          }
        }
      }
    } catch (e) {
      debugPrint("Error syncing shift reminders: $e");
    }
  }

  /// Trigger a test notification immediately
  Future<void> sendTestReminder() async {
    final now = DateTime.now();
    final item = NotificationItem(
      id: 'test_${now.millisecondsSinceEpoch}',
      title: '🧪 Uji Pengingat Presensi',
      body: 'Ini adalah contoh pengingat otomatis presensi shift SIMPEG-KPI. Fitur berjalan dengan baik!',
      type: 'absensi',
      payload: {'type': 'absensi'},
      timestamp: now,
    );

    await NotificationStorage().saveNotification(item);
  }
}
