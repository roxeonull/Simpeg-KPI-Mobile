import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/models/jenis_ketidakhadiran.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/bouncing_button.dart';
import 'dinas_luar_provider.dart';

class DinasLuarFormScreen extends StatefulWidget {
  const DinasLuarFormScreen({super.key});

  @override
  State<DinasLuarFormScreen> createState() => _DinasLuarFormScreenState();
}

class _DinasLuarFormScreenState extends State<DinasLuarFormScreen> {
  final _formKey = GlobalKey<FormState>();

  JenisKetidakhadiran? _selectedJenis;
  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;

  final _lokasiController = TextEditingController();
  final _alasanController = TextEditingController();

  File? _selectedFile;
  String? _fileName;

  @override
  void initState() {
    super.initState();
    _tanggalMulai = DateTime.now();
    _tanggalSelesai = DateTime.now();
  }

  @override
  void dispose() {
    _lokasiController.dispose();
    _alasanController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 180)),
      initialDateRange: DateTimeRange(
        start: _tanggalMulai ?? DateTime.now(),
        end: _tanggalSelesai ?? DateTime.now(),
      ),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.red,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _tanggalMulai = picked.start;
        _tanggalSelesai = picked.end;
      });
    }
  }

  Future<void> _pickSptFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _fileName = result.files.single.name;
        });
      }
    } catch (e) {
      debugPrint("Error picking SPT file: $e");
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedJenis == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pilih jenis ketidakhadiran / tugas.', style: GoogleFonts.plusJakartaSans()),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final provider = context.read<DinasLuarProvider>();

    final tglMulaiStr = DateFormat('yyyy-MM-dd').format(_tanggalMulai!);
    final tglSelesaiStr = DateFormat('yyyy-MM-dd').format(_tanggalSelesai!);

    try {
      await provider.submitDinasLuar(
        jenisKetidakhadiranId: _selectedJenis!.id,
        tanggalMulai: tglMulaiStr,
        tanggalSelesai: tglSelesaiStr,
        lokasiTugas: _lokasiController.text.trim(),
        alasan: _alasanController.text.trim(),
        fileSpt: _selectedFile,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pengajuan Dinas Luar / WFA berhasil dikirim!', style: GoogleFonts.plusJakartaSans()),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.friendlyMessage, style: GoogleFonts.plusJakartaSans()),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e', style: GoogleFonts.plusJakartaSans()),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DinasLuarProvider>();
    final options = provider.jenisOptions;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: BouncingButton(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
              ),
              child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A), size: 20),
            ),
          ),
        ),
        title: Text(
          'Form Dinas Luar / WFA',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Banner Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF3B82F6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.business_center_rounded, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Jika pengajuan disetujui atasan, presensi Anda akan melonggarkan batas geofence kantor pada tanggal tugas.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF1E40AF),
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 1. Jenis Ketidakhadiran Dropdown
              Text(
                'Jenis Tugas / Ketidakhadiran *',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<JenisKetidakhadiran>(
                value: _selectedJenis,
                isExpanded: true,
                decoration: InputDecoration(
                  hintText: '— Pilih Jenis Tugas —',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
                  ),
                ),
                items: options.map((j) {
                  return DropdownMenuItem(
                    value: j,
                    child: Text(
                      j.nama,
                      style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w600),
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedJenis = val),
              ),

              const SizedBox(height: 16),

              // 2. Tanggal Range Picker
              Text(
                'Tanggal Pelaksanaan *',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              BouncingButton(
                onTap: _pickDateRange,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded, color: AppColors.red, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _tanggalMulai == null
                              ? 'Pilih Tanggal'
                              : (_tanggalMulai == _tanggalSelesai
                                  ? DateFormat('dd MMMM yyyy', 'id_ID').format(_tanggalMulai!)
                                  : '${DateFormat('dd MMM yyyy', 'id_ID').format(_tanggalMulai!)} s/d ${DateFormat('dd MMM yyyy', 'id_ID').format(_tanggalSelesai!)}'),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 3. Lokasi Tugas
              Text(
                'Lokasi Penugasan *',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _lokasiController,
                decoration: InputDecoration(
                  hintText: 'Misal: Bandung / Home Office WFA / Kantor KPI Daerah',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Lokasi penugasan wajib diisi' : null,
              ),

              const SizedBox(height: 16),

              // 4. Uraian Alasan / Tugas
              Text(
                'Uraian Tugas & Alasan *',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _alasanController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Jelaskan rincian agenda tugas luar atau WFA...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Uraian tugas wajib diisi' : null,
              ),

              const SizedBox(height: 16),

              // 5. Upload Document SPT
              Text(
                'Lampiran Surat Perintah Tugas (SPT) / Berkas (Opsional)',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              BouncingButton(
                onTap: _pickSptFile,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.attach_file_rounded, color: AppColors.red, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _fileName ?? 'Pilih file SPT (PDF/JPG/PNG)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: _fileName != null ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                            fontWeight: _fileName != null ? FontWeight.w700 : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_selectedFile != null)
                        IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.red),
                          onPressed: () => setState(() {
                            _selectedFile = null;
                            _fileName = null;
                          }),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Submit Button
              BouncingButton(
                onTap: () {
                  if (!provider.isSubmitting) {
                    _submit();
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: AppColors.red,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.red.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: provider.isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            'Kirim Pengajuan Dinas Luar',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
