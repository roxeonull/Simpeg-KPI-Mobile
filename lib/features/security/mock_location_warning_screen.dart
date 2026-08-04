import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/services/mock_location_guard_service.dart';
import '../../core/theme/app_colors.dart';
import '../splash/splash_screen.dart';

/// Halaman Peringatan Full-Screen saat Mock Location / Developer Mode terdeteksi aktif.
///
/// Halaman ini memblokir seluruh akses aplikasi (tidak bisa di-dismiss via tombol back),
/// menyajikan penjelasan yang sopan dan jelas, serta menyediakan tombol pengarah ke Settings.
class MockLocationWarningScreen extends StatefulWidget {
  final VoidCallback? onResolved;

  const MockLocationWarningScreen({
    super.key,
    this.onResolved,
  });

  @override
  State<MockLocationWarningScreen> createState() => _MockLocationWarningScreenState();
}

class _MockLocationWarningScreenState extends State<MockLocationWarningScreen>
    with WidgetsBindingObserver {
  bool _isChecking = false;
  String? _infoMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Otomatis cek ulang ketika pengguna kembali ke aplikasi dari background (misal dari menu Settings)
    if (state == AppLifecycleState.resumed) {
      _checkStatus(showSnack: false);
    }
  }

  Future<void> _checkStatus({bool showSnack = true}) async {
    if (_isChecking) return;
    setState(() {
      _isChecking = true;
      _infoMessage = null;
    });

    final bool isMock = await MockLocationGuardService.isMockLocationActive();

    if (!mounted) return;

    setState(() {
      _isChecking = false;
    });

    if (!isMock) {
      // Kondisi sudah bersih / nonaktif -> Lanjutkan ke alur normal aplikasi
      if (widget.onResolved != null) {
        widget.onResolved!();
      } else if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SplashScreen()),
          (route) => false,
        );
      }
    } else {
      if (showSnack) {
        setState(() {
          _infoMessage = 'Mode Pengembang / Mock Location masih aktif. Mohon nonaktifkan lalu coba lagi.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Tidak dapat di-dismiss dengan tombol back Android
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: Stack(
          children: [
            // Background Image dengan visual style selaras dengan Login & Splash
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/bg-login.png'),
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),
            ),
            // Overlay Gradient Gelap Tegas
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.black.withValues(alpha: 0.92),
                      AppColors.redDark.withValues(alpha: 0.70),
                      AppColors.black.withValues(alpha: 0.96),
                    ],
                  ),
                ),
              ),
            ),
            // Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    // Warning Icon Badge dengan ambient glow
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.red.withValues(alpha: 0.16),
                        border: Border.all(
                          color: AppColors.red.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.red.withValues(alpha: 0.35),
                            blurRadius: 36,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            color: AppColors.redDark.withValues(alpha: 0.3),
                            child: const Icon(
                              Icons.gpp_maybe_rounded,
                              size: 64,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Title
                    Text(
                      'Mode Pengembang Terdeteksi',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Message (Sopan tapi jelas & tegas)
                    Text(
                      'Untuk menggunakan aplikasi SIMPEG-KPI, mohon nonaktifkan pengaturan lokasi palsu (mock location app) di menu Developer Options perangkat Anda, lalu coba lagi.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (_infoMessage != null) ...[
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.amberAccent.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.amberAccent.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: AppColors.amberAccent,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _infoMessage!,
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const Spacer(),
                    // Primary Action: Buka Pengaturan
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: MockLocationGuardService.openDeveloperSettings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.red,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: AppColors.red.withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.settings_suggest_rounded, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              'Buka Pengaturan',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Secondary Action: Coba Lagi
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: _isChecking ? null : () => _checkStatus(showSnack: true),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isChecking
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'Coba Lagi',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
