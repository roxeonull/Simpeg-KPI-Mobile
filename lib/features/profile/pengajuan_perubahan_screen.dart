import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/fade_slide_in.dart';
import '../../core/widgets/shimmer_box.dart';
import '../../core/models/pegawai_detail.dart';
import 'profile_provider.dart';

class PengajuanPerubahanScreen extends StatelessWidget {
  const PengajuanPerubahanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileProvider()..loadDetailPegawai(),
      child: Scaffold(
        backgroundColor: AppColors.cream,
        body: Consumer<ProfileProvider>(
          builder: (context, provider, _) {
            if (provider.isLoadingDetail || provider.pegawaiDetail == null) {
              return Scaffold(
                backgroundColor: AppColors.cream,
                appBar: AppBar(title: const Text('Ajukan Perubahan Data')),
                body: const _ShimmerLoading(),
              );
            }
            return _FormBody(pegawaiDetail: provider.pegawaiDetail!);
          },
        ),
      ),
    );
  }
}

class _FormBody extends StatefulWidget {
  final PegawaiDetail pegawaiDetail;
  const _FormBody({required this.pegawaiDetail});

  @override
  State<_FormBody> createState() => _FormBodyState();
}

class _FormBodyState extends State<_FormBody> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Whitelist field mapping:
  final _fieldOptions = const {
    'no_hp': 'No. HP Utama',
    'email_pribadi': 'Email Pribadi',
    'alamat': 'Alamat Lengkap',
    'nama_panggilan': 'Nama Panggilan',
    'status_marital': 'Status Pernikahan',
    'golongan_darah': 'Golongan Darah',
    'agama': 'Agama',
    'hobi': 'Hobi',
    'koordinat_domisili': 'Koordinat Titik Domisili WFH',
  };

  final _maritalOptions = const ['Belum Kawin', 'Kawin', 'Cerai Hidup', 'Cerai Mati'];
  final _bloodOptions = const ['A', 'B', 'AB', 'O'];
  final _religionOptions = const ['Islam', 'Kristen', 'Katolik', 'Hindu', 'Buddha', 'Khonghucu'];

  // Original values for comparison:
  late final String _origNoHp;
  late final String _origEmailPribadi;
  late final String _origAlamat;
  late final String _origNamaPanggilan;
  late final String _origStatusMarital;
  late final String _origGolonganDarah;
  late final String _origAgama;
  late final String _origHobi;
  late final String _origKoordinatDomisili;

  // Controllers / States for editable fields:
  late final TextEditingController _noHpController;
  late final TextEditingController _emailPribadiController;
  late final TextEditingController _alamatController;
  late final TextEditingController _namaPanggilanController;
  String? _statusMarital;
  String? _golonganDarah;
  String? _agama;
  late final TextEditingController _hobiController;
  late final TextEditingController _koordinatDomisiliController;
  bool _isFetchingGps = false;

  @override
  void initState() {
    super.initState();
    final d = widget.pegawaiDetail;
    _origNoHp = d.noHp ?? '';
    _origEmailPribadi = d.emailPribadi ?? '';
    _origAlamat = d.alamat ?? '';
    _origNamaPanggilan = d.namaPanggilan ?? '';
    _origStatusMarital = d.statusMarital ?? '';
    _origGolonganDarah = d.golonganDarah ?? '';
    _origAgama = d.agama ?? '';
    _origHobi = d.hobi ?? '';
    _origKoordinatDomisili = d.koordinatDomisili ?? '';

    _noHpController = TextEditingController(text: _origNoHp);
    _emailPribadiController = TextEditingController(text: _origEmailPribadi);
    _alamatController = TextEditingController(text: _origAlamat);
    _namaPanggilanController = TextEditingController(text: _origNamaPanggilan);
    _statusMarital = _origStatusMarital.isEmpty ? null : _origStatusMarital;
    _golonganDarah = _origGolonganDarah.isEmpty ? null : _origGolonganDarah;
    _agama = _origAgama.isEmpty ? null : _origAgama;
    _hobiController = TextEditingController(text: _origHobi);
    _koordinatDomisiliController = TextEditingController(text: _origKoordinatDomisili);

    // Listeners to rebuild and highlight changes:
    _noHpController.addListener(_onFieldChanged);
    _emailPribadiController.addListener(_onFieldChanged);
    _alamatController.addListener(_onFieldChanged);
    _namaPanggilanController.addListener(_onFieldChanged);
    _hobiController.addListener(_onFieldChanged);
    _koordinatDomisiliController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  Future<void> _getCurrentGpsForDomisili() async {
    setState(() => _isFetchingGps = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever || perm == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Izin lokasi (GPS) ditolak. Silakan ketik koordinat secara manual.', style: GoogleFonts.plusJakartaSans(fontSize: 13)),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final coordsText = "${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}";
      setState(() {
        _koordinatDomisiliController.text = coordsText;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Koordinat domisili berhasil diambil dari GPS HP: $coordsText', style: GoogleFonts.plusJakartaSans(fontSize: 13)),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil lokasi GPS: $e', style: GoogleFonts.plusJakartaSans(fontSize: 13)),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isFetchingGps = false);
    }
  }

  @override
  void dispose() {
    _noHpController.dispose();
    _emailPribadiController.dispose();
    _alamatController.dispose();
    _namaPanggilanController.dispose();
    _hobiController.dispose();
    _koordinatDomisiliController.dispose();
    super.dispose();
  }

  bool _hasChanges() {
    return _countChanges() > 0;
  }

  int _countChanges() {
    int count = 0;
    if (_noHpController.text.trim() != _origNoHp) count++;
    if (_emailPribadiController.text.trim() != _origEmailPribadi) count++;
    if (_alamatController.text.trim() != _origAlamat) count++;
    if (_namaPanggilanController.text.trim() != _origNamaPanggilan) count++;
    if ((_statusMarital ?? '') != _origStatusMarital) count++;
    if ((_golonganDarah ?? '') != _origGolonganDarah) count++;
    if ((_agama ?? '') != _origAgama) count++;
    if (_hobiController.text.trim() != _origHobi) count++;
    if (_koordinatDomisiliController.text.trim() != _origKoordinatDomisili) count++;
    return count;
  }

  Widget _buildChangeSummaryBanner(int count) {
    if (count == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF59E0B), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFFF59E0B),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$count Perubahan Data Terdeteksi — Siap Dikirim ke Admin',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF92400E),
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _getInputDecoration(String label, String originalValue, String currentValue) {
    final isChanged = originalValue != currentValue;
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.plusJakartaSans(
        color: isChanged ? const Color(0xFFD97706) : const Color(0xFF64748B),
        fontWeight: isChanged ? FontWeight.w700 : FontWeight.w500,
        fontSize: 13.5,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: isChanged ? const Color(0xFFF59E0B) : AppColors.border,
          width: isChanged ? 1.8 : 1.0,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: isChanged ? const Color(0xFFF59E0B) : AppColors.red,
          width: 1.8,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          initialValue: (value == null || value.isEmpty) ? '—' : value,
          enabled: false,
          style: GoogleFonts.plusJakartaSans(color: const Color(0xFF64748B), fontSize: 13.5),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.plusJakartaSans(color: AppColors.grayLight, fontSize: 13.5),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(12),
            ),
            fillColor: AppColors.border.withOpacity(0.15),
            filled: true,
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'Hubungi Admin untuk mengubah data ini',
            style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: AppColors.grayLight, fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Mohon periksa kembali input form yang belum diisi dengan benar.'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final Map<String, String> changes = {};
    if (_noHpController.text.trim() != _origNoHp) {
      changes['no_hp'] = _noHpController.text.trim();
    }
    if (_emailPribadiController.text.trim() != _origEmailPribadi) {
      changes['email_pribadi'] = _emailPribadiController.text.trim();
    }
    if (_alamatController.text.trim() != _origAlamat) {
      changes['alamat'] = _alamatController.text.trim();
    }
    if (_namaPanggilanController.text.trim() != _origNamaPanggilan) {
      changes['nama_panggilan'] = _namaPanggilanController.text.trim();
    }
    if ((_statusMarital ?? '') != _origStatusMarital) {
      changes['status_marital'] = _statusMarital ?? '';
    }
    if ((_golonganDarah ?? '') != _origGolonganDarah) {
      changes['golongan_darah'] = _golonganDarah ?? '';
    }
    if ((_agama ?? '') != _origAgama) {
      changes['agama'] = _agama ?? '';
    }
    if (_hobiController.text.trim() != _origHobi) {
      changes['hobi'] = _hobiController.text.trim();
    }
    if (_koordinatDomisiliController.text.trim() != _origKoordinatDomisili) {
      changes['koordinat_domisili'] = _koordinatDomisiliController.text.trim();
    }

    if (changes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tidak ada perubahan data untuk dikirim.'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Show Progress Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(color: AppColors.red),
              SizedBox(width: 20),
              Expanded(child: Text('Mengirim pengajuan perubahan data...')),
            ],
          ),
        ),
      ),
    );

    final successes = <String>[];
    final failures = <String>[];
    final provider = context.read<ProfileProvider>();

    await Future.wait(changes.entries.map((entry) async {
      try {
        await provider.ajukan(field: entry.key, nilaiBaru: entry.value);
        successes.add(_fieldOptions[entry.key] ?? entry.key);
      } catch (e) {
        final msg = e is ApiException ? e.friendlyMessage : e.toString().replaceFirst('Exception: ', '');
        failures.add('${_fieldOptions[entry.key] ?? entry.key} ($msg)');
      }
    }));

    if (mounted) {
      Navigator.pop(context); // Pop Progress Dialog
      setState(() => _isSubmitting = false);

      // Show Result Confirmation Dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Ringkasan Pengajuan', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (successes.isNotEmpty) ...[
                const Text('Pengajuan Berhasil Dikirim:', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.success)),
                const SizedBox(height: 6),
                ...successes.map((e) => Text('· $e', style: const TextStyle(fontSize: 13))),
                const SizedBox(height: 12),
              ],
              if (failures.isNotEmpty) ...[
                const Text('Pengajuan Gagal Dikirim:', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.danger)),
                const SizedBox(height: 6),
                ...failures.map((e) => Text('· $e', style: const TextStyle(fontSize: 13, color: AppColors.danger))),
                const SizedBox(height: 12),
              ],
              const Text('Pengajuan yang berhasil terkirim akan ditinjau oleh Admin terlebih dahulu.', style: TextStyle(fontSize: 11, color: AppColors.gray)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx); // Pop Confirmation Dialog
                if (successes.isNotEmpty) {
                  Navigator.pop(context); // Return to Profile
                }
              },
              child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.pegawaiDetail;
    final hasChanges = _hasChanges();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          title: const Text('Ajukan Ubah Data'),
          bottom: const TabBar(
            indicatorColor: AppColors.red,
            indicatorWeight: 3,
            labelColor: AppColors.red,
            unselectedLabelColor: AppColors.gray,
            labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
            tabs: [
              Tab(text: 'Personal'),
              Tab(text: 'Kepegawaian'),
              Tab(text: 'Dokumen'),
            ],
          ),
        ),
        body: Form(
          key: _formKey,
          child: TabBarView(
            children: [
              // Tab 1: Personal
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                child: Column(
                  children: [
                    _buildChangeSummaryBanner(_countChanges()),
                    FadeSlideIn(
                      child: _SectionCard(
                        title: 'Identitas Pribadi',
                        children: [
                          _buildReadOnlyField('Nama Lengkap (Tanpa Gelar)', d.nama),
                          _buildReadOnlyField('Gelar Depan', d.gelarDepan),
                          _buildReadOnlyField('Gelar Belakang', d.gelarBelakang),
                          
                          // nama_panggilan (Editable)
                          TextFormField(
                            controller: _namaPanggilanController,
                            decoration: _getInputDecoration('Nama Panggilan', _origNamaPanggilan, _namaPanggilanController.text.trim()),
                          ),

                          _buildReadOnlyField('Tempat Lahir', d.tempatLahir),
                          _buildReadOnlyField('Tanggal Lahir', d.tanggalLahir),
                          _buildReadOnlyField('Jenis Kelamin', d.jenisKelamin == 'L' ? 'Laki-laki' : (d.jenisKelamin == 'P' ? 'Perempuan' : null)),
                          
                          // golongan_darah (Editable Dropdown)
                          DropdownButtonFormField<String>(
                            value: _golonganDarah,
                            decoration: _getInputDecoration('Golongan Darah', _origGolonganDarah, _golonganDarah ?? ''),
                            items: _bloodOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
                            onChanged: (v) => setState(() => _golonganDarah = v),
                          ),

                          // agama (Editable Dropdown)
                          DropdownButtonFormField<String>(
                            value: _agama,
                            decoration: _getInputDecoration('Agama', _origAgama, _agama ?? ''),
                            items: _religionOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
                            onChanged: (v) => setState(() => _agama = v),
                          ),

                          // status_marital (Editable Dropdown)
                          DropdownButtonFormField<String>(
                            value: _statusMarital,
                            decoration: _getInputDecoration('Status Pernikahan', _origStatusMarital, _statusMarital ?? ''),
                            items: _maritalOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
                            onChanged: (v) => setState(() => _statusMarital = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeSlideIn(
                      index: 1,
                      child: _SectionCard(
                        title: 'Pendidikan Terakhir',
                        children: [
                          _buildReadOnlyField('Pendidikan Ringkasan', d.pendidikanTerakhir),
                          _buildReadOnlyField('Jurusan Pendidikan', d.jurusanPendidikan),
                          _buildReadOnlyField('Universitas', d.universitas),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeSlideIn(
                      index: 2,
                      child: _SectionCard(
                        title: 'Kontak',
                        children: [
                          _buildReadOnlyField('Email Resmi', d.email),
                          
                          // email_pribadi (Editable)
                          TextFormField(
                            controller: _emailPribadiController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _getInputDecoration('Email Pribadi', _origEmailPribadi, _emailPribadiController.text.trim()),
                            validator: (v) {
                              if (v != null && v.trim().isNotEmpty) {
                                final reg = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                                if (!reg.hasMatch(v.trim())) {
                                  return 'Format email tidak valid';
                                }
                              }
                              return null;
                            },
                          ),

                          // no_hp (Editable)
                          TextFormField(
                            controller: _noHpController,
                            keyboardType: TextInputType.phone,
                            decoration: _getInputDecoration('No. HP Utama', _origNoHp, _noHpController.text.trim()),
                            validator: (v) {
                              if (_noHpController.text.trim() != _origNoHp && (v == null || v.trim().isEmpty)) {
                                return 'No. HP wajib diisi jika diubah';
                              }
                              return null;
                            },
                          ),

                          _buildReadOnlyField('No. Telepon Tambahan', d.telepon),
                          _buildReadOnlyField('Fax', d.fax),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeSlideIn(
                      index: 3,
                      child: _SectionCard(
                        title: 'Alamat Lengkap',
                        children: [
                          // alamat (Editable)
                          TextFormField(
                            controller: _alamatController,
                            maxLines: 3,
                            decoration: _getInputDecoration('Alamat Lengkap', _origAlamat, _alamatController.text.trim()),
                            validator: (v) {
                              if (_alamatController.text.trim() != _origAlamat && (v == null || v.trim().isEmpty)) {
                                return 'Alamat wajib diisi jika diubah';
                              }
                              return null;
                            },
                          ),

                          // koordinat_domisili (Editable text / manual type + GPS button)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: _koordinatDomisiliController,
                                style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
                                decoration: _getInputDecoration('Koordinat Titik Domisili WFH (Lat, Lng)', _origKoordinatDomisili, _koordinatDomisiliController.text.trim()).copyWith(
                                  hintText: 'Contoh: -6.2088, 106.8456',
                                  helperText: 'Bisa diketik manual atau tekan tombol GPS di bawah',
                                  helperStyle: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.gray),
                                ),
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                onPressed: _isFetchingGps ? null : _getCurrentGpsForDomisili,
                                icon: _isFetchingGps
                                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.red))
                                    : const Icon(Icons.my_location_rounded, size: 18, color: AppColors.red),
                                label: Text(
                                  _isFetchingGps ? 'Mengambil GPS HP...' : 'Ambil Koordinat Rumah Saat Ini (GPS)',
                                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 12.5, color: AppColors.red),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  side: const BorderSide(color: AppColors.redSoft, width: 1.5),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ],
                          ),

                          _buildReadOnlyField('Kelurahan', d.kelurahan),
                          _buildReadOnlyField('Kecamatan', d.kecamatan),
                          _buildReadOnlyField('Kota / Kabupaten', d.kota),
                          _buildReadOnlyField('Provinsi', d.provinsi),
                          _buildReadOnlyField('Kode Pos', d.kodePos),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Tab 2: Kepegawaian (All Read-Only)
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                child: Column(
                  children: [
                    FadeSlideIn(
                      child: _SectionCard(
                        title: 'Kedudukan & Status Dinas',
                        children: [
                          _buildReadOnlyField('NIP', d.nip),
                          _buildReadOnlyField('Tipe Pegawai', d.tipePegawai),
                          _buildReadOnlyField('Status Kepegawaian', d.statusKepegawaian),
                          _buildReadOnlyField('Status Aktif', d.statusAktif.toUpperCase()),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeSlideIn(
                      index: 1,
                      child: _SectionCard(
                        title: 'Jabatan & Unit Kerja',
                        children: [
                          _buildReadOnlyField('Jabatan Utama', d.jabatan),
                          _buildReadOnlyField('Unit Kerja', d.unit),
                          _buildReadOnlyField('Atasan Langsung', d.atasan),
                          _buildReadOnlyField('Jabatan PLT', d.jabatanPlt),
                          _buildReadOnlyField('Jabatan PLH', d.jabatanPlh),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeSlideIn(
                      index: 2,
                      child: _SectionCard(
                        title: 'Riwayat Kepangkatan & TMT',
                        children: [
                          _buildReadOnlyField('Pangkat / Golongan', d.pangkatGolongan),
                          _buildReadOnlyField('TMT Kepangkatan', d.tmtKepangkatan),
                          _buildReadOnlyField('TMT CPNS', d.tmtCpns),
                          _buildReadOnlyField('TMT PNS', d.tmtPns),
                          _buildReadOnlyField('TMT Jabatan (TMT Sistem)', d.tmt),
                          _buildReadOnlyField('TMT Pangkat Berikutnya', d.tmtPangkatBerikutnya),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeSlideIn(
                      index: 3,
                      child: _SectionCard(
                        title: 'Sistem & Finansial',
                        children: [
                          _buildReadOnlyField('Status Portal Kepegawaian', d.portalStatus),
                          _buildReadOnlyField('Status SIMPATIK', d.simpatikStatus),
                          _buildReadOnlyField('Mendapat Tunkin', d.mendapatTunkin ? 'YA' : 'TIDAK'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeSlideIn(
                      index: 4,
                      child: _SectionCard(
                        title: 'Masa Kerja',
                        children: [
                          _buildReadOnlyField('Masa Kerja Keseluruhan', d.masaKerjaKeseluruhan),
                          _buildReadOnlyField('Masa Kerja Golongan', d.masaKerjaGolongan),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Tab 3: Dokumen & Lain-Lain
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                child: Column(
                  children: [
                    FadeSlideIn(
                      child: _SectionCard(
                        title: 'Data Lain-Lain',
                        children: [
                          _buildReadOnlyField('No. KTP (NIK)', d.noKtp),
                          _buildReadOnlyField('No. Kartu Keluarga', d.noKartuKeluarga),
                          _buildReadOnlyField('BKN PNS ID', d.bknPnsId),
                          _buildReadOnlyField('Tinggi Badan', d.tinggiBadan != null ? '${d.tinggiBadan} cm' : null),
                          _buildReadOnlyField('Berat Badan', d.beratBadan != null ? '${d.beratBadan} kg' : null),
                          _buildReadOnlyField('Jenis Rambut', d.jenisRambut),
                          _buildReadOnlyField('Bentuk Muka', d.bentukMuka),
                          _buildReadOnlyField('Warna Kulit', d.warnaKulit),
                          _buildReadOnlyField('Ciri Khas', d.ciriKhas),
                          _buildReadOnlyField('Cacat Tubuh', d.cacatTubuh),
                          
                          // hobi (Editable)
                          TextFormField(
                            controller: _hobiController,
                            decoration: _getInputDecoration('Hobi', _origHobi, _hobiController.text.trim()),
                          ),

                          _buildReadOnlyField('No. Karis / Karsu', d.noKarisKarsu),
                          _buildReadOnlyField('No. BPJS Kesehatan', d.noBpjsKesehatan),
                          _buildReadOnlyField('No. BPJS Ketenagakerjaan', d.noBpjsKetenagakerjaan),
                          _buildReadOnlyField('No. Taspen', d.noTaspen),
                          _buildReadOnlyField('No. NPWP', d.noNpwp),
                          _buildReadOnlyField('No. Kartu ASN Virtual', d.noKartuAsnVirtual),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeSlideIn(
                      index: 1,
                      child: _SectionCard(
                        title: 'Berkas Dokumen Digital (Read-Only)',
                        children: [
                          _buildReadOnlyDocumentTile('Foto Profil', d.fotoUrl),
                          _buildReadOnlyDocumentTile('Arsip KTP', d.fileKtpUrl),
                          _buildReadOnlyDocumentTile('Arsip SK Kepegawaian', d.fileSkUrl),
                          _buildReadOnlyDocumentTile('Arsip Kartu Keluarga', d.fileKartuKeluargaUrl),
                          _buildReadOnlyDocumentTile('Arsip Karis / Karsu', d.fileKarisKarsuUrl),
                          _buildReadOnlyDocumentTile('Arsip BPJS Kesehatan', d.fileBpjsKesehatanUrl),
                          _buildReadOnlyDocumentTile('Arsip BPJS Ketenagakerjaan', d.fileBpjsKetenagakerjaanUrl),
                          _buildReadOnlyDocumentTile('Arsip Taspen', d.fileTaspenUrl),
                          _buildReadOnlyDocumentTile('Arsip NPWP', d.fileNpwpUrl),
                          _buildReadOnlyDocumentTile('Arsip Kartu ASN Virtual', d.fileKartuAsnVirtualUrl),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomSheet: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.border)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: (hasChanges && !_isSubmitting) ? _submit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.grayLight.withOpacity(0.3),
              disabledForegroundColor: AppColors.gray,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: Text(
              hasChanges ? 'Kirim (${_countChanges()}) Pengajuan Perubahan Data' : 'Tidak Ada Perubahan Untuk Dikirim',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyDocumentTile(String label, String? url) {
    final hasFile = url != null && url.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              Text(
                hasFile ? 'Tersedia' : 'Kosong',
                style: TextStyle(
                  fontSize: 11,
                  color: hasFile ? AppColors.success : AppColors.gray,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          const Text(
            'Hubungi Admin untuk mengubah berkas ini',
            style: TextStyle(fontSize: 10, color: AppColors.grayLight, fontStyle: FontStyle.italic),
          ),
          const Divider(height: 12),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.red),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: children.length,
            separatorBuilder: (_, __) => Divider(color: AppColors.border.withOpacity(0.5), height: 16),
            itemBuilder: (_, index) => children[index],
          ),
        ],
      ),
    );
  }
}



class _ShimmerLoading extends StatelessWidget {
  const _ShimmerLoading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(width: 100, height: 16),
                const SizedBox(height: 16),
                ...List.generate(4, (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      ShimmerBox(width: 80, height: 10),
                      SizedBox(height: 6),
                      ShimmerBox(width: 160, height: 14),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
