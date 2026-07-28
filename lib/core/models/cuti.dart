class TimelineStep {
  final String tahap;
  final String status; // menunggu | disetujui | ditolak | selesai
  final DateTime? waktu;
  final String? catatan;

  TimelineStep({required this.tahap, required this.status, this.waktu, this.catatan});

  factory TimelineStep.fromJson(Map<String, dynamic> json) => TimelineStep(
        tahap: json['tahap'],
        status: json['status'],
        waktu: json['waktu'] != null ? DateTime.tryParse(json['waktu']) : null,
        catatan: json['catatan'],
      );
}

class Cuti {
  final int id;
  final int? pegawaiId;
  final String? namaPegawai;
  final String? nipPegawai;
  final String? fotoPegawai;
  final String? unitPegawai;
  final String? jabatanPegawai;
  final String jenisCuti;
  final DateTime tanggalMulai;
  final DateTime tanggalSelesai;
  final int jumlahHari;
  final String? alasan;
  final String? alamatCuti;
  final String? lampiran;
  final String status;
  final String? statusAtasan;
  final String? catatanAtasan;
  final String? statusHr;
  final String? catatanHr;
  final String statusLabel;
  final DateTime? createdAt;
  final List<TimelineStep>? timeline;

  Cuti({
    required this.id,
    this.pegawaiId,
    this.namaPegawai,
    this.nipPegawai,
    this.fotoPegawai,
    this.unitPegawai,
    this.jabatanPegawai,
    required this.jenisCuti,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.jumlahHari,
    this.alasan,
    this.alamatCuti,
    this.lampiran,
    required this.status,
    this.statusAtasan,
    this.catatanAtasan,
    this.statusHr,
    this.catatanHr,
    required this.statusLabel,
    this.createdAt,
    this.timeline,
  });

  factory Cuti.fromJson(Map<String, dynamic> json) => Cuti(
        id: json['id'],
        pegawaiId: json['pegawai_id'],
        namaPegawai: json['nama_pegawai'] ?? json['pegawai']?['nama'],
        nipPegawai: json['nip_pegawai'] ?? json['pegawai']?['nip'],
        fotoPegawai: json['foto_pegawai'] ?? json['pegawai']?['foto'],
        unitPegawai: json['unit_pegawai'] ?? json['pegawai']?['unit'],
        jabatanPegawai: json['jabatan_pegawai'] ?? json['pegawai']?['jabatan'],
        jenisCuti: json['jenis_cuti'],
        tanggalMulai: DateTime.parse(json['tanggal_mulai']),
        tanggalSelesai: DateTime.parse(json['tanggal_selesai']),
        jumlahHari: json['jumlah_hari'],
        alasan: json['alasan'],
        alamatCuti: json['alamat_cuti'],
        lampiran: json['lampiran'],
        status: json['status'],
        statusAtasan: json['status_atasan'],
        catatanAtasan: json['catatan_atasan'],
        statusHr: json['status_hr'],
        catatanHr: json['catatan_hr'],
        statusLabel: json['status_label'] ?? json['status'],
        createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
        timeline: json['timeline'] != null
            ? (json['timeline'] as List).map((e) => TimelineStep.fromJson(e)).toList()
            : null,
      );
}

class SaldoCuti {
  final int tahun;
  final int total;
  final int terpakai;
  final int sisa;

  SaldoCuti({required this.tahun, required this.total, required this.terpakai, required this.sisa});

  factory SaldoCuti.fromJson(Map<String, dynamic> json) => SaldoCuti(
        tahun: json['tahun'],
        total: json['total'],
        terpakai: json['terpakai'],
        sisa: json['sisa'],
      );

  double get progress => total == 0 ? 0 : (terpakai / total).clamp(0, 1).toDouble();
}
