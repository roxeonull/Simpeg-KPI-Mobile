import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/cuti.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shimmer_box.dart';

class LeaveBalanceCard extends StatelessWidget {
  final SaldoCuti? saldo;
  final bool isLoading;

  const LeaveBalanceCard({super.key, this.saldo, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const ShimmerBox(height: 168, borderRadius: BorderRadius.all(Radius.circular(24)));
    }

    final s = saldo;
    final total = s?.total ?? 0;
    final terpakai = s?.terpakai ?? 0;
    final sisa = s?.sisa ?? 0;
    final progress = s?.progress ?? 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.black, Color(0xFF2A211B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Saldo Cuti Tahunan',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${s?.tahun ?? DateTime.now().year}',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.gold,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$sisa',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  height: 1,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'hari tersisa',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: Colors.white.withOpacity(0.12),
                valueColor: const AlwaysStoppedAnimation(AppColors.gold),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _MiniStat(label: 'Total Kuota', value: '$total hari'),
              const SizedBox(width: 24),
              _MiniStat(label: 'Terpakai', value: '$terpakai hari'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white.withOpacity(0.5),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
