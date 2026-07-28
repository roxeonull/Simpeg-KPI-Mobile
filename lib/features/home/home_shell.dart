import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/bouncing_button.dart';
import '../absensi/absensi_screen.dart';
import '../auth/auth_provider.dart';
import '../cuti/cuti_list_screen.dart';
import '../cuti/cuti_provider.dart';
import '../dashboard/dashboard_screen.dart';
import '../profile/profile_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final _screens = const [
    DashboardScreen(),
    AbsensiScreen(),
    CutiListScreen(),
    ProfileScreen(),
  ];

  final _items = const [
    (icon: Icons.grid_view_rounded, label: 'Beranda'),
    (icon: Icons.fingerprint_rounded, label: 'Absensi'),
    (icon: Icons.event_note_rounded, label: 'Cuti'),
    (icon: Icons.person_rounded, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    final isAtasan = context.watch<AuthProvider>().isAtasan;

    return ChangeNotifierProvider(
      create: (_) => CutiProvider()..loadAll(isAtasan: isAtasan),
      child: Builder(
        builder: (context) {
          final pendingCount = isAtasan ? context.watch<CutiProvider>().pendingAtasanCount : 0;

          return Scaffold(
            backgroundColor: AppColors.cream,
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.015, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey<int>(_index),
                child: _screens[_index],
              ),
            ),
            bottomNavigationBar: SafeArea(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.22),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(_items.length, (i) {
                    final selected = i == _index;
                    final item = _items[i];
                    final isCutiTab = i == 2;

                    return Expanded(
                      child: BouncingButton(
                        scaleFactor: 0.94,
                        onTap: () {
                          if (_index != i) {
                            HapticFeedback.lightImpact();
                            setState(() => _index = i);
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.red : Colors.transparent,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: selected
                                ? [
                                    BoxShadow(
                                      color: AppColors.red.withOpacity(0.4),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Icon(
                                    item.icon,
                                    size: 21,
                                    color: selected ? Colors.white : Colors.white.withOpacity(0.45),
                                  ),
                                  if (isCutiTab && isAtasan && pendingCount > 0)
                                    Positioned(
                                      top: -3,
                                      right: -7,
                                      child: Container(
                                        padding: const EdgeInsets.all(3.5),
                                        decoration: BoxDecoration(
                                          color: selected ? Colors.white : AppColors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '$pendingCount',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: selected ? AppColors.red : Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                  color: selected ? Colors.white : Colors.white.withOpacity(0.45),
                                  letterSpacing: -0.1,
                                ),
                                child: Text(item.label),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
