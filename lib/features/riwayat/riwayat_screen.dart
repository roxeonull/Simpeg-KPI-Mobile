import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/riwayat.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/fade_slide_in.dart';
import '../../core/widgets/shimmer_box.dart';
import '../../core/widgets/status_badge.dart';
import 'riwayat_provider.dart';
import 'pelatihan_form_screen.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RiwayatProvider()..loadAll(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: AppColors.cream,
            appBar: AppBar(
              title: const Text('Pendidikan & Pelatihan'),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.red,
                indicatorWeight: 3,
                labelColor: AppColors.red,
                unselectedLabelColor: AppColors.gray,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                tabs: const [Tab(text: 'Pendidikan'), Tab(text: 'Pelatihan')],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: const [_PendidikanTab(), _PelatihanTab()],
            ),
            floatingActionButton: _tabController.index == 1
                ? FloatingActionButton.extended(
                    onPressed: () async {
                      final provider = context.read<RiwayatProvider>();
                      final success = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider.value(
                            value: provider,
                            child: const PelatihanFormScreen(),
                          ),
                        ),
                      );
                      if (success == true && context.mounted) {
                        provider.loadPelatihan();
                      }
                    },
                    backgroundColor: AppColors.red,
                    icon: const Icon(Icons.add_rounded, color: Colors.white),
                    label: const Text('Tambah Pelatihan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  )
                : null,
          );
        }
      ),
    );
  }
}

class _PendidikanTab extends StatelessWidget {
  const _PendidikanTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RiwayatProvider>();

    return RefreshIndicator(
      color: AppColors.red,
      onRefresh: () => context.read<RiwayatProvider>().loadPendidikan(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          if (provider.isLoadingPendidikan)
            Column(children: List.generate(3, (i) => const Padding(padding: EdgeInsets.only(bottom: 12), child: ShimmerBox(height: 84))))
          else if (provider.pendidikan.isEmpty)
            const EmptyState(icon: Icons.school_outlined, title: 'Belum ada riwayat pendidikan tercatat')
          else
            ...List.generate(provider.pendidikan.length, (i) => FadeSlideIn(
              index: i,
              child: Padding(padding: const EdgeInsets.only(bottom: 12), child: _PendidikanCard(item: provider.pendidikan[i])),
            )),
        ],
      ),
    );
  }
}

class _PendidikanCard extends StatelessWidget {
  final RiwayatPendidikan item;
  const _PendidikanCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.infoSoft, borderRadius: BorderRadius.circular(13)),
            child: Text(item.jenjang, style: const TextStyle(color: AppColors.info, fontWeight: FontWeight.w800, fontSize: 11.5)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.institusi, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 2),
                Text('${item.jurusan ?? '-'} · Lulus ${item.tahunLulus}', style: const TextStyle(fontSize: 12.5, color: AppColors.gray)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PelatihanTab extends StatelessWidget {
  const _PelatihanTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RiwayatProvider>();

    return RefreshIndicator(
      color: AppColors.red,
      onRefresh: () => context.read<RiwayatProvider>().loadPelatihan(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          if (!provider.isLoadingPelatihan)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: AppColors.goldGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events_rounded, color: AppColors.black, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total JP Tahun Ini', style: TextStyle(color: AppColors.black, fontSize: 12, fontWeight: FontWeight.w600)),
                        Text('${provider.totalJpTahunIni} Jam Pelajaran', style: const TextStyle(color: AppColors.black, fontSize: 16, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (provider.isLoadingPelatihan)
            Column(children: List.generate(3, (i) => const Padding(padding: EdgeInsets.only(bottom: 12), child: ShimmerBox(height: 90))))
          else if (provider.pelatihan.isEmpty)
            const EmptyState(icon: Icons.workspace_premium_outlined, title: 'Belum ada riwayat pelatihan tercatat')
          else
            ...List.generate(provider.pelatihan.length, (i) => FadeSlideIn(
              index: i,
              child: Padding(padding: const EdgeInsets.only(bottom: 12), child: _PelatihanCard(item: provider.pelatihan[i])),
            )),
        ],
      ),
    );
  }
}

class _PelatihanCard extends StatelessWidget {
  final RiwayatPelatihan item;
  const _PelatihanCard({required this.item});

  BadgeTone get _tone {
    switch (item.statusVerifikasi) {
      case 'terverifikasi':
        return BadgeTone.success;
      case 'ditolak':
        return BadgeTone.danger;
      default:
        return BadgeTone.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(item.namaPelatihan, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14))),
              StatusBadge(label: item.statusVerifikasi[0].toUpperCase() + item.statusVerifikasi.substring(1), tone: _tone),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              _MetaChip(icon: Icons.apartment_rounded, label: item.penyelenggara ?? '-'),
              _MetaChip(icon: Icons.calendar_today_rounded, label: Formatters.tanggalPendek(item.tanggal)),
              _MetaChip(icon: Icons.timer_rounded, label: '${item.durasiJp} JP'),
              _MetaChip(icon: Icons.category_rounded, label: Formatters.kategoriPelatihan(item.kategori)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.grayLight),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.gray)),
      ],
    );
  }
}
