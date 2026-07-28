class Pegawai {
  final int id;
  final String nip;
  final String nama;
  final String? jabatan;
  final String? unit;
  final String? statusKepegawaian;
  final String? foto;
  final String? noHp;
  final String? alamat;
  final String? email;

  Pegawai({
    required this.id,
    required this.nip,
    required this.nama,
    this.jabatan,
    this.unit,
    this.statusKepegawaian,
    this.foto,
    this.noHp,
    this.alamat,
    this.email,
  });

  factory Pegawai.fromJson(Map<String, dynamic> json) => Pegawai(
        id: json['id'],
        nip: json['nip'] ?? '',
        nama: json['nama'] ?? '',
        jabatan: json['jabatan'],
        unit: json['unit'],
        statusKepegawaian: json['status_kepegawaian'],
        foto: json['foto'],
        noHp: json['no_hp'],
        alamat: json['alamat'],
        email: json['email'],
      );

  String get initials {
    final parts = nama.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
}
