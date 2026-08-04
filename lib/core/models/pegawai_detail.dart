class PegawaiDetail {
  final int id;
  // Personal
  final String nama;
  final String? gelarDepan;
  final String? gelarBelakang;
  final String? namaPanggilan;
  final String? tempatLahir;
  final String? tanggalLahir;
  final String? jenisKelamin;
  final String? golonganDarah;
  final String? agama;
  final String? statusMarital;
  final String? pendidikanTerakhir;
  final String? jurusanPendidikan;
  final String? universitas;
  final String? email;
  final String? emailPribadi;
  final String? noHp;
  final String? telepon;
  final String? fax;
  final String? alamat;
  final String? kelurahan;
  final String? kecamatan;
  final String? kota;
  final String? provinsi;
  final String? kodePos;
  final String? koordinatDomisili;
  final double? latDomisili;
  final double? lngDomisili;

  // Kepegawaian
  final String nip;
  final String? tipePegawai;
  final String statusKepegawaian;
  final String statusAktif;
  final String? jabatan;
  final String? unit;
  final String? atasan;
  final String? jabatanPlt;
  final String? jabatanPlh;
  final String? pangkatGolongan;
  final String? tmtKepangkatan;
  final String? tmtCpns;
  final String? tmtPns;
  final String? tmt;
  final String? tmtPangkatBerikutnya;
  final String? portalStatus;
  final String? simpatikStatus;
  final bool mendapatTunkin;
  final String? masaKerjaKeseluruhan;
  final String? masaKerjaGolongan;

  // Lain-Lain
  final String? noKtp;
  final String? noKartuKeluarga;
  final String? bknPnsId;
  final int? tinggiBadan;
  final int? beratBadan;
  final String? jenisRambut;
  final String? bentukMuka;
  final String? warnaKulit;
  final String? ciriKhas;
  final String? cacatTubuh;
  final String? hobi;
  final String? noKarisKarsu;
  final String? noBpjsKesehatan;
  final String? noBpjsKetenagakerjaan;
  final String? noTaspen;
  final String? noNpwp;
  final String? noKartuAsnVirtual;

  // Dokumen URLs
  final String? fotoUrl;
  final String? fileKtpUrl;
  final String? fileSkUrl;
  final String? fileKartuKeluargaUrl;
  final String? fileKarisKarsuUrl;
  final String? fileBpjsKesehatanUrl;
  final String? fileBpjsKetenagakerjaanUrl;
  final String? fileTaspenUrl;
  final String? fileNpwpUrl;
  final String? fileKartuAsnVirtualUrl;

  PegawaiDetail({
    required this.id,
    required this.nama,
    this.gelarDepan,
    this.gelarBelakang,
    this.namaPanggilan,
    this.tempatLahir,
    this.tanggalLahir,
    this.jenisKelamin,
    this.golonganDarah,
    this.agama,
    this.statusMarital,
    this.pendidikanTerakhir,
    this.jurusanPendidikan,
    this.universitas,
    this.email,
    this.emailPribadi,
    this.noHp,
    this.telepon,
    this.fax,
    this.alamat,
    this.kelurahan,
    this.kecamatan,
    this.kota,
    this.provinsi,
    this.kodePos,
    this.koordinatDomisili,
    this.latDomisili,
    this.lngDomisili,
    required this.nip,
    this.tipePegawai,
    required this.statusKepegawaian,
    required this.statusAktif,
    this.jabatan,
    this.unit,
    this.atasan,
    this.jabatanPlt,
    this.jabatanPlh,
    this.pangkatGolongan,
    this.tmtKepangkatan,
    this.tmtCpns,
    this.tmtPns,
    this.tmt,
    this.tmtPangkatBerikutnya,
    this.portalStatus,
    this.simpatikStatus,
    required this.mendapatTunkin,
    this.masaKerjaKeseluruhan,
    this.masaKerjaGolongan,
    this.noKtp,
    this.noKartuKeluarga,
    this.bknPnsId,
    this.tinggiBadan,
    this.beratBadan,
    this.jenisRambut,
    this.bentukMuka,
    this.warnaKulit,
    this.ciriKhas,
    this.cacatTubuh,
    this.hobi,
    this.noKarisKarsu,
    this.noBpjsKesehatan,
    this.noBpjsKetenagakerjaan,
    this.noTaspen,
    this.noNpwp,
    this.noKartuAsnVirtual,
    this.fotoUrl,
    this.fileKtpUrl,
    this.fileSkUrl,
    this.fileKartuKeluargaUrl,
    this.fileKarisKarsuUrl,
    this.fileBpjsKesehatanUrl,
    this.fileBpjsKetenagakerjaanUrl,
    this.fileTaspenUrl,
    this.fileNpwpUrl,
    this.fileKartuAsnVirtualUrl,
  });

  factory PegawaiDetail.fromJson(Map<String, dynamic> json) => PegawaiDetail(
        id: json['id'],
        nama: json['nama'],
        gelarDepan: json['gelar_depan'],
        gelarBelakang: json['gelar_belakang'],
        namaPanggilan: json['nama_panggilan'],
        tempatLahir: json['tempat_lahir'],
        tanggalLahir: json['tanggal_lahir'],
        jenisKelamin: json['jenis_kelamin'],
        golonganDarah: json['golongan_darah'],
        agama: json['agama'],
        statusMarital: json['status_marital'],
        pendidikanTerakhir: json['pendidikan_terakhir'],
        jurusanPendidikan: json['jurusan_pendidikan'],
        universitas: json['universitas'],
        email: json['email'],
        emailPribadi: json['email_pribadi'],
        noHp: json['no_hp'],
        telepon: json['telepon'],
        fax: json['fax'],
        alamat: json['alamat'],
        kelurahan: json['kelurahan'],
        kecamatan: json['kecamatan'],
        kota: json['kota'],
        provinsi: json['provinsi'],
        kodePos: json['kode_pos'],
        koordinatDomisili: (json['koordinat_domisili'] != null && json['koordinat_domisili'].toString().trim().isNotEmpty)
            ? json['koordinat_domisili'].toString()
            : (json['lat_domisili'] != null && json['lng_domisili'] != null ? "${json['lat_domisili']}, ${json['lng_domisili']}" : null),
        latDomisili: json['lat_domisili'] != null ? double.tryParse(json['lat_domisili'].toString()) : null,
        lngDomisili: json['lng_domisili'] != null ? double.tryParse(json['lng_domisili'].toString()) : null,
        nip: json['nip'],
        tipePegawai: json['tipe_pegawai'],
        statusKepegawaian: json['status_kepegawaian'],
        statusAktif: json['status_aktif'],
        jabatan: json['jabatan'],
        unit: json['unit'],
        atasan: json['atasan'],
        jabatanPlt: json['jabatan_plt'],
        jabatanPlh: json['jabatan_plh'],
        pangkatGolongan: json['pangkat_golongan'],
        tmtKepangkatan: json['tmt_kepangkatan'],
        tmtCpns: json['tmt_cpns'],
        tmtPns: json['tmt_pns'],
        tmt: json['tmt'],
        tmtPangkatBerikutnya: json['tmt_pangkat_berikutnya'],
        portalStatus: json['portal_status'],
        simpatikStatus: json['simpatik_status'],
        mendapatTunkin: json['mendapat_tunkin'] ?? false,
        masaKerjaKeseluruhan: json['masa_kerja_keseluruhan'],
        masaKerjaGolongan: json['masa_kerja_golongan'],
        noKtp: json['no_ktp'],
        noKartuKeluarga: json['no_kartu_keluarga'],
        bknPnsId: json['bkn_pns_id'],
        tinggiBadan: json['tinggi_badan'] is int ? json['tinggi_badan'] : int.tryParse(json['tinggi_badan']?.toString() ?? ''),
        beratBadan: json['berat_badan'] is int ? json['berat_badan'] : int.tryParse(json['berat_badan']?.toString() ?? ''),
        jenisRambut: json['jenis_rambut'],
        bentukMuka: json['bentuk_muka'],
        warnaKulit: json['warna_kulit'],
        ciriKhas: json['ciri_khas'],
        cacatTubuh: json['cacat_tubuh'],
        hobi: json['hobi'],
        noKarisKarsu: json['no_karis_karsu'],
        noBpjsKesehatan: json['no_bpjs_kesehatan'],
        noBpjsKetenagakerjaan: json['no_bpjs_ketenagakerjaan'],
        noTaspen: json['no_taspen'],
        noNpwp: json['no_npwp'],
        noKartuAsnVirtual: json['no_kartu_asn_virtual'],
        fotoUrl: json['foto_url'],
        fileKtpUrl: json['file_ktp_url'],
        fileSkUrl: json['file_sk_url'],
        fileKartuKeluargaUrl: json['file_kartu_keluarga_url'],
        fileKarisKarsuUrl: json['file_karis_karsu_url'],
        fileBpjsKesehatanUrl: json['file_bpjs_kesehatan_url'],
        fileBpjsKetenagakerjaanUrl: json['file_bpjs_ketenagakerjaan_url'],
        fileTaspenUrl: json['file_taspen_url'],
        fileNpwpUrl: json['file_npwp_url'],
        fileKartuAsnVirtualUrl: json['file_kartu_asn_virtual_url'],
      );
}
