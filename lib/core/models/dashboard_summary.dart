import 'cuti.dart';
import 'jadwal_shift.dart';

class AbsensiHariIni {
  final String? jamMasuk;
  final String? jamKeluar;
  final String? status;

  AbsensiHariIni({this.jamMasuk, this.jamKeluar, this.status});

  factory AbsensiHariIni.fromJson(Map<String, dynamic>? json) {
    if (json == null) return AbsensiHariIni();
    return AbsensiHariIni(
      jamMasuk: json['jam_masuk'],
      jamKeluar: json['jam_keluar'],
      status: json['status'],
    );
  }

  bool get sudahMasuk => jamMasuk != null;
  bool get sudahKeluar => jamKeluar != null;
}

class DashboardSummary {
  final AbsensiHariIni absensiHariIni;
  final bool hasJadwalShift;
  final JadwalShiftItem? jadwalShiftHariIni;
  final int saldoCutiTotal;
  final int saldoCutiSisa;
  final int totalJpTahunIni;
  final int rekapHadir;
  final int rekapIzinSakit;
  final int rekapAlpa;
  final List<Cuti> cutiTerbaru;

  DashboardSummary({
    required this.absensiHariIni,
    required this.hasJadwalShift,
    this.jadwalShiftHariIni,
    required this.saldoCutiTotal,
    required this.saldoCutiSisa,
    required this.totalJpTahunIni,
    required this.rekapHadir,
    required this.rekapIzinSakit,
    required this.rekapAlpa,
    required this.cutiTerbaru,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) => DashboardSummary(
        absensiHariIni: AbsensiHariIni.fromJson(json['absensi_hari_ini']),
        hasJadwalShift: json['has_jadwal_shift'] as bool? ?? false,
        jadwalShiftHariIni: json['jadwal_shift_hari_ini'] != null
            ? JadwalShiftItem.fromJson(json['jadwal_shift_hari_ini'])
            : null,
        saldoCutiTotal: json['saldo_cuti']?['total'] ?? 0,
        saldoCutiSisa: json['saldo_cuti']?['sisa'] ?? 0,
        totalJpTahunIni: json['total_jp_tahun_ini'] ?? 0,
        rekapHadir: json['rekap_absensi_bulan_ini']?['hadir'] ?? 0,
        rekapIzinSakit: json['rekap_absensi_bulan_ini']?['izin_sakit'] ?? 0,
        rekapAlpa: json['rekap_absensi_bulan_ini']?['alpa'] ?? 0,
        cutiTerbaru: (json['cuti_terbaru'] as List? ?? [])
            .map((e) => Cuti.fromJson(e))
            .toList(),
      );
}
