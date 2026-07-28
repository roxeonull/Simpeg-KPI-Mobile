import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum BadgeTone { success, warning, danger, info, neutral }

class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeTone tone;

  const StatusBadge({super.key, required this.label, this.tone = BadgeTone.neutral});

  (Color, Color) _colors() {
    switch (tone) {
      case BadgeTone.success:
        return (AppColors.successSoft, AppColors.success);
      case BadgeTone.warning:
        return (AppColors.warningSoft, AppColors.warning);
      case BadgeTone.danger:
        return (AppColors.dangerSoft, AppColors.danger);
      case BadgeTone.info:
        return (AppColors.infoSoft, AppColors.info);
      case BadgeTone.neutral:
        return (AppColors.creamSoft, AppColors.gray);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          Text(
            label,
            style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
