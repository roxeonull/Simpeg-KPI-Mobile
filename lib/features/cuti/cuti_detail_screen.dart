import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/models/cuti.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/status_badge.dart';
import '../auth/auth_provider.dart';
import 'cuti_provider.dart';
import 'widgets/atasan_approval_dialogs.dart';
import 'widgets/cuti_status_helper.dart';

class CutiDetailScreen extends StatefulWidget {
  final int cutiId;
  const CutiDetailScreen({super.key, required this.cutiId});

  @override
  State<CutiDetailScreen> createState() => _CutiDetailScreenState();
}

class _CutiDetailScreenState extends State<CutiDetailScreen> {
  Cuti? _cuti;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cuti = await context.read<CutiProvider>().loadDetail(widget.cutiId);
      if (mounted) setState(() => _cuti = cuti);
    } catch (_) {
      if (mounted) setState(() => _error = 'Gagal memuat detail pengajuan cuti.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _approve() async {
    if (_cuti == null) return;
    final catatan = await AtasanApprovalDialogs.showApproveDialog(context, _cuti!);
    if (catatan == null || !mounted) return;

    final provider = context.read<CutiProvider>();
    try {
      await provider.setujuiCutiAtasan(_cuti!.id, catatan: catatan.isEmpty ? null : catatan);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pengajuan cuti ${_cuti?.namaPegawai ?? ''} berhasil disetujui.'),
            backgroundColor: Colors.green,
          ),
        );
        _load();
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.friendlyMessage), backgroundColor: AppColors.red),
        );
      }
    }
  }

  Future<void> _reject() async {
    if (_cuti == null) return;
    final catatan = await AtasanApprovalDialogs.showRejectDialog(context, _cuti!);
    if (catatan == null || !mounted) return;

    final provider = context.read<CutiProvider>();
    try {
      await provider.tolakCutiAtasan(_cuti!.id, catatan: catatan);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pengajuan cuti ${_cuti?.namaPegawai ?? ''} berhasil ditolak.'),
            backgroundColor: AppColors.black,
          ),
        );
        _load();
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.friendlyMessage), backgroundColor: AppColors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final showApprovalBar = _cuti != null && _cuti!.canApprove == true;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: const Text('Detail Pengajuan')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.red))
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.gray)))
              : _cuti == null
                  ? const SizedBox.shrink()
                  : _DetailContent(cuti: _cuti!),
      bottomNavigationBar: showApprovalBar
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _reject,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.red, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.close_rounded, color: AppColors.red),
                        label: const Text('Tolak', style: TextStyle(color: AppColors.red, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _approve,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF15803D),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.check_rounded, color: Colors.white),
                        label: const Text('Setujui', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}

class _DetailContent extends StatelessWidget {
  final Cuti cuti;
  const _DetailContent({required this.cuti});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (cuti.namaPegawai != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.redSoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_rounded, color: AppColors.red, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cuti.namaPegawai!,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.black),
                        ),
                        if (cuti.nipPegawai != null)
                          Text('NIP. ${cuti.nipPegawai!}', style: const TextStyle(fontSize: 12, color: AppColors.gray)),
                        if (cuti.unitPegawai != null)
                          Text(cuti.unitPegawai!, style: const TextStyle(fontSize: 12, color: AppColors.grayLight)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.heroGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(Formatters.jenisCuti(cuti.jenisCuti), style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                    StatusBadge(label: cuti.statusLabel, tone: CutiStatusHelper.tone(cuti.status)),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _HeroStat(label: 'Mulai', value: Formatters.tanggalPendek(cuti.tanggalMulai))),
                    Expanded(child: _HeroStat(label: 'Selesai', value: Formatters.tanggalPendek(cuti.tanggalSelesai))),
                    Expanded(child: _HeroStat(label: 'Durasi', value: '${cuti.jumlahHari} hari')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (cuti.alasan != null && cuti.alasan!.isNotEmpty) ...[
            const Text('Alasan Pengajuan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
              child: Text(cuti.alasan!, style: const TextStyle(fontSize: 13.5, color: AppColors.black, height: 1.5)),
            ),
            const SizedBox(height: 24),
          ],
          if (cuti.alamatCuti != null && cuti.alamatCuti!.isNotEmpty) ...[
            const Text('Alamat Selama Cuti', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
              child: Text(cuti.alamatCuti!, style: const TextStyle(fontSize: 13.5, color: AppColors.black, height: 1.5)),
            ),
            const SizedBox(height: 24),
          ],
          const Text('Progres Persetujuan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
          const SizedBox(height: 14),
          if (cuti.timeline != null)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
              child: Column(
                children: List.generate(cuti.timeline!.length, (i) {
                  final step = cuti.timeline![i];
                  final isLast = i == cuti.timeline!.length - 1;
                  return _TimelineTile(step: step, isLast: isLast);
                }),
              ),
            ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  const _HeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 11.5)),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _TimelineTile extends StatelessWidget {
  final TimelineStep step;
  final bool isLast;
  const _TimelineTile({required this.step, required this.isLast});

  (Color, IconData) _visual() {
    switch (step.status) {
      case 'selesai':
      case 'disetujui':
        return (AppColors.success, Icons.check_rounded);
      case 'ditolak':
        return (AppColors.danger, Icons.close_rounded);
      default:
        return (AppColors.grayLight, Icons.hourglass_empty_rounded);
    }
  }

  String _statusLabel() {
    switch (step.status) {
      case 'selesai':
        return 'Selesai';
      case 'disetujui':
        return 'Disetujui';
      case 'ditolak':
        return 'Ditolak';
      default:
        return 'Menunggu';
    }
  }

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _visual();
    final isPending = step.status == 'menunggu';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              const SizedBox(height: 16),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isPending ? Colors.white : color,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: isPending ? 2 : 0),
                ),
                child: Icon(icon, size: 14, color: isPending ? color : Colors.white),
              ),
              if (!isLast) Expanded(child: Container(width: 2, color: AppColors.border, margin: const EdgeInsets.symmetric(vertical: 4))),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 14, bottom: 20, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(step.tahap, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5))),
                      Text(_statusLabel(), style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: color)),
                    ],
                  ),
                  if (step.waktu != null) ...[
                    const SizedBox(height: 3),
                    Text(Formatters.tanggalPanjang(step.waktu!), style: const TextStyle(fontSize: 11.5, color: AppColors.grayLight)),
                  ],
                  if (step.catatan != null && step.catatan!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppColors.creamSoft, borderRadius: BorderRadius.circular(10)),
                      child: Text(step.catatan!, style: const TextStyle(fontSize: 12, color: AppColors.gray)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
