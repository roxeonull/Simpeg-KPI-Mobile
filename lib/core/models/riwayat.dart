class RiwayatPendidikan {
  final int id;
  final String jenjang;
  final String institusi;
  final String? jurusan;
  final int tahunLulus;
  final String? fileIjazah;

  RiwayatPendidikan({
    required this.id,
    required this.jenjang,
    required this.institusi,
    this.jurusan,
    required this.tahunLulus,
    this.fileIjazah,
  });

  factory RiwayatPendidikan.fromJson(Map<String, dynamic> json) => RiwayatPendidikan(
        id: json['id'],
        jenjang: json['jenjang'],
        institusi: json['institusi'],
        jurusan: json['jurusan'],
        tahunLulus: json['tahun_lulus'],
        fileIjazah: json['file_ijazah'],
      );
}

class RiwayatPelatihan {
  final int id;
  final String namaPelatihan;
  final String? penyelenggara;
  final DateTime tanggal;
  final DateTime? tanggalAkhir;
  final int durasiJp;
  final String kategori;
  final String statusVerifikasi;
  final String? catatan;
  final String? noSertifikat;
  final DateTime? tanggalSertifikat;
  final String? bidangSdmSpbe;
  final String? sertifikat;
  final int? bentukPelatihanId;
  final String? bentukPelatihan;
  final int? tipeKursusId;
  final String? tipeKursus;
  final int? jenisKursusId;
  final String? jenisKursus;
  final int? instansiId;
  final String? instansi;

  RiwayatPelatihan({
    required this.id,
    required this.namaPelatihan,
    this.penyelenggara,
    required this.tanggal,
    this.tanggalAkhir,
    required this.durasiJp,
    required this.kategori,
    required this.statusVerifikasi,
    this.catatan,
    this.noSertifikat,
    this.tanggalSertifikat,
    this.bidangSdmSpbe,
    this.sertifikat,
    this.bentukPelatihanId,
    this.bentukPelatihan,
    this.tipeKursusId,
    this.tipeKursus,
    this.jenisKursusId,
    this.jenisKursus,
    this.instansiId,
    this.instansi,
  });

  factory RiwayatPelatihan.fromJson(Map<String, dynamic> json) => RiwayatPelatihan(
        id: json['id'],
        namaPelatihan: json['nama_pelatihan'],
        penyelenggara: json['penyelenggara'],
        tanggal: DateTime.parse(json['tanggal']),
        tanggalAkhir: json['tanggal_akhir'] != null ? DateTime.parse(json['tanggal_akhir']) : null,
        durasiJp: json['durasi_jp'],
        kategori: json['kategori'],
        statusVerifikasi: json['status_verifikasi'],
        catatan: json['catatan'],
        noSertifikat: json['no_sertifikat'],
        tanggalSertifikat: json['tanggal_sertifikat'] != null ? DateTime.parse(json['tanggal_sertifikat']) : null,
        bidangSdmSpbe: json['bidang_sdm_spbe'],
        sertifikat: json['sertifikat'],
        bentukPelatihanId: json['bentuk_pelatihan_id'],
        bentukPelatihan: json['bentuk_pelatihan'],
        tipeKursusId: json['tipe_kursus_id'],
        tipeKursus: json['tipe_kursus'],
        jenisKursusId: json['jenis_kursus_id'],
        jenisKursus: json['jenis_kursus'],
        instansiId: json['instansi_id'],
        instansi: json['instansi'],
      );
}
