import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/models/absensi.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/fade_slide_in.dart';
import '../../core/widgets/shimmer_box.dart';
import '../../core/widgets/status_badge.dart';
import 'widgets/geofence_map.dart';
import 'absensi_provider.dart';

class AbsensiScreen extends StatelessWidget {
  const AbsensiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AbsensiProvider()
        ..loadToday()
        ..loadHistory(),
      child: const _AbsensiBody(),
    );
  }
}

class _AbsensiBody extends StatelessWidget {
  const _AbsensiBody();

  Future<void> _handleMasuk(BuildContext context) async {
    final provider = context.read<AbsensiProvider>();
    try {
      await provider.presensiMasuk();
      if (context.mounted) _showSnack(context, 'Presensi masuk berhasil dicatat.', success: true);
    } catch (e) {
      if (context.mounted) _showSnack(context, e.toString(), success: false);
    }
  }

  Future<void> _handleKeluar(BuildContext context) async {
    final provider = context.read<AbsensiProvider>();
    try {
      await provider.presensiKeluar();
      if (context.mounted) _showSnack(context, 'Presensi pulang berhasil dicatat.', success: true);
    } catch (e) {
      if (context.mounted) _showSnack(context, e.toString(), success: false);
    }
  }

  void _showSnack(BuildContext context, String message, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.replaceFirst('ApiException: ', '')),
        backgroundColor: success ? AppColors.success : AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AbsensiProvider>();

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: const Text('Absensi')),
      body: RefreshIndicator(
        color: AppColors.red,
        onRefresh: () async {
          await context.read<AbsensiProvider>().loadToday();
          await context.read<AbsensiProvider>().loadHistory();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (provider.isLoadingToday) ...[
                const ShimmerBox(height: 230, borderRadius: BorderRadius.all(Radius.circular(24))),
                const SizedBox(height: 16),
                const ShimmerBox(height: 240, borderRadius: BorderRadius.all(Radius.circular(22))),
              ] else ...[
                FadeSlideIn(
                  child: _PresensiCard(
                    provider: provider,
                    onMasuk: () => _handleMasuk(context),
                    onKeluar: () => _handleKeluar(context),
                  ),
                ),
                const SizedBox(height: 16),
                const FadeSlideIn(
                  index: 1,
                  child: InteractiveGeofenceMap(),
                ),
              ],
              const SizedBox(height: 26),
              const Text('Riwayat Presensi', style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              if (provider.isLoadingHistory)
                Column(children: List.generate(3, (i) => const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: ShimmerBox(height: 64),
                )))
              else if (provider.history.isEmpty)
                const EmptyState(icon: Icons.history_rounded, title: 'Belum ada riwayat presensi bulan ini')
              else
                ...List.generate(provider.history.length, (i) => FadeSlideIn(
                  index: i + 2,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _HistoryTile(absensi: provider.history[i]),
                  ),
                )),
            ],
          ),
        ),
      ),
    );
  }
}

class _PresensiCard extends StatelessWidget {
  final AbsensiProvider provider;
  final VoidCallback onMasuk;
  final VoidCallback onKeluar;

  const _PresensiCard({required this.provider, required this.onMasuk, required this.onKeluar});

  @override
  Widget build(BuildContext context) {
    final today = provider.today;
    final shift = provider.shiftHariIni;
    final sudahMasuk = today?.jamMasuk != null;
    final sudahKeluar = today?.jamKeluar != null;

    final bool isWeekendNonShift = provider.isWeekendNonShift;
    final bool isLiburHariIni = shift != null && shift.isLibur;
    final String liburNama = shift?.statusShift?.nama ?? 'Hari Ini Libur (Reguler)';

    // Hitung jendela buka presensi masuk (Shift vs Normal)
    bool isJendelaBelumBuka = false;
    String jamBukaStr = '05:00';

    if (!sudahMasuk && !isLiburHariIni && !isWeekendNonShift) {
      int windowOpenMinutes = 5 * 60; // default 05:00 untuk pegawai normal
      jamBukaStr = '05:00';

      if (shift != null && shift.jamMulai != null) {
        final parts = shift.jamMulai!.split(':');
        if (parts.length >= 2) {
          final h = int.tryParse(parts[0]) ?? 8;
          final m = int.tryParse(parts[1]) ?? 0;
          final startMinutes = h * 60 + m;
          windowOpenMinutes = startMinutes - 60; // 60 menit sebelum shift
          if (windowOpenMinutes < 0) windowOpenMinutes += 1440;

          final bukaH = (windowOpenMinutes ~/ 60).toString().padLeft(2, '0');
          final bukaM = (windowOpenMinutes % 60).toString().padLeft(2, '0');
          jamBukaStr = '$bukaH:$bukaM';
        }
      }

      final now = DateTime.now();
      final nowMinutes = now.hour * 60 + now.minute;

      if (shift != null && shift.shift == '3') {
        // Shift 3 (mulai 22:00, jendela buka 21:00 = 1260m s/d 06:00 pagi)
        if (nowMinutes >= 360 && nowMinutes < 1260) {
          isJendelaBelumBuka = true;
        }
      } else {
        if (nowMinutes < windowOpenMinutes) {
          isJendelaBelumBuka = true;
        }
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.heroGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.red.withOpacity(0.28), blurRadius: 24, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Formatters.hariTanggal(DateTime.now()),
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  if (DateTime.now().weekday == DateTime.friday) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '🏡 WFH Jumat (Domisili)',
                        style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  if (shift != null && !shift.isLibur)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${shift.shiftLabel} · ${shift.jamMulai}-${shift.jamSelesai}' + (shift.stasiunTv != null ? ' · ${shift.stasiunTv}' : ''),
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isWeekendNonShift
                ? 'Hari Ini Libur Akhir Pekan'
                : (isLiburHariIni
                    ? 'Hari Ini Libur ($liburNama)'
                    : (sudahKeluar
                        ? 'Presensi Hari Ini Selesai'
                        : (sudahMasuk
                            ? 'Jangan Lupa Presensi Pulang'
                            : (isJendelaBelumBuka
                                ? 'Belum Jam Presensi'
                                : 'Mulai Presensi Masuk')))),
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          if (isWeekendNonShift) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: const [
                  Icon(Icons.weekend_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Hari ini adalah hari libur (akhir pekan), presensi tidak diperlukan.',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (isLiburHariIni) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sesuai jadwal shift, Anda tidak perlu melakukan presensi hari ini.',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (isJendelaBelumBuka) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      shift != null
                          ? 'Presensi untuk ${shift.shiftLabel} baru bisa dilakukan mulai pukul $jamBukaStr'
                          : 'Presensi masuk baru bisa dilakukan mulai pukul $jamBukaStr',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: _TimeBox(label: 'Masuk', value: today?.jamMasuk?.substring(0, 5) ?? '--:--', done: sudahMasuk)),
              const SizedBox(width: 12),
              Expanded(child: _TimeBox(label: 'Pulang', value: today?.jamKeluar?.substring(0, 5) ?? '--:--', done: sudahKeluar)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (provider.isSubmitting || isLiburHariIni || isJendelaBelumBuka || isWeekendNonShift)
                  ? null
                  : (sudahKeluar ? null : (sudahMasuk ? onKeluar : onMasuk)),
              icon: provider.isSubmitting
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.red))
                  : Icon(
                      isWeekendNonShift
                          ? Icons.event_busy_rounded
                          : (isLiburHariIni
                              ? Icons.event_available_rounded
                              : (isJendelaBelumBuka
                                  ? Icons.lock_clock_rounded
                                  : (sudahMasuk ? Icons.logout_rounded : Icons.camera_alt_rounded))),
                      size: 18,
                    ),
              label: Text(
                isWeekendNonShift
                    ? 'Hari Ini Libur Akhir Pekan'
                    : (isLiburHariIni
                        ? 'Hari Ini Libur'
                        : (isJendelaBelumBuka
                            ? 'Presensi Buka Pukul $jamBukaStr'
                            : (sudahKeluar
                                ? 'Presensi Selesai'
                                : (provider.isSubmitting
                                    ? 'Memproses...'
                                    : (sudahMasuk ? 'Presensi Pulang' : 'Presensi Masuk (Selfie)'))))),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.red,
                disabledBackgroundColor: Colors.white.withOpacity(0.5),
                disabledForegroundColor: AppColors.red.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeBox extends StatelessWidget {
  final String label;
  final String value;
  final bool done;
  const _TimeBox({required this.label, required this.value, required this.done});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.14), borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11.5)),
              const Spacer(),
              if (done) const Icon(Icons.check_circle_rounded, color: Colors.white, size: 14),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final Absensi absensi;
  const _HistoryTile({required this.absensi});

  (Color, Color, IconData) _statusStyle() {
    switch (absensi.status) {
      case 'hadir':
        return (AppColors.successSoft, AppColors.success, Icons.check_circle_outline_rounded);
      case 'telat':
        return (AppColors.warningSoft, AppColors.warning, Icons.schedule_rounded);
      case 'izin':
      case 'sakit':
        return (AppColors.infoSoft, AppColors.info, Icons.info_outline_rounded);
      default:
        return (AppColors.dangerSoft, AppColors.danger, Icons.cancel_outlined);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = _statusStyle();
    final jamMasuk = absensi.jamMasuk != null && absensi.jamMasuk!.length >= 5 ? absensi.jamMasuk!.substring(0, 5) : '--:--';
    final jamKeluar = absensi.jamKeluar != null && absensi.jamKeluar!.length >= 5 ? absensi.jamKeluar!.substring(0, 5) : '--:--';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: fg, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Formatters.tanggalPendek(absensi.tanggal),
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.south_west_rounded, color: AppColors.success, size: 12),
                    const SizedBox(width: 3),
                    Text(
                      jamMasuk,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF475569),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.north_east_rounded, color: AppColors.danger, size: 12),
                    const SizedBox(width: 3),
                    Text(
                      jamKeluar,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF475569),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          StatusBadge(
            label: absensi.status[0].toUpperCase() + absensi.status.substring(1),
            tone: absensi.status == 'hadir'
                ? BadgeTone.success
                : absensi.status == 'telat'
                    ? BadgeTone.warning
                    : (absensi.status == 'izin' || absensi.status == 'sakit')
                        ? BadgeTone.info
                        : BadgeTone.danger,
          ),
        ],
      ),
    );
  }
}
