import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/status_badge.dart';
import '../auth/auth_provider.dart';
import '../auth/login_screen.dart';
import '../riwayat/riwayat_screen.dart';
import 'profile_provider.dart';
import 'data_pegawai_screen.dart';
import 'pengajuan_perubahan_screen.dart';

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Keluar Aplikasi'),
        content: const Text('Anda yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar', style: TextStyle(color: AppColors.danger)),
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
    final profileProvider = context.watch<ProfileProvider>();
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
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: AppColors.heroGradient),
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [BoxShadow(color: AppColors.red.withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 8))],
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
                                    style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Text(
                                pegawai?.initials ?? '?',
                                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(pegawai?.nama ?? auth.user?.name ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(pegawai?.jabatan ?? '-', style: const TextStyle(fontSize: 13, color: AppColors.gray)),
                  const SizedBox(height: 10),
                  if (pegawai?.statusKepegawaian != null)
                    StatusBadge(label: pegawai!.statusKepegawaian!, tone: BadgeTone.info),
                ],
              ),
            ),
            const SizedBox(height: 26),
            _SectionCard(
              children: [
                _InfoRow(icon: Icons.badge_rounded, label: 'NIP', value: pegawai?.nip ?? '-'),
                _InfoRow(icon: Icons.apartment_rounded, label: 'Unit Kerja', value: pegawai?.unit ?? '-'),
                _InfoRow(icon: Icons.mail_rounded, label: 'Email', value: pegawai?.email ?? auth.user?.email ?? '-'),
                _InfoRow(icon: Icons.call_rounded, label: 'No. HP', value: pegawai?.noHp ?? '-'),
                _InfoRow(icon: Icons.location_on_rounded, label: 'Alamat', value: pegawai?.alamat ?? '-', isLast: true),
              ],
            ),
            const SizedBox(height: 16),
            _MenuTile(
              icon: Icons.badge_rounded,
              label: 'Data Pegawai',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DataPegawaiScreen())),
            ),
            const SizedBox(height: 10),
            _MenuTile(
              icon: Icons.school_rounded,
              label: 'Riwayat Pendidikan & Diklat',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RiwayatScreen())),
            ),
            const SizedBox(height: 10),
            _MenuTile(
              icon: Icons.lock_outline_rounded,
              label: 'Ubah Password',
              onTap: () => _openChangePasswordSheet(context),
            ),
            const SizedBox(height: 10),
            _MenuTile(
              icon: Icons.edit_note_rounded,
              label: 'Ajukan Perubahan Data',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PengajuanPerubahanScreen()),
                ).then((_) {
                  context.read<ProfileProvider>().load();
                });
              },
            ),
            const SizedBox(height: 22),
            const Text('Riwayat Pengajuan Perubahan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
            const SizedBox(height: 12),
            if (profileProvider.isLoading)
              const SizedBox(height: 60, child: Center(child: CircularProgressIndicator(color: AppColors.red, strokeWidth: 2)))
            else if (profileProvider.pengajuan.isEmpty)
              const EmptyState(icon: Icons.fact_check_outlined, title: 'Belum ada pengajuan perubahan data')
            else
              ...profileProvider.pengajuan.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _PengajuanTile(item: p),
                  )),
            const SizedBox(height: 26),
            OutlinedButton.icon(
              onPressed: () => _confirmLogout(context),
              icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.danger),
              label: const Text('Keluar', style: TextStyle(color: AppColors.danger)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.dangerSoft, width: 1.4)),
            ),
          ],
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.grayLight),
          const SizedBox(width: 14),
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.gray)),
          const Spacer(),
          Flexible(
            child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(color: AppColors.redSoft, borderRadius: BorderRadius.circular(11)),
                child: Icon(icon, size: 17, color: AppColors.red),
              ),
              const SizedBox(width: 14),
              Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5))),
              const Icon(Icons.chevron_right_rounded, color: AppColors.grayLight),
            ],
          ),
        ),
      ),
    );
  }
}

class _PengajuanTile extends StatelessWidget {
  final PengajuanPerubahan item;
  const _PengajuanTile({required this.item});

  BadgeTone get _tone {
    switch (item.status) {
      case 'disetujui':
        return BadgeTone.success;
      case 'ditolak':
        return BadgeTone.danger;
      default:
        return BadgeTone.warning;
    }
  }

  String _getFieldLabel(String field) {
    switch (field) {
      case 'no_hp':
        return 'No. HP Utama';
      case 'email':
        return 'Email Resmi';
      case 'email_pribadi':
        return 'Email Pribadi';
      case 'alamat':
        return 'Alamat Lengkap';
      case 'nama_panggilan':
        return 'Nama Panggilan';
      case 'status_marital':
        return 'Status Pernikahan';
      case 'golongan_darah':
        return 'Golongan Darah';
      case 'agama':
        return 'Agama';
      case 'hobi':
        return 'Hobi';
      default:
        return field.split('_').map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1);
        }).join(' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_getFieldLabel(item.field), style: const TextStyle(fontSize: 11.5, color: AppColors.grayLight, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(item.nilaiBaru, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          StatusBadge(label: item.status[0].toUpperCase() + item.status.substring(1), tone: _tone),
        ],
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
          content: const Text('Mohon periksa kembali password yang dimasukkan.'),
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
            content: const Text('Kata sandi berhasil diubah.'),
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
            content: Text(e is ApiException ? e.friendlyMessage : 'Terjadi kesalahan: $e'),
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
              const Text('Ubah Password', style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              const Text('Masukkan kata sandi lama Anda dan kata sandi baru.', style: TextStyle(fontSize: 12.5, color: AppColors.gray)),
              const SizedBox(height: 20),
              TextFormField(
                controller: _currentPasswordController,
                obscureText: _obscureCurrent,
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
                child: provider.isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white))
                    : const Text('Simpan Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
