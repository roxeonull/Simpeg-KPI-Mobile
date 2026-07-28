class Absensi {
  final int id;
  final DateTime tanggal;
  final String? jamMasuk;
  final String? jamKeluar;
  final String status;
  final String? keterangan;

  Absensi({
    required this.id,
    required this.tanggal,
    this.jamMasuk,
    this.jamKeluar,
    required this.status,
    this.keterangan,
  });

  factory Absensi.fromJson(Map<String, dynamic> json) => Absensi(
        id: json['id'],
        tanggal: DateTime.parse(json['tanggal']),
        jamMasuk: json['jam_masuk'],
        jamKeluar: json['jam_keluar'],
        status: json['status'],
        keterangan: json['keterangan'],
      );
}
