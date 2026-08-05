import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/models/dinas_luar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/bouncing_button.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/status_badge.dart';
import '../auth/auth_provider.dart';
import 'dinas_luar_form_screen.dart';
import 'dinas_luar_provider.dart';

class DinasLuarListScreen extends StatefulWidget {
  final int initialTab;
  const DinasLuarListScreen({super.key, this.initialTab = 0});

  @override
  State<DinasLuarListScreen> createState() => _DinasLuarListScreenState();
}

class _DinasLuarListScreenState extends State<DinasLuarListScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    final isAtasan = context.read<AuthProvider>().isAtasan;
    if (isAtasan) {
      _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DinasLuarProvider>().loadAll(isAtasan: isAtasan);
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAtasan = context.watch<AuthProvider>().isAtasan;
    final provider = context.watch<DinasLuarProvider>();

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
          'Dinas Luar & WFA',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        bottom: isAtasan
            ? TabBar(
                controller: _tabController,
                indicatorColor: AppColors.red,
                indicatorWeight: 3,
                labelColor: AppColors.red,
                unselectedLabelColor: const Color(0xFF64748B),
                labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13.5),
                tabs: [
                  const Tab(text: 'Pengajuan Saya'),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Persetujuan Tim'),
                        if (provider.teamRequests.where((r) => r.isPending).isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${provider.teamRequests.where((r) => r.isPending).length}',
                              style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              )
            : null,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.red,
        elevation: 4,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DinasLuarFormScreen()),
          ).then((_) {
            context.read<DinasLuarProvider>().loadAll(isAtasan: isAtasan);
          });
        },
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Ajukan Dinas Luar',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.red))
          : isAtasan
              ? TabBarView(
                  controller: _tabController,
                  children: [
                    _MyRequestsList(items: provider.myRequests),
                    _TeamRequestsList(items: provider.teamRequests),
                  ],
                )
              : _MyRequestsList(items: provider.myRequests),
    );
  }
}

class _MyRequestsList extends StatelessWidget {
  final List<DinasLuarItem> items;
  const _MyRequestsList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => context.read<DinasLuarProvider>().loadMine(),
        color: AppColors.red,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(top: 80),
            child: EmptyState(
              icon: Icons.business_center_outlined,
              title: 'Belum Ada Pengajuan',
              subtitle: 'Pengajuan Dinas Luar / WFA / Tugas Lapangan Anda akan tercatat di sini.',
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<DinasLuarProvider>().loadMine(),
      color: AppColors.red,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return _DinasLuarCard(item: item, isTeam: false);
        },
      ),
    );
  }
}

class _TeamRequestsList extends StatelessWidget {
  final List<DinasLuarItem> items;
  const _TeamRequestsList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => context.read<DinasLuarProvider>().loadTeamRequests(),
        color: AppColors.red,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(top: 80),
            child: EmptyState(
              icon: Icons.group_work_outlined,
              title: 'Belum Ada Pengajuan Tim',
              subtitle: 'Pengajuan Dinas Luar / WFA dari anggota tim Anda akan muncul di sini.',
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<DinasLuarProvider>().loadTeamRequests(),
      color: AppColors.red,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return _DinasLuarCard(item: item, isTeam: true);
        },
      ),
    );
  }
}

class _DinasLuarCard extends StatelessWidget {
  final DinasLuarItem item;
  final bool isTeam;

  const _DinasLuarCard({
    required this.item,
    required this.isTeam,
  });

  BadgeTone get _tone {
    if (item.isApproved) return BadgeTone.success;
    if (item.isRejected) return BadgeTone.danger;
    return BadgeTone.warning;
  }

  void _openFile(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showApprovalDialog(BuildContext context, bool isApprove) {
    final catatanController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isApprove ? 'Setujui Pengajuan?' : 'Tolak Pengajuan?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isApprove
                  ? 'Persetujuan ini akan melonggarkan batas geofence presensi pegawai pada hari tugas tersebut.'
                  : 'Berikan alasan penolakan pengajuan ini.',
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF64748B)),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: catatanController,
              decoration: InputDecoration(
                hintText: 'Catatan Atasan (Opsional)',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isApprove ? const Color(0xFF10B981) : AppColors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final p = context.read<DinasLuarProvider>();
              Navigator.pop(ctx);
              try {
                if (isApprove) {
                  await p.setujuiDinasLuar(item.id, catatan: catatanController.text.trim());
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Pengajuan berhasil disetujui.', style: GoogleFonts.plusJakartaSans()),
                        backgroundColor: const Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } else {
                  await p.tolakDinasLuar(item.id, catatan: catatanController.text.trim());
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Pengajuan telah ditolak.', style: GoogleFonts.plusJakartaSans()),
                        backgroundColor: AppColors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal memproses persetujuan: $e', style: GoogleFonts.plusJakartaSans()),
                      backgroundColor: AppColors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: Text(
              isApprove ? 'Setujui' : 'Tolak',
              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.07)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isTeam && item.pegawaiNama != null) ...[
                      Text(
                        item.pegawaiNama!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      item.jenisKetidakhadiranNama,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: isTeam ? 13 : 15,
                        fontWeight: isTeam ? FontWeight.w600 : FontWeight.w800,
                        color: isTeam ? const Color(0xFF64748B) : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(
                label: item.status[0].toUpperCase() + item.status.substring(1),
                tone: _tone,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Date & Location Info
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              Text(
                item.dateRangeText,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF334155),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 14, color: AppColors.red),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.lokasiTugas,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    color: const Color(0xFF475569),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          if (item.alasan.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item.alasan,
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          if (item.fileSptUrl != null && item.fileSptUrl!.isNotEmpty) ...[
            const SizedBox(height: 10),
            InkWell(
              onTap: () => _openFile(item.fileSptUrl!),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf_rounded, size: 15, color: AppColors.red),
                  const SizedBox(width: 6),
                  Text(
                    'Lihat Berkas SPT',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.red,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (item.catatanAtasan != null && item.catatanAtasan!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Catatan Atasan: ${item.catatanAtasan}',
                style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF475569)),
              ),
            ),
          ],

          // Approval Action Buttons for Atasan on Team Requests
          if (isTeam && item.isPending) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _showApprovalDialog(context, false),
                    child: Text('Tolak', style: GoogleFonts.plusJakartaSans(color: AppColors.red, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _showApprovalDialog(context, true),
                    child: Text('Setujui', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
