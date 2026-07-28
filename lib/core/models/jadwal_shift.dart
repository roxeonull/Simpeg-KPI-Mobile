class StatusShift {
  final int id;
  final String kode;
  final String nama;
  final String? warna;

  StatusShift({
    required this.id,
    required this.kode,
    required this.nama,
    this.warna,
  });

  factory StatusShift.fromJson(Map<String, dynamic> json) {
    return StatusShift(
      id: json['id'] as int,
      kode: json['kode'] as String? ?? '',
      nama: json['nama'] as String? ?? '',
      warna: json['warna'] as String?,
    );
  }
}

class JadwalShiftItem {
  final int id;
  final String tanggal;
  final String shift;
  final String jamMulai;
  final String jamSelesai;
  final String? stasiunTv;
  final bool isLibur;
  final StatusShift? statusShift;
  final String? keterangan;

  JadwalShiftItem({
    required this.id,
    required this.tanggal,
    required this.shift,
    required this.jamMulai,
    required this.jamSelesai,
    this.stasiunTv,
    required this.isLibur,
    this.statusShift,
    this.keterangan,
  });

  factory JadwalShiftItem.fromJson(Map<String, dynamic> json) {
    return JadwalShiftItem(
      id: json['id'] as int,
      tanggal: json['tanggal'] as String? ?? '',
      shift: json['shift'] as String? ?? '1',
      jamMulai: json['jam_mulai'] as String? ?? '08:00',
      jamSelesai: json['jam_selesai'] as String? ?? '16:00',
      stasiunTv: json['stasiun_tv'] as String?,
      isLibur: json['is_libur'] as bool? ?? false,
      statusShift: json['status_shift'] != null
          ? StatusShift.fromJson(json['status_shift'] as Map<String, dynamic>)
          : null,
      keterangan: json['keterangan'] as String?,
    );
  }

  String get shiftLabel => 'Shift $shift';
  String get jamRange => '$jamMulai - $jamSelesai';
}
