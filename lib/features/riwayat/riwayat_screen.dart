import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final int initialTab;
  const RiwayatScreen({super.key, this.initialTab = 0});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTab.clamp(0, 1));
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
                labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13.5),
                unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13.5),
                tabs: const [Tab(text: 'Pendidikan'), Tab(text: 'Pelatihan')],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [_PendidikanTab(), _PelatihanTab()],
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
                    label: Text(
                      'Tambah Pelatihan',
                      style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.infoSoft, borderRadius: BorderRadius.circular(13)),
            child: Text(
              item.jenjang,
              style: GoogleFonts.plusJakartaSans(color: AppColors.info, fontWeight: FontWeight.w800, fontSize: 11.5),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.institusi,
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.black),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.jurusan ?? '-'} · Lulus ${item.tahunLulus}',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppColors.gray),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PelatihanTab extends StatefulWidget {
  const _PelatihanTab();

  @override
  State<_PelatihanTab> createState() => _PelatihanTabState();
}

class _PelatihanTabState extends State<_PelatihanTab> {
  int? _selectedYear; // null means 'Semua Tahun'

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RiwayatProvider>();
    final allPelatihan = provider.pelatihan;

    // Collect available unique years sorted descending
    final years = allPelatihan.map((p) => p.tanggal.year).toSet().toList()
      ..sort((a, b) => b.compareTo(a));

    // Filter pelatihan list by selected year
    final filteredList = _selectedYear == null
        ? allPelatihan
        : allPelatihan.where((p) => p.tanggal.year == _selectedYear).toList();

    // Calculate total JP for selected filter
    final int displayJp = _selectedYear == null
        ? allPelatihan.fold(0, (sum, item) => sum + item.durasiJp)
        : filteredList.fold(0, (sum, item) => sum + item.durasiJp);

    final String bannerTitle = _selectedYear == null
        ? 'Total Akumulasi Seluruh JP'
        : 'Total Capaian Diklat Tahun $_selectedYear';

    return RefreshIndicator(
      color: AppColors.red,
      onRefresh: () => context.read<RiwayatProvider>().loadPelatihan(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          if (!provider.isLoadingPelatihan) ...[
            Container(
              padding: const EdgeInsets.all(18),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF15110F), Color(0xFF2E241E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.14),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bannerTitle,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withOpacity(0.65),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$displayJp Jam Pelajaran (JP)',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (years.isNotEmpty) ...[
              SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: years.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final isAll = index == 0;
                    final yearVal = isAll ? null : years[index - 1];
                    final isSelected = _selectedYear == yearVal;
                    final label = isAll ? 'Semua Tahun' : 'Tahun $yearVal';

                    return GestureDetector(
                      onTap: () => setState(() => _selectedYear = yearVal),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.red : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? AppColors.red : AppColors.border,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          label,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                            color: isSelected ? Colors.white : const Color(0xFF334155),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
          if (provider.isLoadingPelatihan)
            Column(children: List.generate(3, (i) => const Padding(padding: EdgeInsets.only(bottom: 12), child: ShimmerBox(height: 90))))
          else if (filteredList.isEmpty)
            const EmptyState(icon: Icons.workspace_premium_outlined, title: 'Belum ada riwayat pelatihan tercatat')
          else
            ...List.generate(filteredList.length, (i) => FadeSlideIn(
              index: i,
              child: Padding(padding: const EdgeInsets.only(bottom: 12), child: _PelatihanCard(item: filteredList[i])),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          Row(
            children: [
              Expanded(
                child: Text(
                  item.namaPelatihan,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                    color: AppColors.black,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(
                label: item.statusVerifikasi[0].toUpperCase() + item.statusVerifikasi.substring(1),
                tone: _tone,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _MetaChip(icon: Icons.apartment_rounded, label: item.penyelenggara ?? '-'),
              _MetaChip(icon: Icons.calendar_today_rounded, label: Formatters.tanggalPendek(item.tanggal)),
              _MetaChip(icon: Icons.timer_outlined, label: '${item.durasiJp} JP'),
              _MetaChip(icon: Icons.category_outlined, label: Formatters.kategoriPelatihan(item.kategori)),
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
        Icon(icon, size: 12.5, color: const Color(0xFF64748B)),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.5,
            color: const Color(0xFF475569),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
