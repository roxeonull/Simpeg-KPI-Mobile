import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../auth/auth_provider.dart';
import '../auth/login_screen.dart';
import '../home/home_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _fade = CurvedAnimation(parent: _controller, curve: const Interval(0, 0.7, curve: Curves.easeOut));
    _controller.forward();
    _navigateWhenReady();
  }

  Future<void> _navigateWhenReady() async {
    final auth = context.read<AuthProvider>();
    // Beri waktu minimal supaya animasi splash terlihat mulus.
    final minDelay = Future.delayed(const Duration(milliseconds: 1400));

    while (auth.status == AuthStatus.unknown) {
      await Future.delayed(const Duration(milliseconds: 80));
    }
    await minDelay;

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: auth.status == AuthStatus.authenticated ? const HomeShell() : const LoginScreen(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          // Background Image with Top Alignment matching Login Screen
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
          // Red-Black Gradient Overlay matching Login Screen
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.redDark.withValues(alpha: 0.45),
                    AppColors.black.withValues(alpha: 0.88),
                  ],
                ),
              ),
            ),
          ),
          // Center Content
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo Container with soft ambient glow & frosted backdrop for high logo contrast
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.15),
                            blurRadius: 36,
                            spreadRadius: 6,
                          ),
                          BoxShadow(
                            color: AppColors.redDark.withValues(alpha: 0.4),
                            blurRadius: 48,
                            spreadRadius: 12,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            color: Colors.white.withValues(alpha: 0.18),
                            child: Image.asset(
                              'assets/images/logo-kpi.png',
                              width: 105,
                              height: 105,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'SIMPEG-KPI',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sistem Informasi Kepegawaian',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.gold.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
