import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/status_badge.dart';
import '../auth/auth_provider.dart';
import '../auth/login_screen.dart';
import 'profile_provider.dart';
import 'data_pegawai_screen.dart';
import 'pengajuan_perubahan_screen.dart';
import '../notification/widgets/pengaturan_notifikasi_sheet.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileProvider()..load(),
      child: const _ProfileBody(),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Keluar Aplikasi', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: Text('Anda yakin ingin keluar dari akun ini?', style: GoogleFonts.plusJakartaSans(fontSize: 13.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: AppColors.gray, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Keluar', style: GoogleFonts.plusJakartaSans(color: AppColors.danger, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthProvider>().logout();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  void _openChangePasswordSheet(BuildContext context) {
    final provider = context.read<ProfileProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(value: provider, child: const _ChangePasswordSheet()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final pegawai = auth.user?.pegawai;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: AppColors.heroGradient),
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(color: AppColors.red.withValues(alpha: 0.28), blurRadius: 22, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: pegawai?.foto != null && pegawai!.foto!.isNotEmpty
                          ? Image.network(
                              pegawai.foto!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Text(
                                    pegawai.initials,
                                    style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Text(
                                pegawai?.initials ?? '?',
                                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    pegawai?.nama ?? auth.user?.name ?? '',
                    style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.black),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    pegawai?.jabatan ?? '-',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  if (pegawai?.statusKepegawaian != null)
                    StatusBadge(label: pegawai!.statusKepegawaian!, tone: BadgeTone.info),
                ],
              ),
            ),
            const SizedBox(height: 26),
            _SectionCard(
              children: [
                _InfoRow(icon: Icons.badge_outlined, label: 'NIP', value: pegawai?.nip ?? '-'),
                _InfoRow(icon: Icons.apartment_rounded, label: 'Unit Kerja', value: pegawai?.unit ?? '-'),
                _InfoRow(icon: Icons.mail_outlined, label: 'Email', value: pegawai?.email ?? auth.user?.email ?? '-'),
                _InfoRow(icon: Icons.call_outlined, label: 'No. HP', value: pegawai?.noHp ?? '-'),
                _InfoRow(icon: Icons.location_on_outlined, label: 'Alamat', value: pegawai?.alamat ?? '-', isLast: true),
              ],
            ),
            const SizedBox(height: 24),

            // Section 1: Data Kepegawaian
            const _SectionHeader(title: 'KEPEGAWAIAN'),
            const SizedBox(height: 8),
            _MenuTile(
              icon: Icons.badge_outlined,
              label: 'Data Pegawai Lengkap',
              subtitle: 'Profil pribadi, keluarga, & dokumen',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DataPegawaiScreen())),
            ),
            const SizedBox(height: 10),
            _MenuTile(
              icon: Icons.edit_note_rounded,
              label: 'Pengajuan Perubahan Data',
              subtitle: 'Form pembaharuan data & riwayat pengajuan',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PengajuanPerubahanScreen()),
                ).then((_) {
                  if (context.mounted) {
                    context.read<ProfileProvider>().load();
                  }
                });
              },
            ),

            const SizedBox(height: 22),

            // Section 2: Pengaturan Aplikasi & Keamanan
            const _SectionHeader(title: 'PENGATURAN APLIKASI'),
            const SizedBox(height: 8),
            _MenuTile(
              icon: Icons.notifications_active_outlined,
              label: 'Pengaturan Notifikasi Presensi',
              subtitle: 'Atur pengingat shift & absen otomatis',
              onTap: () => PengaturanNotifikasiSheet.show(context),
            ),
            const SizedBox(height: 10),
            _MenuTile(
              icon: Icons.lock_outline_rounded,
              label: 'Ubah Password Akun',
              subtitle: 'Ganti kata sandi akun SIMPEG-KPI',
              onTap: () => _openChangePasswordSheet(context),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _confirmLogout(context),
                icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.danger),
                label: Text('Keluar dari Akun', style: GoogleFonts.plusJakartaSans(color: AppColors.danger, fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.dangerSoft, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF64748B),
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;
  const _InfoRow({required this.icon, required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF64748B)),
          const SizedBox(width: 14),
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF64748B), fontWeight: FontWeight.w500)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.black),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  const _MenuTile({required this.icon, required this.label, this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(color: AppColors.redSoft, borderRadius: BorderRadius.circular(11)),
                child: Icon(icon, size: 19, color: AppColors.red),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13.5, color: AppColors.black),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.grayLight, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mohon periksa kembali password yang dimasukkan.', style: GoogleFonts.plusJakartaSans(fontSize: 13)),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    try {
      await context.read<ProfileProvider>().ubahPassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
        newPasswordConfirmation: _confirmPasswordController.text,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kata sandi berhasil diubah.', style: GoogleFonts.plusJakartaSans(fontSize: 13)),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e is ApiException ? e.friendlyMessage : 'Terjadi kesalahan: $e', style: GoogleFonts.plusJakartaSans(fontSize: 13)),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
        decoration: const BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(999)))),
              const SizedBox(height: 20),
              Text('Ubah Password', style: GoogleFonts.plusJakartaSans(fontSize: 16.5, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Masukkan kata sandi lama Anda dan kata sandi baru.', style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppColors.gray)),
              const SizedBox(height: 20),
              TextFormField(
                controller: _currentPasswordController,
                obscureText: _obscureCurrent,
                style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
                decoration: InputDecoration(
                  labelText: 'Password Lama',
                  hintText: 'Masukkan password lama',
                  suffixIcon: IconButton(
                    icon: Icon(_obscureCurrent ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNew,
                style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
                decoration: InputDecoration(
                  labelText: 'Password Baru',
                  hintText: 'Masukkan password baru (min. 8 karakter)',
                  suffixIcon: IconButton(
                    icon: Icon(_obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Wajib diisi';
                  if (v.length < 8) return 'Password baru minimal 8 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Password Baru',
                  hintText: 'Masukkan kembali password baru',
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Wajib diisi';
                  if (v != _newPasswordController.text) return 'Konfirmasi harus sama dengan password baru';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: provider.isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: provider.isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white))
                    : Text('Simpan Password', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
