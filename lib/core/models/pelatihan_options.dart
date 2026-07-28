class BentukPelatihanOption {
  final int id;
  final String namaBentuk;

  BentukPelatihanOption({required this.id, required this.namaBentuk});

  factory BentukPelatihanOption.fromJson(Map<String, dynamic> json) => BentukPelatihanOption(
        id: json['id'],
        namaBentuk: json['nama_bentuk'],
      );
}

class TipeKursusOption {
  final int id;
  final String namaTipe;
  final int bentukPelatihanId;

  TipeKursusOption({required this.id, required this.namaTipe, required this.bentukPelatihanId});

  factory TipeKursusOption.fromJson(Map<String, dynamic> json) => TipeKursusOption(
        id: json['id'],
        namaTipe: json['nama_tipe'],
        bentukPelatihanId: json['bentuk_pelatihan_id'],
      );
}

class JenisKursusOption {
  final int id;
  final String namaJenis;

  JenisKursusOption({required this.id, required this.namaJenis});

  factory JenisKursusOption.fromJson(Map<String, dynamic> json) => JenisKursusOption(
        id: json['id'],
        namaJenis: json['nama_jenis'],
      );
}

class InstansiOption {
  final int id;
  final String namaInstansi;

  InstansiOption({required this.id, required this.namaInstansi});

  factory InstansiOption.fromJson(Map<String, dynamic> json) => InstansiOption(
        id: json['id'],
        namaInstansi: json['nama_instansi'],
      );
}

class PelatihanOptions {
  final List<BentukPelatihanOption> bentukPelatihans;
  final List<TipeKursusOption> tipeKursuses;
  final List<JenisKursusOption> jenisKursuses;
  final List<InstansiOption> instansis;

  PelatihanOptions({
    required this.bentukPelatihans,
    required this.tipeKursuses,
    required this.jenisKursuses,
    required this.instansis,
  });

  factory PelatihanOptions.fromJson(Map<String, dynamic> json) => PelatihanOptions(
        bentukPelatihans: (json['bentuk_pelatihans'] as List)
            .map((e) => BentukPelatihanOption.fromJson(e))
            .toList(),
        tipeKursuses: (json['tipe_kursuses'] as List)
            .map((e) => TipeKursusOption.fromJson(e))
            .toList(),
        jenisKursuses: (json['jenis_kursuses'] as List)
            .map((e) => JenisKursusOption.fromJson(e))
            .toList(),
        instansis: (json['instansis'] as List)
            .map((e) => InstansiOption.fromJson(e))
            .toList(),
      );
}
