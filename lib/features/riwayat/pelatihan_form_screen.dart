import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/shimmer_box.dart';
import 'riwayat_provider.dart';

class PelatihanFormScreen extends StatefulWidget {
  const PelatihanFormScreen({super.key});

  @override
  State<PelatihanFormScreen> createState() => _PelatihanFormScreenState();
}

class _PelatihanFormScreenState extends State<PelatihanFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final _namaController = TextEditingController();
  final _bidangController = TextEditingController();
  final _penyelenggaraController = TextEditingController();
  final _durasiController = TextEditingController();
  final _noSertifikatController = TextEditingController();

  // Selected state
  int? _bentukId;
  int? _tipeId;
  int? _jenisId;
  int? _instansiId;

  DateTime? _mulai;
  DateTime? _akhir;
  DateTime? _tglSertifikat;
  File? _sertifikat;
  String? _sertifikatFileName;
  bool _isPdf = false;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RiwayatProvider>().loadPelatihanOptions().then((_) {
        setState(() {
          _initialized = true;
        });
      });
    });
  }

  @override
  void dispose() {
    _namaController.dispose();
    _bidangController.dispose();
    _penyelenggaraController.dispose();
    _durasiController.dispose();
    _noSertifikatController.dispose();
    super.dispose();
  }

  Future<void> _pickMulai() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _mulai ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.red),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _mulai = picked;
        if (_akhir != null && _akhir!.isBefore(picked)) {
          _akhir = picked;
        }
      });
    }
  }

  Future<void> _pickAkhir() async {
    if (_mulai == null) {
      _showSnack('Pilih tanggal mulai terlebih dahulu.', success: false);
      return;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: _akhir ?? _mulai!,
      firstDate: _mulai!,
      lastDate: DateTime(DateTime.now().year + 5),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.red),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _akhir = picked);
    }
  }

  Future<void> _pickTglSertifikat() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _tglSertifikat ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: now,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.red),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _tglSertifikat = picked);
    }
  }

  Future<void> _pickSertifikat() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        final fileName = result.files.single.name;
        final isPdf = fileName.toLowerCase().endsWith('.pdf');

        setState(() {
          _sertifikat = File(path);
          _sertifikatFileName = fileName;
          _isPdf = isPdf;
        });
      }
    } catch (e) {
      _showSnack('Gagal memilih berkas sertifikat: $e', success: false);
    }
  }

  void _showSnack(String message, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.white)),
        backgroundColor: success ? AppColors.success : AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      _showSnack('Mohon periksa kembali input form yang belum diisi dengan benar.', success: false);
      return;
    }
    if (_mulai == null || _akhir == null) {
      _showSnack('Tanggal mulai dan tanggal akhir wajib diisi.', success: false);
      return;
    }
    if (_tglSertifikat == null) {
      _showSnack('Tanggal sertifikat wajib diisi.', success: false);
      return;
    }
    if (_sertifikat == null) {
      _showSnack('Berkas sertifikat (PDF/Gambar) wajib diunggah.', success: false);
      return;
    }

    try {
      await context.read<RiwayatProvider>().submitPelatihan(
            namaPelatihan: _namaController.text.trim(),
            penyelenggara: _penyelenggaraController.text.trim(),
            tanggalMulai: _mulai!,
            tanggalAkhir: _akhir!,
            durasiJp: int.parse(_durasiController.text),
            bentukPelatihanId: _bentukId!,
            tipeKursusId: _tipeId!,
            jenisKursusId: _jenisId!,
            instansiId: _instansiId!,
            noSertifikat: _noSertifikatController.text.trim(),
            tanggalSertifikat: _tglSertifikat!,
            bidangSdmSpbe: _bidangController.text.trim().isEmpty ? null : _bidangController.text.trim(),
            sertifikatPath: _sertifikat!.path,
          );
      if (mounted) {
        Navigator.pop(context, true);
        _showSnack('Riwayat pelatihan berhasil ditambahkan dan akan diverifikasi Admin.', success: true);
      }
    } catch (e) {
      _showSnack(e is ApiException ? e.friendlyMessage : 'Terjadi kesalahan: $e', success: false);
    }
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.red, letterSpacing: 0.5),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: RichText(
        text: TextSpan(
          text: text,
          style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.black),
          children: [
            if (required)
              const TextSpan(text: ' *', style: TextStyle(color: AppColors.danger)),
          ],
        ),
      ),
    );
  }

  Widget _buildSertifikatPickerBox() {
    final hasFile = _sertifikat != null;

    return GestureDetector(
      onTap: _pickSertifikat,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: hasFile ? const Color(0xFFF0FDF4) : AppColors.creamSoft.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasFile ? const Color(0xFF16A34A) : AppColors.border,
            width: hasFile ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: hasFile
                    ? (_isPdf ? const Color(0xFFDC2626).withOpacity(0.12) : const Color(0xFF16A34A).withOpacity(0.12))
                    : AppColors.grayLight.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                hasFile
                    ? (_isPdf ? Icons.picture_as_pdf_rounded : Icons.image_rounded)
                    : Icons.upload_file_rounded,
                color: hasFile
                    ? (_isPdf ? const Color(0xFFDC2626) : const Color(0xFF16A34A))
                    : AppColors.gray,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasFile ? (_sertifikatFileName ?? 'File Terlampir') : 'Pilih Berkas Sertifikat (PDF / Gambar)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: hasFile ? AppColors.black : const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasFile
                        ? (_isPdf ? 'Dokumen PDF terlampir siap diunggah' : 'Berkas Gambar (JPG/PNG) terlampir')
                        : 'Mendukung format PDF, JPG, JPEG, PNG',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: hasFile ? const Color(0xFF16A34A) : AppColors.gray,
                      fontWeight: hasFile ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            if (hasFile)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF16A34A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RiwayatProvider>();
    final options = provider.pelatihanOptions;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: Text('Tambah Pelatihan', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
      ),
      body: !_initialized || provider.isLoadingOptions
          ? const _LoadingState()
          : options == null
              ? Center(child: Text('Gagal mengambil data master opsi.', style: GoogleFonts.plusJakartaSans()))
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                    children: [
                      // SECTION 1: Informasi Pelatihan
                      _buildSection(
                        title: 'INFORMASI PELATIHAN',
                        children: [
                          _buildLabel('Nama Kursus/Pelatihan', required: true),
                          TextFormField(
                            controller: _namaController,
                            style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
                            decoration: const InputDecoration(hintText: 'Contoh: Pelatihan Keamanan Siber SPBE'),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama pelatihan wajib diisi' : null,
                          ),
                          const SizedBox(height: 14),
                          _buildLabel('Bidang SDM SPBE (Opsional)'),
                          TextFormField(
                            controller: _bidangController,
                            style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
                            decoration: const InputDecoration(hintText: 'Contoh: Manajemen Layanan SPBE'),
                          ),
                          const SizedBox(height: 14),
                          _buildLabel('Bentuk Pelatihan', required: true),
                          DropdownButtonFormField<int>(
                            value: _bentukId,
                            decoration: const InputDecoration(hintText: 'Pilih Bentuk Pelatihan'),
                            isExpanded: true,
                            items: options.bentukPelatihans.map((opt) {
                              return DropdownMenuItem<int>(
                                value: opt.id,
                                child: Text(opt.namaBentuk, style: GoogleFonts.plusJakartaSans(fontSize: 13.5)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                _bentukId = val;
                                _tipeId = null; // Reset tipe when bentuk changes
                              });
                            },
                            validator: (v) => v == null ? 'Bentuk pelatihan wajib dipilih' : null,
                          ),
                          const SizedBox(height: 14),
                          _buildLabel('Tipe Kursus', required: true),
                          DropdownButtonFormField<int>(
                            value: _tipeId,
                            decoration: const InputDecoration(hintText: 'Pilih Tipe Kursus'),
                            isExpanded: true,
                            items: _bentukId == null
                                ? []
                                : options.tipeKursuses
                                    .where((t) => t.bentukPelatihanId == _bentukId)
                                    .map((opt) {
                                    return DropdownMenuItem<int>(
                                      value: opt.id,
                                      child: Text(opt.namaTipe, style: GoogleFonts.plusJakartaSans(fontSize: 13.5)),
                                    );
                                  }).toList(),
                            onChanged: _bentukId == null
                                ? null
                                : (val) {
                                    setState(() => _tipeId = val);
                                  },
                            validator: (v) => v == null ? 'Tipe kursus wajib dipilih' : null,
                          ),
                          const SizedBox(height: 14),
                          _buildLabel('Jenis Kursus', required: true),
                          DropdownButtonFormField<int>(
                            value: _jenisId,
                            decoration: const InputDecoration(hintText: 'Pilih Jenis Kursus'),
                            isExpanded: true,
                            items: options.jenisKursuses.map((opt) {
                              return DropdownMenuItem<int>(
                                value: opt.id,
                                child: Text(opt.namaJenis, style: GoogleFonts.plusJakartaSans(fontSize: 13.5)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() => _jenisId = val);
                            },
                            validator: (v) => v == null ? 'Jenis kursus wajib dipilih' : null,
                          ),
                        ],
                      ),

                      // SECTION 2: Penyelenggara
                      _buildSection(
                        title: 'PENYELENGGARA',
                        children: [
                          _buildLabel('Institusi Penyelenggara', required: true),
                          TextFormField(
                            controller: _penyelenggaraController,
                            style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
                            decoration: const InputDecoration(hintText: 'Contoh: Pusdiklat Kemenkominfo'),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Institusi penyelenggara wajib diisi' : null,
                          ),
                          const SizedBox(height: 14),
                          _buildLabel('Instansi Pengirim', required: true),
                          DropdownButtonFormField<int>(
                            value: _instansiId,
                            decoration: const InputDecoration(hintText: 'Pilih Instansi Pengirim'),
                            isExpanded: true,
                            items: options.instansis.map((opt) {
                              return DropdownMenuItem<int>(
                                value: opt.id,
                                child: Text(opt.namaInstansi, style: GoogleFonts.plusJakartaSans(fontSize: 13.5)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() => _instansiId = val);
                            },
                            validator: (v) => v == null ? 'Instansi pengirim wajib dipilih' : null,
                          ),
                        ],
                      ),

                      // SECTION 3: Jadwal & Durasi
                      _buildSection(
                        title: 'JADWAL & DURASI',
                        children: [
                          _buildLabel('Tanggal Mulai', required: true),
                          GestureDetector(
                            onTap: _pickMulai,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: AppColors.creamSoft.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.grayLight),
                                  const SizedBox(width: 12),
                                  Text(
                                    _mulai == null ? 'Pilih Tanggal Mulai' : Formatters.tanggalPendek(_mulai!),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: _mulai == null ? AppColors.grayLight : AppColors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _buildLabel('Tanggal Akhir', required: true),
                          GestureDetector(
                            onTap: _pickAkhir,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: AppColors.creamSoft.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.grayLight),
                                  const SizedBox(width: 12),
                                  Text(
                                    _akhir == null ? 'Pilih Tanggal Akhir' : Formatters.tanggalPendek(_akhir!),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: _akhir == null ? AppColors.grayLight : AppColors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _buildLabel('Durasi (Jam Pelajaran / JP)', required: true),
                          TextFormField(
                            controller: _durasiController,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
                            decoration: const InputDecoration(hintText: 'Contoh: 32'),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Durasi JP wajib diisi';
                              final val = int.tryParse(v);
                              if (val == null || val <= 0) return 'Durasi harus berupa angka positif';
                              return null;
                            },
                          ),
                        ],
                      ),

                      // SECTION 4: Sertifikat
                      _buildSection(
                        title: 'SERTIFIKAT',
                        children: [
                          _buildLabel('Nomor Sertifikat', required: true),
                          TextFormField(
                            controller: _noSertifikatController,
                            style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
                            decoration: const InputDecoration(hintText: 'Contoh: CERT/SPBE/2026/001'),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Nomor sertifikat wajib diisi' : null,
                          ),
                          const SizedBox(height: 14),
                          _buildLabel('Tanggal Terbit Sertifikat', required: true),
                          GestureDetector(
                            onTap: _pickTglSertifikat,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: AppColors.creamSoft.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.grayLight),
                                  const SizedBox(width: 12),
                                  Text(
                                    _tglSertifikat == null ? 'Pilih Tanggal Sertifikat' : Formatters.tanggalPendek(_tglSertifikat!),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: _tglSertifikat == null ? AppColors.grayLight : AppColors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _buildLabel('File Arsip Sertifikat (PDF / Gambar)', required: true),
                          _buildSertifikatPickerBox(),
                        ],
                      ),

                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: provider.isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: provider.isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                              )
                            : Text(
                                'Simpan & Kirim Pelatihan',
                                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14.5),
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: List.generate(
        3,
        (index) => const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: ShimmerBox(height: 180, borderRadius: BorderRadius.all(Radius.circular(20))),
        ),
      ),
    );
  }
}
