import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/models/notification_item.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/bouncing_button.dart';
import '../../core/widgets/empty_state.dart';
import '../auth/auth_provider.dart';
import '../cuti/cuti_detail_screen.dart';
import '../cuti/cuti_list_screen.dart';
import '../cuti/cuti_provider.dart';
import 'notification_provider.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final itemDate = DateTime(dt.year, dt.month, dt.day);

    final timeStr = DateFormat('HH:mm').format(dt);

    if (itemDate == today) {
      return 'Hari ini, $timeStr';
    } else if (itemDate == yesterday) {
      return 'Kemarin, $timeStr';
    } else {
      return '${DateFormat('dd MMM yyyy', 'id_ID').format(dt)}, $timeStr';
    }
  }

  void _handleNotificationTap(NotificationItem item) {
    // 1. Mark as read
    if (!item.isRead) {
      context.read<NotificationProvider>().markAsRead(item.id);
    }

    // 2. Handle Payload navigation
    final payload = item.payload;
    if (payload == null || payload.isEmpty) return;

    final type = payload['type']?.toString() ?? item.type;
    final idStr = payload['id']?.toString();
    final isAtasan = context.read<AuthProvider>().isAtasan;

    if (type == 'cuti') {
      if (idStr != null && int.tryParse(idStr) != null) {
        final cutiId = int.parse(idStr);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider(
              create: (_) => CutiProvider()..loadAll(isAtasan: isAtasan),
              child: CutiDetailScreen(cutiId: cutiId),
            ),
          ),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const CutiListScreen(initialTab: 0),
          ),
        );
      }
    }
  }

  void _confirmClearAll() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Hapus Semua Notifikasi?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        content: Text(
          'Semua riwayat notifikasi akan dihapus secara permanen.',
          style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.gray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(color: AppColors.gray, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              context.read<NotificationProvider>().clearAll();
              Navigator.pop(ctx);
            },
            child: Text(
              'Hapus',
              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final unreadCount = provider.unreadCount;
    final items = provider.filteredItems;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: BouncingButton(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A), size: 20),
            ),
          ),
        ),
        title: Row(
          children: [
            Text(
              'Pusat Notifikasi',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unreadCount Baru',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (provider.items.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF0F172A)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onSelected: (value) {
                if (value == 'read_all') {
                  provider.markAllAsRead();
                } else if (value == 'clear_all') {
                  _confirmClearAll();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'read_all',
                  child: Row(
                    children: [
                      const Icon(Icons.done_all_rounded, size: 18, color: Color(0xFF475569)),
                      const SizedBox(width: 10),
                      Text(
                        'Tandai Semua Dibaca',
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.red),
                      const SizedBox(width: 10),
                      Text(
                        'Hapus Semua',
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.red),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          _CategoryFilterBar(
            selectedCategory: provider.selectedCategory,
            onSelect: (cat) => provider.setCategory(cat),
          ),

          const SizedBox(height: 10),

          // Main List / Empty State
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.red))
                : items.isEmpty
                    ? RefreshIndicator(
                        onRefresh: () => provider.loadNotifications(),
                        color: AppColors.red,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 80),
                            child: EmptyState(
                              icon: Icons.notifications_off_outlined,
                              title: 'Belum Ada Notifikasi',
                              subtitle: provider.selectedCategory == 'semua'
                                  ? 'Riwayat notifikasi dan pemberitahuan penting Anda akan muncul di sini.'
                                  : 'Tidak ada notifikasi untuk kategori yang dipilih.',
                            ),
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => provider.loadNotifications(),
                        color: AppColors.red,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 30),
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return _NotificationCard(
                              item: item,
                              timeFormatted: _formatTimestamp(item.timestamp),
                              onTap: () => _handleNotificationTap(item),
                              onDelete: () => provider.deleteNotification(item.id),
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

class _CategoryFilterBar extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onSelect;

  const _CategoryFilterBar({
    required this.selectedCategory,
    required this.onSelect,
  });

  static const _categories = [
    ('semua', 'Semua', Icons.grid_view_rounded),
    ('cuti', 'Cuti & Izin', Icons.event_available_rounded),
    ('absensi', 'Presensi', Icons.fingerprint_rounded),
    ('perubahan_data', 'Profil', Icons.manage_accounts_rounded),
    ('pengumuman', 'Pengumuman', Icons.campaign_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = selectedCategory == cat.$1;

          return BouncingButton(
            onTap: () => onSelect(cat.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.black : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.black : Colors.black.withValues(alpha: 0.08),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Icon(
                    cat.$3,
                    size: 15,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat.$2,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationItem item;
  final String timeFormatted;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.item,
    required this.timeFormatted,
    required this.onTap,
    required this.onDelete,
  });

  IconData _getIcon() {
    switch (item.type) {
      case 'cuti':
        return Icons.event_available_rounded;
      case 'absensi':
        return Icons.fingerprint_rounded;
      case 'perubahan_data':
        return Icons.manage_accounts_rounded;
      case 'pelatihan':
        return Icons.school_rounded;
      case 'pengumuman':
        return Icons.campaign_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  Color _getIconBgColor() {
    switch (item.type) {
      case 'cuti':
        return const Color(0xFFEEF2FF);
      case 'absensi':
        return const Color(0xFFECFDF5);
      case 'perubahan_data':
        return const Color(0xFFFFF7ED);
      case 'pelatihan':
        return const Color(0xFFF3E8FF);
      case 'pengumuman':
        return const Color(0xFFFEF2F2);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  Color _getIconColor() {
    switch (item.type) {
      case 'cuti':
        return const Color(0xFF4F46E5);
      case 'absensi':
        return const Color(0xFF10B981);
      case 'perubahan_data':
        return const Color(0xFFF97316);
      case 'pelatihan':
        return const Color(0xFF9333EA);
      case 'pengumuman':
        return AppColors.red;
      default:
        return const Color(0xFF475569);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 22),
      ),
      child: BouncingButton(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: item.isRead ? Colors.white : const Color(0xFFFFFDF8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: item.isRead ? Colors.black.withValues(alpha: 0.06) : AppColors.red.withValues(alpha: 0.25),
              width: item.isRead ? 1.0 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: item.isRead ? Colors.black.withValues(alpha: 0.03) : AppColors.red.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Badge
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _getIconBgColor(),
                  shape: BoxShape.circle,
                ),
                child: Icon(_getIcon(), size: 21, color: _getIconColor()),
              ),
              const SizedBox(width: 12),

              // Title & Body
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: item.isRead ? FontWeight.w700 : FontWeight.w800,
                              color: const Color(0xFF0F172A),
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        if (!item.isRead) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: const BoxDecoration(
                              color: AppColors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (item.body.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.body,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          color: const Color(0xFF475569),
                          height: 1.35,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 13, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 4),
                        Text(
                          timeFormatted,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
