import 'package:flutter/material.dart';

/// Palet warna identitas visual KPI Pusat — selaras dengan web SIMPEG-KPI.
class AppColors {
  AppColors._();

  // Color Tokens Utama
  static const Color red = Color(0xFFC1272D);
  static const Color redDark = Color(0xFF84181C);
  static const Color redSoft = Color(0xFFF6E4E5);
  static const Color black = Color(0xFF15110F);
  static const Color gold = Color(0xFFC9A227);
  static const Color goldSoft = Color(0xFFF6EFDA);
  static const Color cream = Color(0xFFFAF6EF);
  static const Color creamSoft = Color(0xFFF4EFE6);
  static const Color gray = Color(0xFF6B6560);
  static const Color grayLight = Color(0xFFA39D96);
  static const Color border = Color(0xFFE7E1D6);

  // Status Tones
  static const Color success = Color(0xFF16A34A);
  static const Color successSoft = Color(0xFFE3F6EA);
  static const Color warning = Color(0xFFD97706);
  static const Color warningSoft = Color(0xFFFCF0DD);
  static const Color danger = Color(0xFFDC2626);
  static const Color dangerSoft = Color(0xFFFBE6E6);
  static const Color info = Color(0xFF0284C7);
  static const Color infoSoft = Color(0xFFE1F1FA);

  // Quick Action Menu Accent Colors (Dual-Tone Gradients & Soft Backdrops)
  static const Color indigoAccent = Color(0xFF6366F1);
  static const Color indigoSoft = Color(0xFFEEF2FF);

  static const Color emeraldAccent = Color(0xFF10B981);
  static const Color emeraldSoft = Color(0xFFECFDF5);

  static const Color skyAccent = Color(0xFF0284C7);
  static const Color skySoft = Color(0xFFF0F9FF);

  static const Color amberAccent = Color(0xFFF59E0B);
  static const Color amberSoft = Color(0xFFFFFBEB);

  static const Color crimsonAccent = red;
  static const Color crimsonSoft = redSoft;

  // Gradients
  static const List<Color> heroGradient = [red, redDark];
  static const List<Color> goldGradient = [Color(0xFFDDBB4B), gold];
  static const List<Color> cardGradient = [Colors.white, Color(0xFFFCFAF7)];

  // Soft Realistic Multi-Layer Shadows
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get heroShadow => [
        BoxShadow(
          color: red.withOpacity(0.28),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ];
}
