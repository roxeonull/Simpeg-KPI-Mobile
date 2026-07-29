import 'package:flutter/material.dart';
import '../../../core/models/cuti.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';

class AtasanApprovalDialogs {
  static Future<String?> showApproveDialog(BuildContext context, Cuti cuti) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Setujui Pengajuan Cuti',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.black),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Apakah Anda yakin ingin menyetujui pengajuan cuti ${cuti.namaPegawai ?? 'anggota tim'} untuk tanggal ${Formatters.rentangTanggal(cuti.tanggalMulai, cuti.tanggalSelesai)} (${cuti.jumlahHari} hari)?',
                  style: const TextStyle(fontSize: 13.5, color: AppColors.gray, height: 1.4),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 13.5),
                  decoration: InputDecoration(
                    labelText: 'Catatan (Opsional)',
                    hintText: 'Tambahkan catatan jika ada...',
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: AppColors.cream,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.red),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(null),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Batal', style: TextStyle(color: AppColors.gray, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF15803D),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Ya, Setujui', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<String?> showRejectDialog(BuildContext context, Cuti cuti) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.redSoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.cancel_rounded, color: AppColors.red, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Tolak Pengajuan Cuti',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.black),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Berikan alasan penolakan pengajuan cuti ${cuti.namaPegawai ?? 'anggota tim'}. Alasan ini akan dikirimkan kepada pegawai.',
                  style: const TextStyle(fontSize: 13.5, color: AppColors.gray, height: 1.4),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 13.5),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Alasan penolakan wajib diisi.';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Alasan Penolakan (Wajib)',
                    hintText: 'Tuliskan alasan penolakan di sini...',
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: AppColors.cream,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.red),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(null),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Batal', style: TextStyle(color: AppColors.gray, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            Navigator.of(ctx).pop(controller.text.trim());
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Tolak Cuti', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
