import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/shimmer_box.dart';
import '../../../core/widgets/status_badge.dart';
import '../cuti_provider.dart';

class TeamCalendarView extends StatefulWidget {
  const TeamCalendarView({super.key});

  @override
  State<TeamCalendarView> createState() => _TeamCalendarViewState();
}

class _TeamCalendarViewState extends State<TeamCalendarView> {
  late DateTime _currentMonth;

  final List<String> _monthNames = const [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _loadData();
  }

  void _loadData() {
    final bulanStr = '${_currentMonth.year}-${_currentMonth.month.toString().padLeft(2, '0')}';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CutiProvider>().loadKalenderTim(bulanStr);
    });
  }

  void _changeMonth(int offset) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + offset, 1);
    });
    _loadData();
  }

  void _goToToday() {
    final now = DateTime.now();
    if (_currentMonth.year != now.year || _currentMonth.month != now.month) {
      setState(() {
        _currentMonth = now;
      });
      _loadData();
    }
  }

  List<DateTime> _generateDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    // Determine how many days we subtract to start the grid on Monday (weekday 1)
    // If firstDay.weekday is Monday (1), subtract 0 days.
    // If firstDay.weekday is Sunday (7), subtract 6 days.
    final offset = firstDay.weekday - 1;
    final gridStart = firstDay.subtract(Duration(days: offset));
    return List.generate(42, (i) => gridStart.add(Duration(days: i)));
  }

  Color _getCutiColor(String jenis) {
    switch (jenis) {
      case 'tahunan':
        return const Color(0xFF3B82F6); // Blue
      case 'sakit':
        return const Color(0xFFEF4444); // Red
      case 'melahirkan':
        return const Color(0xFF10B981); // Emerald
      default:
        return const Color(0xFFF59E0B); // Amber (lainnya)
    }
  }

  String _getJenisLabel(String jenis) {
    switch (jenis) {
      case 'tahunan':
        return 'Cuti Tahunan';
      case 'sakit':
        return 'Cuti Sakit';
      case 'melahirkan':
        return 'Cuti Melahirkan';
      default:
        return 'Cuti Lainnya';
    }
  }

  void _showCutiDetails(DateTime date, List<dynamic> cutis) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: AppColors.cream,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cuti Tim · ${date.day} ${_monthNames[date.month - 1]} ${date.year}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.black),
                    ),
                    Container(
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(color: AppColors.grayLight.withOpacity(0.5), borderRadius: BorderRadius.circular(2)),
                    )
                  ],
                ),
                const SizedBox(height: 18),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: cutis.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final item = cutis[i];
                      final isApproved = item['status'] == 'disetujui';
                      final color = _getCutiColor(item['jenis_cuti']);

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 42,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['nama_pegawai'],
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: AppColors.black),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${_getJenisLabel(item['jenis_cuti'])} · ${item['alasan'] ?? '-'}',
                                    style: const TextStyle(fontSize: 12, color: AppColors.gray),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            StatusBadge(
                              label: isApproved ? 'Disetujui' : 'Menunggu',
                              tone: isApproved ? BadgeTone.success : BadgeTone.warning,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CutiProvider>();
    final days = _generateDaysInMonth(_currentMonth);
    final now = DateTime.now();

    return Column(
      children: [
        // 1. Navigation Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${_monthNames[_currentMonth.month - 1]} ${_currentMonth.year}',
                  style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: AppColors.black),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _changeMonth(-1),
                    icon: const Icon(Icons.chevron_left_rounded, color: AppColors.gray, size: 20),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                    ),
                  ),
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: _goToToday,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: AppColors.border),
                      foregroundColor: AppColors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                      textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                    ),
                    child: const Text('Hari Ini'),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: () => _changeMonth(1),
                    icon: const Icon(Icons.chevron_right_rounded, color: AppColors.gray, size: 20),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 2. Legend Box
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Wrap(
            spacing: 10,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              _buildLegendItem(const Color(0xFF3B82F6), 'Tahunan'),
              _buildLegendItem(const Color(0xFFEF4444), 'Sakit'),
              _buildLegendItem(const Color(0xFF10B981), 'Melahirkan'),
              _buildLegendItem(const Color(0xFFF59E0B), 'Lainnya'),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: AppColors.grayLight.withOpacity(0.35),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('Faded = Menunggu', style: TextStyle(fontSize: 10.5, color: AppColors.gray, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // 3. Weekdays Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: const [
              Expanded(child: _WeekdayLabel(label: 'Sen')),
              Expanded(child: _WeekdayLabel(label: 'Sel')),
              Expanded(child: _WeekdayLabel(label: 'Rab')),
              Expanded(child: _WeekdayLabel(label: 'Kam')),
              Expanded(child: _WeekdayLabel(label: 'Jum')),
              Expanded(child: _WeekdayLabel(label: 'Sab')),
              Expanded(child: _WeekdayLabel(label: 'Min')),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // 4. Calendar Grid
        Expanded(
          child: provider.isLoadingKalender
              ? const _CalendarShimmer()
              : Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 5,
                      crossAxisSpacing: 5,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: 42,
                    itemBuilder: (ctx, index) {
                      final date = days[index];
                      final isCurrentMonth = date.month == _currentMonth.month;
                      final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
                      
                      final normalizedDate = DateTime(date.year, date.month, date.day);
                      final dayCutis = provider.kalenderTim[normalizedDate] ?? [];

                      return GestureDetector(
                        onTap: dayCutis.isEmpty
                            ? null
                            : () => _showCutiDetails(date, dayCutis),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isToday ? AppColors.redSoft : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isToday ? AppColors.red.withOpacity(0.5) : AppColors.border,
                              width: isToday ? 1.4 : 1.0,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${date.day}',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                                  color: isCurrentMonth
                                      ? (isToday ? AppColors.red : AppColors.black)
                                      : AppColors.grayLight,
                                ),
                              ),
                              if (dayCutis.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: dayCutis.take(3).map<Widget>((item) {
                                    final isApproved = item['status'] == 'disetujui';
                                    final color = _getCutiColor(item['jenis_cuti']);
                                    return Container(
                                      width: 4.5,
                                      height: 4.5,
                                      margin: const EdgeInsets.symmetric(horizontal: 0.8),
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(isApproved ? 1.0 : 0.35),
                                        shape: BoxShape.circle,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10.5, color: AppColors.black, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String label;
  const _WeekdayLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.gray),
      ),
    );
  }
}

class _CalendarShimmer extends StatelessWidget {
  const _CalendarShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          childAspectRatio: 1.0,
        ),
        itemCount: 42,
        itemBuilder: (_, __) => const ShimmerBox(
          height: 50,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }
}
