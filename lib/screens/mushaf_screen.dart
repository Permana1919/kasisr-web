import 'package:flutter/material.dart';

import 'package:app_hafalan_quran/screens/menghafal_screen.dart';
import 'package:app_hafalan_quran/theme/app_theme.dart';
import 'package:app_hafalan_quran/widgets/mosque_background.dart';

/// Mode hafalan yang dibuka lewat ikon gear di halaman isi surah.
///
/// Tampilannya sama dengan tab Menghafal, hanya dibungkus Scaffold sendiri
/// supaya bisa dibuka sebagai halaman penuh.
class MushafScreen extends StatelessWidget {
  const MushafScreen({super.key});

  static const String route = '/mushaf';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBottom,
      body: MosqueBackground(
        gradient: AppColors.homeGradient,
        child: SafeArea(child: const MenghafalScreen(embedded: false)),
      ),
    );
  }
}
