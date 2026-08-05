class DinasLuarItem {
  final int id;
  final int pegawaiId;
  final String? pegawaiNama;
  final int? jenisKetidakhadiranId;
  final String jenisKetidakhadiranNama;
  final String tanggalMulai;
  final String tanggalSelesai;
  final String lokasiTugas;
  final String alasan;
  final String? fileSptUrl;
  final String status;
  final String? approvedByNama;
  final String? catatanAtasan;
  final DateTime createdAt;

  DinasLuarItem({
    required this.id,
    required this.pegawaiId,
    this.pegawaiNama,
    this.jenisKetidakhadiranId,
    required this.jenisKetidakhadiranNama,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.lokasiTugas,
    required this.alasan,
    this.fileSptUrl,
    required this.status,
    this.approvedByNama,
    this.catatanAtasan,
    required this.createdAt,
  });

  factory DinasLuarItem.fromJson(Map<String, dynamic> json) {
    String jenisNama = json['jenis_ketidakhadiran_nama'] ?? '';
    if (jenisNama.isEmpty && json['jenis_ketidakhadiran'] != null) {
      jenisNama = json['jenis_ketidakhadiran']['nama'] ?? '';
    }
    if (jenisNama.isEmpty && json['jenis'] != null) {
      final j = json['jenis'].toString();
      if (j == 'dinas_luar') jenisNama = 'Dinas Luar';
      else if (j == 'wfa') jenisNama = 'WFA (Work From Anywhere)';
      else if (j == 'tugas_lapangan') jenisNama = 'Tugas Lapangan';
      else jenisNama = j;
    }

    return DinasLuarItem(
      id: json['id'] as int,
      pegawaiId: json['pegawai_id'] as int? ?? 0,
      pegawaiNama: json['pegawai_nama'] ?? (json['pegawai'] != null ? json['pegawai']['nama'] : null),
      jenisKetidakhadiranId: json['jenis_ketidakhadiran_id'] as int?,
      jenisKetidakhadiranNama: jenisNama.isNotEmpty ? jenisNama : 'Dinas Luar / Tugas Khusus',
      tanggalMulai: json['tanggal_mulai'] ?? '',
      tanggalSelesai: json['tanggal_selesai'] ?? '',
      lokasiTugas: json['lokasi_tugas'] ?? '',
      alasan: json['alasan'] ?? '',
      fileSptUrl: json['file_spt_url'] ?? json['file_spt'],
      status: json['status'] ?? 'pending',
      approvedByNama: json['approved_by_nama'] ?? (json['approver'] != null ? json['approver']['name'] : null),
      catatanAtasan: json['catatan_atasan'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  bool get isApproved => status == 'disetujui';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'ditolak';

  String get dateRangeText {
    if (tanggalMulai == tanggalSelesai) {
      return tanggalMulai;
    }
    return '$tanggalMulai s/d $tanggalSelesai';
  }
}
