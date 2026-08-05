import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/models/cuti.dart';
import '../../core/models/dashboard_summary.dart';
import '../../core/models/jadwal_shift.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/bouncing_button.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/fade_slide_in.dart';
import '../../core/widgets/shimmer_box.dart';
import '../../core/widgets/status_badge.dart';
import '../auth/auth_provider.dart';
import '../cuti/widgets/cuti_status_helper.dart';
import '../cuti/cuti_list_screen.dart';
import '../jadwal_shift/jadwal_shift_screen.dart';
import '../riwayat/riwayat_screen.dart';
import '../profile/data_pegawai_screen.dart';
import '../profile/pengajuan_perubahan_screen.dart';
import '../notification/notification_provider.dart';
import '../notification/notification_center_screen.dart';
import 'dashboard_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardProvider()..load(),
      child: const _DashboardBody(),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dashboard = context.watch<DashboardProvider>();
    final pegawai = auth.user?.pegawai;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.red,
          onRefresh: () => context.read<DashboardProvider>().load(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modern Profile Header Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black.withOpacity(0.06), width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _Avatar(
                        initials: pegawai?.initials ?? '?',
                        foto: pegawai?.foto,
                        size: 48,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _greeting(),
                                  style: GoogleFonts.plusJakartaSans(
                                    color: const Color(0xFF64748B),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text('👋', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              pegawai?.nama ?? auth.user?.name ?? '',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 17.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (pegawai?.jabatan != null && pegawai!.jabatan!.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                pegawai.jabatan!,
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppColors.red,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ] else if (pegawai?.nip != null && pegawai!.nip.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                'NIP. ${pegawai.nip}',
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppColors.gray,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Consumer<NotificationProvider>(
                        builder: (context, notifProvider, _) {
                          final unread = notifProvider.unreadCount;
                          return BouncingButton(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const NotificationCenterScreen(),
                                ),
                              );
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black.withOpacity(0.06)),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Icon(
                                    Icons.notifications_none_rounded,
                                    color: Color(0xFF0F172A),
                                    size: 22,
                                  ),
                                  if (unread > 0)
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: const BoxDecoration(
                                          color: AppColors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 16,
                                          minHeight: 16,
                                        ),
                                        child: Center(
                                          child: Text(
                                            unread > 99 ? '99+' : '$unread',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.bold,
                                              height: 1.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                if (dashboard.isLoading)
                  const _DashboardSkeleton()
                else if (dashboard.error != null)
                  EmptyState(icon: Icons.cloud_off_rounded, title: dashboard.error!)
                else if (dashboard.summary != null)
                  _DashboardContent(summary: dashboard.summary!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final DashboardSummary summary;
  const _DashboardContent({required this.summary});

  @override
  Widget build(BuildContext context) {
    final s = summary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeSlideIn(index: 0, child: _AttendanceHeroCard(summary: s)),
        if (s.jadwalShiftHariIni != null) ...[
          const SizedBox(height: 16),
          FadeSlideIn(index: 1, child: _ShiftHariIniCard(item: s.jadwalShiftHariIni!)),
        ],
        const SizedBox(height: 20),
        FadeSlideIn(index: 2, child: _QuickMenuGrid(hasJadwalShift: s.hasJadwalShift)),
        const SizedBox(height: 20),
        FadeSlideIn(
          index: 3,
          child: Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Saldo Cuti',
                  value: '${s.saldoCutiSisa}',
                  suffix: '/ ${s.saldoCutiTotal} hari',
                  icon: Icons.event_available_rounded,
                  color: AppColors.gold,
                  bgColor: AppColors.goldSoft,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _StatCard(
                  label: 'JP Diklat',
                  value: '${s.totalJpTahunIni}',
                  suffix: 'JP tahun ini',
                  icon: Icons.school_rounded,
                  color: AppColors.info,
                  bgColor: AppColors.infoSoft,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        FadeSlideIn(index: 4, child: _AttendanceChartCard(summary: s)),
        const SizedBox(height: 24),
        FadeSlideIn(
          index: 5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.red,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Pengajuan Cuti Terbaru',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.black,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if ((s.cutiTerbaru as List).isEmpty)
          const EmptyState(icon: Icons.event_busy_rounded, title: 'Belum ada pengajuan cuti')
        else
          ...List.generate((s.cutiTerbaru as List<Cuti>).length, (i) {
            final cuti = (s.cutiTerbaru as List<Cuti>)[i];
            return FadeSlideIn(
              index: 6 + i,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CutiMiniCard(cuti: cuti),
              ),
            );
          }),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initials;
  final String? foto;
  final double size;

  const _Avatar({
    required this.initials,
    this.foto,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFB91C1C), Color(0xFFDC2626)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.red.withOpacity(0.22),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: foto != null && foto!.isNotEmpty
                ? Image.network(
                    foto!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text(
                          initials,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Text(
                      initials,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
          ),
        ),
        Positioned(
          right: -1,
          bottom: -1,
          child: Container(
            width: 13,
            height: 13,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.2),
            ),
          ),
        ),
      ],
    );
  }
}

class _AttendanceHeroCard extends StatelessWidget {
  final DashboardSummary summary;
  const _AttendanceHeroCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final a = summary.absensiHariIni;
    final bool sudahMasuk = a.sudahMasuk;
    final bool sudahKeluar = a.sudahKeluar;

    String statusText;
    IconData statusIcon;
    if (!sudahMasuk) {
      statusText = 'Anda belum presensi masuk hari ini';
      statusIcon = Icons.login_rounded;
    } else if (!sudahKeluar) {
      statusText = 'Masuk pukul ${a.jamMasuk} · Belum presensi pulang';
      statusIcon = Icons.access_time_filled_rounded;
    } else {
      statusText = 'Presensi hari ini lengkap';
      statusIcon = Icons.check_circle_rounded;
    }

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.heroGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.heroShadow,
      ),
      child: Stack(
        children: [
          // Decorative background circles for visual depth
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            left: -40,
            bottom: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(statusIcon, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        statusText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _TimeBlock(label: 'Jam Masuk', value: a.jamMasuk?.substring(0, 5) ?? '--:--')),
                      Container(width: 1, height: 32, color: Colors.white.withOpacity(0.2)),
                      Expanded(child: _TimeBlock(label: 'Jam Pulang', value: a.jamKeluar?.substring(0, 5) ?? '--:--')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeBlock extends StatelessWidget {
  final String label;
  final String value;
  const _TimeBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11.5, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String suffix;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.suffix,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.cardGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 14),
          Text(label, style: const TextStyle(color: AppColors.gray, fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: AppColors.black, letterSpacing: -0.4),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  suffix,
                  style: const TextStyle(fontSize: 11, color: AppColors.grayLight, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttendanceChartCard extends StatelessWidget {
  final DashboardSummary summary;
  const _AttendanceChartCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final hadir = summary.rekapHadir as int;
    final izin = summary.rekapIzinSakit as int;
    final alpa = summary.rekapAlpa as int;
    final total = hadir + izin + alpa;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.cardGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.red,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Rekap Kehadiran Bulan Ini',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.black),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (total == 0)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('Belum ada data kehadiran bulan ini', style: TextStyle(color: AppColors.grayLight, fontSize: 12.5)),
              ),
            )
          else
            Row(
              children: [
                SizedBox(
                  height: 110,
                  width: 110,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 30,
                      sections: [
                        PieChartSectionData(value: hadir.toDouble(), color: AppColors.success, radius: 18, showTitle: false),
                        PieChartSectionData(value: izin.toDouble(), color: AppColors.info, radius: 18, showTitle: false),
                        PieChartSectionData(value: alpa.toDouble(), color: AppColors.danger, radius: 18, showTitle: false),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LegendRow(color: AppColors.success, label: 'Hadir', value: hadir),
                      const SizedBox(height: 10),
                      _LegendRow(color: AppColors.info, label: 'Izin/Sakit', value: izin),
                      const SizedBox(height: 10),
                      _LegendRow(color: AppColors.danger, label: 'Alpa', value: alpa),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final int value;
  const _LegendRow({required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.gray, fontWeight: FontWeight.w500))),
        Text('$value', style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.black)),
      ],
    );
  }
}

class _CutiMiniCard extends StatelessWidget {
  final Cuti cuti;
  const _CutiMiniCard({required this.cuti});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.redSoft, borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.event_note_rounded, color: AppColors.red, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(Formatters.jenisCuti(cuti.jenisCuti), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.black)),
                const SizedBox(height: 3),
                Text(
                  '${Formatters.rentangTanggal(cuti.tanggalMulai, cuti.tanggalSelesai)} · ${cuti.jumlahHari} hari',
                  style: const TextStyle(color: AppColors.gray, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          StatusBadge(label: cuti.statusLabel, tone: CutiStatusHelper.tone(cuti.status)),
        ],
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ShimmerBox(height: 140, borderRadius: BorderRadius.all(Radius.circular(24))),
        const SizedBox(height: 16),
        const ShimmerBox(height: 90, borderRadius: BorderRadius.all(Radius.circular(18))),
        const SizedBox(height: 16),
        Row(children: const [
          Expanded(child: ShimmerBox(height: 100)),
          SizedBox(width: 12),
          Expanded(child: ShimmerBox(height: 100)),
        ]),
        const SizedBox(height: 16),
        const ShimmerBox(height: 160),
      ],
    );
  }
}

class _ShiftHariIniCard extends StatelessWidget {
  final JadwalShiftItem item;
  const _ShiftHariIniCard({required this.item});

  @override
  Widget build(BuildContext context) {
    if (item.isLibur) {
      final statusNama = item.statusShift?.nama ?? 'Hari Ini Libur (Reguler)';
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFBBF7D0)),
          boxShadow: AppColors.softShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.event_available_rounded, color: Color(0xFF15803D), size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jadwal Shift Hari Ini',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF166534)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    statusNama,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF14532D)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4338CA), Color(0xFF1E1B4B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: const Color(0xFF4338CA).withOpacity(0.25), blurRadius: 18, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  item.shiftLabel,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${item.jamMulai} - ${item.jamSelesai} WIB',
                style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          if (item.stasiunTv != null && item.stasiunTv!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.live_tv_rounded, color: Color(0xFF38BDF8), size: 18),
                const SizedBox(width: 8),
                Text(
                  'Pantau Stasiun TV: ',
                  style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12.5),
                ),
                Expanded(
                  child: Text(
                    item.stasiunTv!,
                    style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Grid Akses Cepat Menu Layanan Kepegawaian (KONSISTEN 4 KOLOM PER BARIS)
class _QuickMenuGrid extends StatelessWidget {
  final bool hasJadwalShift;
  const _QuickMenuGrid({this.hasJadwalShift = false});

  @override
  Widget build(BuildContext context) {
    // Definisi item-item menu layanan kepegawaian
    final List<_QuickMenuItemData> items = [
      if (hasJadwalShift)
        _QuickMenuItemData(
          label: 'Jadwal Shift',
          icon: Icons.calendar_month_rounded,
          accentColor: AppColors.indigoAccent,
          bgColor: AppColors.indigoSoft,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const JadwalShiftScreen()),
            );
          },
        ),
      _QuickMenuItemData(
        label: 'Data Pegawai',
        icon: Icons.badge_rounded,
        accentColor: AppColors.emeraldAccent,
        bgColor: AppColors.emeraldSoft,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DataPegawaiScreen()),
          );
        },
      ),
      _QuickMenuItemData(
        label: 'Diklat',
        icon: Icons.school_rounded,
        accentColor: AppColors.skyAccent,
        bgColor: AppColors.skySoft,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RiwayatScreen()),
          );
        },
      ),
      _QuickMenuItemData(
        label: 'Kalender Tim',
        icon: Icons.calendar_month_rounded,
        accentColor: AppColors.amberAccent,
        bgColor: AppColors.amberSoft,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CutiListScreen(initialTab: 1)),
          );
        },
      ),
      _QuickMenuItemData(
        label: 'Ajukan Ubah',
        icon: Icons.edit_note_rounded,
        accentColor: AppColors.crimsonAccent,
        bgColor: AppColors.crimsonSoft,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PengajuanPerubahanScreen()),
          );
        },
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.cardGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.red,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Layanan Kepegawaian',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Consistent 4-Column Grid View with Natural Left-Alignment
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 8,
              mainAxisExtent: 90,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return _QuickMenuButton(
                label: item.label,
                icon: item.icon,
                accentColor: item.accentColor,
                bgColor: item.bgColor,
                onTap: item.onTap,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuickMenuItemData {
  final String label;
  final IconData icon;
  final Color accentColor;
  final Color bgColor;
  final VoidCallback onTap;

  _QuickMenuItemData({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.bgColor,
    required this.onTap,
  });
}

class _QuickMenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color accentColor;
  final Color bgColor;
  final VoidCallback onTap;

  const _QuickMenuButton({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingButton(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: accentColor.withOpacity(0.18), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: accentColor, size: 21),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}
