class JenisKetidakhadiran {
  final int id;
  final String nama;

  JenisKetidakhadiran({
    required this.id,
    required this.nama,
  });

  factory JenisKetidakhadiran.fromJson(Map<String, dynamic> json) {
    return JenisKetidakhadiran(
      id: json['id'] as int,
      nama: json['nama'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
    };
  }
}
