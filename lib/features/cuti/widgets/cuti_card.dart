import 'package:flutter/material.dart';
import '../../../core/models/cuti.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/status_badge.dart';
import 'cuti_status_helper.dart';

class CutiCard extends StatelessWidget {
  final Cuti cuti;
  final VoidCallback onTap;
  final bool showPegawaiName;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const CutiCard({
    super.key,
    required this.cuti,
    required this.onTap,
    this.showPegawaiName = false,
    this.onApprove,
    this.onReject,
  });

  IconData get _icon {
    switch (cuti.jenisCuti) {
      case 'sakit':
        return Icons.local_hospital_rounded;
      case 'melahirkan':
        return Icons.family_restroom_rounded;
      case 'tahunan':
        return Icons.beach_access_rounded;
      default:
        return Icons.event_note_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasActions = onApprove != null && onReject != null && cuti.statusAtasan == 'menunggu';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(color: AppColors.redSoft, borderRadius: BorderRadius.circular(14)),
                    child: Icon(_icon, color: AppColors.red, size: 19),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showPegawaiName && cuti.namaPegawai != null) ...[
                          Row(
                            children: [
                              const Icon(Icons.person_rounded, size: 14, color: AppColors.red),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  cuti.namaPegawai!,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: AppColors.black),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (cuti.unitPegawai != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                cuti.unitPegawai!,
                                style: const TextStyle(fontSize: 11.5, color: AppColors.gray),
                              ),
                            ),
                          const SizedBox(height: 6),
                        ],
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                Formatters.jenisCuti(cuti.jenisCuti),
                                style: TextStyle(
                                  fontWeight: showPegawaiName ? FontWeight.w600 : FontWeight.w700,
                                  fontSize: showPegawaiName ? 13 : 14,
                                  color: showPegawaiName ? AppColors.gray : AppColors.black,
                                ),
                              ),
                            ),
                            StatusBadge(label: cuti.statusLabel, tone: CutiStatusHelper.tone(cuti.status)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.grayLight),
                            const SizedBox(width: 5),
                            Text(
                              Formatters.rentangTanggal(cuti.tanggalMulai, cuti.tanggalSelesai),
                              style: const TextStyle(fontSize: 12, color: AppColors.gray),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.timelapse_rounded, size: 12, color: AppColors.grayLight),
                            const SizedBox(width: 5),
                            Text('${cuti.jumlahHari} hari', style: const TextStyle(fontSize: 12, color: AppColors.gray)),
                          ],
                        ),
                        if (cuti.alasan != null && cuti.alasan!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            cuti.alasan!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12.5, color: AppColors.grayLight, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.grayLight),
                ],
              ),
              if (hasActions) ...[
                const SizedBox(height: 14),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onReject,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          side: const BorderSide(color: AppColors.red),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.red),
                        label: const Text('Tolak', style: TextStyle(color: AppColors.red, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onApprove,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF15803D),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                        label: const Text('Setujui', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
