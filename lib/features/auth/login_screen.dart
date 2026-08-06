import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../home/home_shell.dart';
import 'auth_provider.dart';

import '../../core/services/mock_location_guard_service.dart';

import '../security/mock_location_warning_screen.dart';
import 'forgot_password_modal.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _isWarningShowing = false;

  late AnimationController _animationController;
  late Animation<double> _bgOpacityAnimation;
  late Animation<double> _cardOpacityAnimation;
  late Animation<Offset> _cardSlideAnimation;
  late Animation<double> _cardScaleAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _bgOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _cardOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
      ),
    );

    _cardSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 80),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _cardScaleAnimation = Tween<double>(begin: 0.93, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
    _checkMockLocation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkMockLocation();
    }
  }

  Future<void> _checkMockLocation() async {
    if (_isWarningShowing) return;
    final bool isMock = await MockLocationGuardService.isMockLocationActive();
    if (isMock && mounted) {
      _isWarningShowing = true;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MockLocationWarningScreen(
            onResolved: () {
              if (mounted && Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
      );
      _isWarningShowing = false;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthProvider>();
    final success = await auth.login(_emailController.text.trim(), _passwordController.text);

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 450),
          pageBuilder: (_, animation, __) => FadeTransition(opacity: animation, child: const HomeShell()),
        ),
      );
    } else if (auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage!),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _openForgotPasswordSheet(BuildContext context) {
    ForgotPasswordModal.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _bgOpacityAnimation.value,
                  child: child,
                );
              },
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
          ),
          // Dark Red-Black Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.redDark.withValues(alpha: 0.45),
                    AppColors.black.withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),
          ),
          // Responsive Content Area
          Positioned.fill(
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 32,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Top Section: KPI Logo & Title
                          Column(
                            children: [
                              SizedBox(height: constraints.maxHeight * 0.025),
                              Image.asset(
                                'assets/images/logo-kpi.png',
                                width: 80,
                                height: 80,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'SIMPEG-KPI',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Sistem Informasi Kepegawaian',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                          // Gap pushing card lower down
                          SizedBox(height: constraints.maxHeight * 0.08),
                          // Middle Section: Frosted Glass Login Card
                          AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: _cardSlideAnimation.value,
                                child: Transform.scale(
                                  scale: _cardScaleAnimation.value,
                                  child: Opacity(
                                    opacity: _cardOpacityAnimation.value,
                                    child: child,
                                  ),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.11),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.22),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                          'Selamat Datang',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: Colors.white,
                                            fontSize: 19,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.2,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Masuk untuk mengelola presensi, cuti, dan data kepegawaian Anda.',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: Colors.white.withValues(alpha: 0.7),
                                            fontSize: 12,
                                            height: 1.4,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 18),
                                        _DarkField(
                                          controller: _emailController,
                                          hint: 'Email',
                                          icon: Icons.mail_outline_rounded,
                                          keyboardType: TextInputType.emailAddress,
                                          validator: (v) {
                                            if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                                            if (!v.contains('@')) return 'Format email tidak valid';
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 10),
                                        _DarkField(
                                          controller: _passwordController,
                                          hint: 'Kata Sandi',
                                          icon: Icons.lock_outline_rounded,
                                          obscureText: _obscure,
                                          suffix: IconButton(
                                            icon: Icon(
                                              _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                              color: Colors.white.withValues(alpha: 0.55),
                                              size: 20,
                                            ),
                                            onPressed: () => setState(() => _obscure = !_obscure),
                                          ),
                                          validator: (v) => (v == null || v.isEmpty) ? 'Kata sandi wajib diisi' : null,
                                        ),
                                        const SizedBox(height: 18),
                                        ElevatedButton(
                                          onPressed: auth.isLoading ? null : _submit,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.red,
                                            disabledBackgroundColor: AppColors.red.withValues(alpha: 0.5),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 13.5),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                            elevation: 2,
                                            shadowColor: AppColors.red.withValues(alpha: 0.3),
                                          ),
                                          child: auth.isLoading
                                              ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2.2,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : Text(
                                                  'Masuk',
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontSize: 14.5,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white,
                                                    letterSpacing: 0.6,
                                                  ),
                                                ),
                                        ),
                                        const SizedBox(height: 12),
                                        Center(
                                          child: InkWell(
                                            onTap: () => _openForgotPasswordSheet(context),
                                            borderRadius: BorderRadius.circular(8),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                              child: Text(
                                                'Lupa Kata Sandi?',
                                                style: GoogleFonts.plusJakartaSans(
                                                  color: Colors.white.withValues(alpha: 0.8),
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w600,
                                                  decoration: TextDecoration.underline,
                                                  decorationColor: Colors.white.withValues(alpha: 0.5),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Bottom Section: Copyright Anchored at Bottom
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '© ${DateTime.now().year} Komisi Penyiaran Indonesia Pusat',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 11,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}



class _DarkField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _DarkField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.32),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 13.5),
        prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.55), size: 20),
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.22), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.2),
        ),
        errorStyle: const TextStyle(color: Color(0xFFFF8A8A), fontSize: 11.5),
      ),
    );
  }
}
