import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/models/cuti.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/fade_slide_in.dart';
import '../../core/widgets/shimmer_box.dart';
import '../auth/auth_provider.dart';
import 'cuti_detail_screen.dart';
import 'cuti_form_screen.dart';
import 'cuti_provider.dart';
import 'widgets/atasan_approval_dialogs.dart';
import 'widgets/cuti_card.dart';
import 'widgets/filter_chips_row.dart';
import 'widgets/leave_balance_card.dart';
import 'widgets/team_calendar_view.dart';

class CutiListScreen extends StatefulWidget {
  final int initialTab;
  const CutiListScreen({super.key, this.initialTab = 0});

  @override
  State<CutiListScreen> createState() => _CutiListScreenState();
}

class _CutiListScreenState extends State<CutiListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isAtasan = false;

  @override
  void initState() {
    super.initState();
    _isAtasan = context.read<AuthProvider>().isAtasan;
    final tabLength = _isAtasan ? 3 : 2;
    final initial = widget.initialTab.clamp(0, tabLength - 1);

    _tabController = TabController(length: tabLength, vsync: this, initialIndex: initial);
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

  Future<void> _openForm(BuildContext context) async {
    final provider = context.read<CutiProvider>();
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: const CutiFormScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CutiProvider()..loadAll(isAtasan: _isAtasan),
      child: Builder(
        builder: (context) {
          final pendingCount = context.watch<CutiProvider>().pendingAtasanCount;

          return Scaffold(
            backgroundColor: AppColors.cream,
            appBar: AppBar(
              title: const Text('Cuti & Izin'),
              bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: AppColors.red,
                indicatorWeight: 3,
                labelColor: AppColors.red,
                unselectedLabelColor: AppColors.gray,
                labelPadding: const EdgeInsets.symmetric(horizontal: 14),
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                tabs: _isAtasan
                    ? [
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Persetujuan'),
                              if (pendingCount > 0) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.red,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$pendingCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const Tab(text: 'Pengajuan Saya'),
                        const Tab(text: 'Kalender Tim'),
                      ]
                    : const [
                        Tab(text: 'Pengajuan Saya'),
                        Tab(text: 'Kalender Tim'),
                      ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: _isAtasan
                  ? const [
                      _AtasanApprovalListBody(),
                      _CutiListBody(),
                      TeamCalendarView(),
                    ]
                  : const [
                      _CutiListBody(),
                      TeamCalendarView(),
                    ],
            ),
            floatingActionButton: (_isAtasan ? _tabController.index == 1 : _tabController.index == 0)
                ? FloatingActionButton.extended(
                    onPressed: () => _openForm(context),
                    backgroundColor: AppColors.red,
                    icon: const Icon(Icons.add_rounded, color: Colors.white),
                    label: const Text('Ajukan Cuti', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  )
                : null,
          );
        },
      ),
    );
  }
}

class _AtasanApprovalListBody extends StatelessWidget {
  const _AtasanApprovalListBody();

  static const _filterOptions = {
    'menunggu': 'Menunggu',
    'disetujui': 'Disetujui',
    'ditolak': 'Ditolak',
    'semua': 'Semua',
  };

  Future<void> _openDetail(BuildContext context, int id) async {
    final provider = context.read<CutiProvider>();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: CutiDetailScreen(cutiId: id),
        ),
      ),
    );
    if (context.mounted) {
      provider.loadAtasanCutiList();
    }
  }

  Future<void> _approve(BuildContext context, Cuti cuti) async {
    final catatan = await AtasanApprovalDialogs.showApproveDialog(context, cuti);
    if (catatan == null || !context.mounted) return;

    final provider = context.read<CutiProvider>();
    try {
      await provider.setujuiCutiAtasan(cuti.id, catatan: catatan.isEmpty ? null : catatan);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pengajuan cuti ${cuti.namaPegawai ?? ''} berhasil disetujui.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.friendlyMessage), backgroundColor: AppColors.red),
        );
      }
    }
  }

  Future<void> _reject(BuildContext context, Cuti cuti) async {
    final catatan = await AtasanApprovalDialogs.showRejectDialog(context, cuti);
    if (catatan == null || !context.mounted) return;

    final provider = context.read<CutiProvider>();
    try {
      await provider.tolakCutiAtasan(cuti.id, catatan: catatan);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pengajuan cuti ${cuti.namaPegawai ?? ''} berhasil ditolak.'),
            backgroundColor: AppColors.black,
          ),
        );
      }
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.friendlyMessage), backgroundColor: AppColors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CutiProvider>();

    return RefreshIndicator(
      color: AppColors.red,
      onRefresh: () => context.read<CutiProvider>().loadAtasanCutiList(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeSlideIn(
              child: FilterChipsRow(
                selected: provider.atasanFilter,
                options: _filterOptions,
                countFor: provider.countAtasanFor,
                onSelected: (key) => context.read<CutiProvider>().setAtasanFilter(key),
              ),
            ),
            const SizedBox(height: 16),
            if (provider.isLoadingAtasanList)
              Column(
                children: List.generate(
                  3,
                  (i) => const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: ShimmerBox(height: 110),
                  ),
                ),
              )
            else if (provider.atasanFiltered.isEmpty)
              const EmptyState(
                icon: Icons.assignment_turned_in_rounded,
                title: 'Tidak ada pengajuan cuti tim',
                subtitle: 'Belum ada pengajuan cuti dari anggota tim yang sesuai dengan filter ini.',
              )
            else
              ...List.generate(provider.atasanFiltered.length, (i) {
                final cuti = provider.atasanFiltered[i];
                return FadeSlideIn(
                  index: i + 1,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CutiCard(
                      cuti: cuti,
                      showPegawaiName: true,
                      onTap: () => _openDetail(context, cuti.id),
                      onApprove: () => _approve(context, cuti),
                      onReject: () => _reject(context, cuti),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _CutiListBody extends StatelessWidget {
  const _CutiListBody();

  static const _filterOptions = {
    'semua': 'Semua',
    'menunggu': 'Menunggu',
    'disetujui': 'Disetujui',
    'ditolak': 'Ditolak',
  };

  Future<void> _openDetail(BuildContext context, int id) async {
    final provider = context.read<CutiProvider>();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: CutiDetailScreen(cutiId: id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CutiProvider>();
    final isAtasan = context.watch<AuthProvider>().isAtasan;

    return RefreshIndicator(
      color: AppColors.red,
      onRefresh: () => context.read<CutiProvider>().loadAll(isAtasan: isAtasan),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeSlideIn(child: LeaveBalanceCard(saldo: provider.saldo, isLoading: provider.isLoadingSaldo)),
            const SizedBox(height: 22),
            FadeSlideIn(
              index: 1,
              child: FilterChipsRow(
                selected: provider.filter,
                options: _filterOptions,
                countFor: provider.countFor,
                onSelected: (key) => context.read<CutiProvider>().setFilter(key),
              ),
            ),
            const SizedBox(height: 16),
            if (provider.isLoadingList)
              Column(
                children: List.generate(
                  3,
                  (i) => const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: ShimmerBox(height: 96),
                  ),
                ),
              )
            else if (provider.filtered.isEmpty)
              const EmptyState(
                icon: Icons.event_busy_rounded,
                title: 'Belum ada pengajuan cuti',
                subtitle: 'Ketuk tombol "Ajukan Cuti" untuk membuat pengajuan baru.',
              )
            else
              ...List.generate(provider.filtered.length, (i) {
                final cuti = provider.filtered[i];
                return FadeSlideIn(
                  index: i + 2,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CutiCard(cuti: cuti, onTap: () => _openDetail(context, cuti.id)),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
