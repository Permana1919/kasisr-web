import 'package:flutter/material.dart';

import 'package:app_hafalan_quran/screens/menghafal_screen.dart';
import 'package:app_hafalan_quran/screens/placeholder_screen.dart';
import 'package:app_hafalan_quran/screens/quran_list_screen.dart';
import 'package:app_hafalan_quran/theme/app_icons.dart';
import 'package:app_hafalan_quran/theme/app_theme.dart';
import 'package:app_hafalan_quran/widgets/app_bottom_nav.dart';
import 'package:app_hafalan_quran/widgets/app_icon.dart';
import 'package:app_hafalan_quran/widgets/avatar_badge.dart';
import 'package:app_hafalan_quran/widgets/feature_tile.dart';
import 'package:app_hafalan_quran/widgets/mosque_background.dart';

/// Kerangka utama: konten + bottom navigation.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, this.initialIndex = 0});

  static const String route = '/home';
  static const String routeQuran = '/quran';
  static const String routeMenghafal = '/menghafal';
  static const String routePengaturan = '/pengaturan';

  /// Tab yang langsung dibuka (0 = Home, 1 = Quran, 2 = Menghafal,
  /// 3 = Pengaturan).
  final int initialIndex;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late int _index = widget.initialIndex;

  void _selectTab(int index) {
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.homeBottom,
      drawer: _AppDrawer(
        currentIndex: _index,
        onSelect: (index) {
          Navigator.of(context).pop();
          _selectTab(index);
        },
      ),
      body: MosqueBackground(
        bottomInset: AppBottomNav.barHeight + safeBottom,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: IndexedStack(
                  index: _index,
                  children: [
                    HomeScreen(onOpenQuran: () => _selectTab(1)),
                    const QuranListScreen(),
                    const MenghafalScreen(),
                    const PlaceholderScreen(
                      title: 'Pengaturan',
                      subtitle: 'Halaman pengaturan belum dibuat',
                      iconAsset: AppIcons.pengaturan,
                    ),
                  ],
                ),
              ),
              AppBottomNav(
                index: _index,
                onChanged: _selectTab,
                bottomPadding: safeBottom,
                items: const [
                  AppNavItem(asset: AppIcons.home, size: 28),
                  AppNavItem(asset: AppIcons.quran, size: 29),
                  AppNavItem(asset: AppIcons.menghafal, size: 27),
                  AppNavItem(asset: AppIcons.pengaturan, size: 27),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onOpenQuran});

  final VoidCallback onOpenQuran;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Column(
        children: [
          const AvatarBadge(size: 38, iconSize: 22, borderWidth: 1.5),
          const SizedBox(height: 18),
          const _ActivityCard(),
          const SizedBox(height: 22),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                'Fitur',
                style: serifStyle(20, color: AppColors.white),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FeatureTile(
                  label: 'Jadwal Salat',
                  icon: AppIcon(
                    AppIcons.jadwalSalat,
                    size: 34,
                    color: AppColors.ink,
                  ),
                ),
                FeatureTile(
                  label: 'Doa',
                  icon: AppIcon(AppIcons.doa, size: 38, color: AppColors.ink),
                ),
                FeatureTile(
                  label: 'Quran',
                  icon: AppIcon(AppIcons.quran, size: 38, color: AppColors.ink),
                  onTap: onOpenQuran,
                ),
                const FeatureTile(label: '', filled: true),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const _StreakCard(),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(30, 22, 30, 30),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.45),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text('Activity', style: serifStyle(17, color: AppColors.white)),
          const SizedBox(height: 24),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 104,
                child: Column(
                  children: [
                    _GreyBox(height: 40),
                    SizedBox(height: 16),
                    _GreyBox(height: 40),
                  ],
                ),
              ),
              SizedBox(width: 16),
              Expanded(child: _GreyBox(height: 96)),
            ],
          ),
          const SizedBox(height: 26),
          Container(
            height: 32,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.greyBar,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              'PROGRES BAR',
              style: serifStyle(
                13.5,
                color: AppColors.ink,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GreyBox extends StatelessWidget {
  const _GreyBox({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 26),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Streak Mingguan',
            style: sansStyle(15, weight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var day = 1; day <= 7; day++)
                Column(
                  children: [
                    day == 1
                        ? const AppIcon(AppIcons.campfire, size: 22)
                        : const AppIcon(
                            AppIcons.campfireBw,
                            size: 22,
                            color: Color(0xFFBFBFBF),
                            blendMode: BlendMode.modulate,
                          ),
                    const SizedBox(height: 10),
                    Text('$day', style: sansStyle(12.5)),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 2),
          Center(child: Text('Hari', style: serifStyle(30, height: 1.15))),
        ],
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({required this.currentIndex, required this.onSelect});

  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    const items = [
      (AppIcons.home, 'Home'),
      (AppIcons.quran, 'Quran'),
      (AppIcons.menghafal, 'Menghafal'),
      (AppIcons.pengaturan, 'Pengaturan'),
    ];

    return Drawer(
      backgroundColor: AppColors.darkGreen,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Text(
                'Salam App',
                style: serifStyle(26, color: AppColors.white),
              ),
            ),
            for (var i = 0; i < items.length; i++)
              ListTile(
                selected: currentIndex == i,
                selectedTileColor: AppColors.white.withValues(alpha: 0.08),
                leading: AppIcon(
                  items[i].$1,
                  size: 22,
                  color: AppColors.white,
                ),
                title: Text(
                  items[i].$2,
                  style: sansStyle(14, color: AppColors.white),
                ),
                onTap: () => onSelect(i),
              ),
          ],
        ),
      ),
    );
  }
}
