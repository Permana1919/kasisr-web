import 'package:flutter/material.dart';

import 'package:app_hafalan_quran/theme/app_icons.dart';
import 'package:app_hafalan_quran/theme/app_theme.dart';

/// Latar halaman: gradien hijau dengan foto masjid di bagian bawah.
///
/// Gambar `bg-masjid.png` sudah punya alpha sendiri (bagian langit
/// transparan), jadi dipakai apa adanya tanpa [Opacity] tambahan.
class MosqueBackground extends StatelessWidget {
  const MosqueBackground({
    super.key,
    required this.child,
    this.gradient = AppColors.homeGradient,
    this.imageOpacity = 1,
    this.bottomInset = 0,
  });

  final Widget child;
  final Gradient gradient;

  /// Pengali alpha gambar. Bawaan 1 karena alpha sudah ada di file PNG.
  final double imageOpacity;

  /// Bagian bawah yang tidak ditutup gambar (misalnya bottom navigation).
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: gradient),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: bottomInset,
            child: Opacity(
              opacity: imageOpacity,
              child: Image.asset(
                AppIcons.masjidBackground,
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
