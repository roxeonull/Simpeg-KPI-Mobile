import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/jadwal_shift.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/fade_slide_in.dart';
import '../../core/widgets/shimmer_box.dart';
import 'jadwal_shift_provider.dart';

class JadwalShiftScreen extends StatelessWidget {
  const JadwalShiftScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => JadwalShiftProvider()..loadMonthly(),
      child: const _JadwalShiftBody(),
    );
  }
}

class _JadwalShiftBody extends StatefulWidget {
  const _JadwalShiftBody();

  @override
  State<_JadwalShiftBody> createState() => _JadwalShiftBodyState();
}

class _JadwalShiftBodyState extends State<_JadwalShiftBody> {
  late DateTime _currentMonth;

  final List<String> _monthNames = const [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
  }

  void _changeMonth(int offset) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + offset, 1);
    });
    final bulanStr = '${_currentMonth.year}-${_currentMonth.month.toString().padLeft(2, '0')}';
    context.read<JadwalShiftProvider>().loadMonthly(bulanStr);
  }

  void _goToToday() {
    final now = DateTime.now();
    if (_currentMonth.year != now.year || _currentMonth.month != now.month) {
      setState(() {
        _currentMonth = now;
      });
      final bulanStr = '${now.year}-${now.month.toString().padLeft(2, '0')}';
      context.read<JadwalShiftProvider>().loadMonthly(bulanStr);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<JadwalShiftProvider>();
    final isCurrentMonthNow = _currentMonth.year == DateTime.now().year && _currentMonth.month == DateTime.now().month;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Jadwal Shift Saya'),
      ),
      body: RefreshIndicator(
        color: AppColors.red,
        onRefresh: () async {
          final bulanStr = '${_currentMonth.year}-${_currentMonth.month.toString().padLeft(2, '0')}';
          await context.read<JadwalShiftProvider>().loadMonthly(bulanStr);
        },
        child: Column(
          children: [
            // Header Navigasi Bulan
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded),
                    color: AppColors.black,
                    onPressed: () => _changeMonth(-1),
                  ),
                  InkWell(
                    onTap: _goToToday,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Row(
                        children: [
                          Text(
                            '${_monthNames[_currentMonth.month - 1]} ${_currentMonth.year}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.black,
                            ),
                          ),
                          if (!isCurrentMonthNow) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.redSoft,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Bulan Ini',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.red,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded),
                    color: AppColors.black,
                    onPressed: () => _changeMonth(1),
                  ),
                ],
              ),
            ),

            // Main Content Area
            Expanded(
              child: provider.isLoading
                  ? const _ShiftSkeleton()
                  : provider.error != null
                      ? EmptyState(
                          icon: Icons.cloud_off_rounded,
                          title: provider.error!,
                          onRetry: () {
                            final bulanStr = '${_currentMonth.year}-${_currentMonth.month.toString().padLeft(2, '0')}';
                            context.read<JadwalShiftProvider>().loadMonthly(bulanStr);
                          },
                        )
                      : provider.entries.isEmpty
                          ? const EmptyState(
                              icon: Icons.event_busy_rounded,
                              title: 'Tidak ada jadwal shift pada bulan terpilih.',
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                              itemCount: provider.entries.length,
                              itemBuilder: (context, index) {
                                final item = provider.entries[index];
                                return FadeSlideIn(
                                  index: index,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _DailyShiftCard(item: item),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyShiftCard extends StatelessWidget {
  final JadwalShiftItem item;
  const _DailyShiftCard({required this.item});

  @override
  Widget build(BuildContext context) {
    DateTime? dt;
    try {
      dt = DateTime.parse(item.tanggal);
    } catch (_) {}

    final bool isWeekend = dt != null && (dt.weekday == DateTime.saturday || dt.weekday == DateTime.sunday);
    final String dateFormatted = dt != null ? Formatters.hariTanggal(dt) : item.tanggal;

    if (item.isLibur) {
      final statusNama = item.statusShift?.nama ?? 'Libur Reguler';
      final statusWarnaHex = item.statusShift?.warna;
      Color statusBg = AppColors.successSoft;
      Color statusFg = AppColors.success;

      if (statusWarnaHex != null && statusWarnaHex.startsWith('#')) {
        try {
          final hex = statusWarnaHex.replaceFirst('#', 'FF');
          statusFg = Color(int.parse(hex, radix: 16));
          statusBg = statusFg.withOpacity(0.12);
        } catch (_) {}
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isWeekend ? const Color(0xFFF9FAFB) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.event_available_rounded, color: statusFg, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateFormatted,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: AppColors.black),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusNama,
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: statusFg),
                        ),
                      ),
                    ],
                  ),
                  if (item.keterangan != null && item.keterangan!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.keterangan!,
                      style: const TextStyle(fontSize: 11, color: AppColors.gray),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isWeekend ? const Color(0xFFFEFCE8) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateFormatted,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.black),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  item.shiftLabel,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4F46E5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.access_time_filled_rounded, size: 15, color: AppColors.gray),
              const SizedBox(width: 6),
              Text(
                item.jamRange,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.black),
              ),
              if (item.stasiunTv != null && item.stasiunTv!.isNotEmpty) ...[
                const SizedBox(width: 14),
                Container(width: 1, height: 14, color: AppColors.border),
                const SizedBox(width: 14),
                const Icon(Icons.live_tv_rounded, size: 15, color: Color(0xFF0284C7)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.stasiunTv!,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0284C7)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          if (item.keterangan != null && item.keterangan!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item.keterangan!,
              style: const TextStyle(fontSize: 11.5, color: AppColors.gray),
            ),
          ],
        ],
      ),
    );
  }
}

class _ShiftSkeleton extends StatelessWidget {
  const _ShiftSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: ShimmerBox(height: 90, borderRadius: BorderRadius.all(Radius.circular(18))),
      ),
    );
  }
}
