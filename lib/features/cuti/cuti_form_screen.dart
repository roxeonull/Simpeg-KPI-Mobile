import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import 'cuti_provider.dart';

class CutiFormScreen extends StatefulWidget {
  const CutiFormScreen({super.key});

  @override
  State<CutiFormScreen> createState() => _CutiFormScreenState();
}

class _CutiFormScreenState extends State<CutiFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _alasanController = TextEditingController();
  final _alamatController = TextEditingController();

  String _jenis = 'tahunan';
  DateTime? _mulai;
  DateTime? _selesai;
  File? _lampiran;
  bool _submitting = false;

  final _jenisOptions = const {
    'tahunan': ('Cuti Tahunan', Icons.beach_access_rounded),
    'sakit': ('Cuti Sakit', Icons.local_hospital_rounded),
    'melahirkan': ('Cuti Melahirkan', Icons.family_restroom_rounded),
    'lainnya': ('Cuti Lainnya', Icons.event_note_rounded),
  };

  int get _jumlahHariKerja {
    if (_mulai == null || _selesai == null) return 0;
    int count = 0;
    DateTime cursor = _mulai!;
    while (!cursor.isAfter(_selesai!)) {
      if (cursor.weekday != DateTime.saturday && cursor.weekday != DateTime.sunday) count++;
      cursor = cursor.add(const Duration(days: 1));
    }
    return count;
  }

  @override
  void dispose() {
    _alasanController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _mulai != null && _selesai != null ? DateTimeRange(start: _mulai!, end: _selesai!) : null,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.red)),
        child: child!,
      ),
    );
    if (range != null) {
      setState(() {
        _mulai = range.start;
        _selesai = range.end;
      });
    }
  }

  Future<void> _pickLampiran() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file != null) setState(() => _lampiran = File(file.path));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      _showSnack('Mohon periksa kembali input form yang belum diisi dengan benar.', success: false);
      return;
    }
    if (_mulai == null || _selesai == null) {
      _showSnack('Pilih tanggal mulai dan selesai cuti.', success: false);
      return;
    }

    setState(() => _submitting = true);
    try {
      await context.read<CutiProvider>().ajukanCuti(
            jenisCuti: _jenis,
            tanggalMulai: _mulai!,
            tanggalSelesai: _selesai!,
            alasan: _alasanController.text.trim(),
            alamatCuti: _alamatController.text.trim(),
            lampiranPath: _lampiran?.path,
          );
      if (mounted) {
        Navigator.of(context).pop(true);
        _showSnack('Pengajuan cuti berhasil dikirim.', success: true);
      }
    } catch (e) {
      _showSnack(e is ApiException ? e.friendlyMessage : 'Terjadi kesalahan: $e', success: false);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showSnack(String message, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? AppColors.success : AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: const Text('Ajukan Cuti')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            const Text('Jenis Cuti', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _jenisOptions.entries.map((entry) {
                final selected = entry.key == _jenis;
                return GestureDetector(
                  onTap: () => setState(() => _jenis = entry.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.red : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: selected ? AppColors.red : AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(entry.value.$2, size: 16, color: selected ? Colors.white : AppColors.gray),
                        const SizedBox(width: 8),
                        Text(entry.value.$1, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : AppColors.black)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text('Periode Cuti', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickDateRange,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.creamSoft,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.date_range_rounded, color: AppColors.red, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _mulai == null
                            ? 'Pilih tanggal mulai dan selesai'
                            : '${Formatters.tanggalPendek(_mulai!)}  →  ${Formatters.tanggalPendek(_selesai!)}',
                        style: TextStyle(fontSize: 13.5, color: _mulai == null ? AppColors.grayLight : AppColors.black, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.grayLight),
                  ],
                ),
              ),
            ),
            if (_mulai != null) ...[
              const SizedBox(height: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Container(
                  key: ValueKey(_jumlahHariKerja),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(color: AppColors.goldSoft, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 15, color: AppColors.gold),
                      const SizedBox(width: 8),
                      Text('Total $_jumlahHariKerja hari kerja (di luar akhir pekan)', style: const TextStyle(fontSize: 12.5, color: AppColors.black, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            const Text('Alasan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 10),
            TextFormField(
              controller: _alasanController,
              maxLines: 4,
              decoration: const InputDecoration(hintText: 'Jelaskan alasan pengajuan cuti Anda...'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Alasan wajib diisi' : null,
            ),
            const SizedBox(height: 24),
            const Text('Alamat Selama Cuti (opsional)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 10),
            TextFormField(
              controller: _alamatController,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Tuliskan alamat lengkap tempat tinggal selama cuti...'),
            ),
            const SizedBox(height: 24),
            const Text('Lampiran (opsional)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickLampiran,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.creamSoft,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.attach_file_rounded, color: AppColors.gray, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _lampiran != null ? _lampiran!.path.split('/').last : 'Unggah dokumen pendukung (opsional)',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, color: AppColors.gray),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                  : const Text('Kirim Pengajuan'),
            ),
          ],
        ),
      ),
    );
  }
}
