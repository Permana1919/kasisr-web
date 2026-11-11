import 'package:flutter/material.dart';

import 'package:app_hafalan_quran/screens/home_screen.dart';
import 'package:app_hafalan_quran/screens/login_screen.dart';
import 'package:app_hafalan_quran/screens/mushaf_screen.dart';
import 'package:app_hafalan_quran/screens/register_screen.dart';
import 'package:app_hafalan_quran/screens/surah_detail_screen.dart';
import 'package:app_hafalan_quran/theme/app_theme.dart';

void main() {
  runApp(const SalamApp());
}

class SalamApp extends StatelessWidget {
  const SalamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Salam App',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      builder: (context, child) {
        // Di layar lebar (web/desktop) tampilan dikunci selebar ponsel.
        return ColoredBox(
          color: AppColors.darkGreenDeep,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
      initialRoute: LoginScreen.route,
      routes: {
        LoginScreen.route: (_) => const LoginScreen(),
        RegisterScreen.route: (_) => const RegisterScreen(),
        HomeShell.route: (_) => const HomeShell(),
        HomeShell.routeQuran: (_) => const HomeShell(initialIndex: 1),
        HomeShell.routeMenghafal: (_) => const HomeShell(initialIndex: 2),
        HomeShell.routePengaturan: (_) => const HomeShell(initialIndex: 3),
        SurahDetailScreen.route: (_) => const SurahDetailScreen(),
        MushafScreen.route: (_) => const MushafScreen(),
      },
    );
  }
}
