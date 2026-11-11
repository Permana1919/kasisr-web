import 'package:flutter/material.dart';

/// Menampilkan ikon PNG dari assets.
///
/// Ikon hitam bisa diwarnai ulang lewat [color]; gambar berwarna
/// (misalnya api) cukup dibiarkan tanpa [color].
class AppIcon extends StatelessWidget {
  const AppIcon(
    this.asset, {
    super.key,
    this.size = 24,
    this.color,
    this.blendMode = BlendMode.srcIn,
  });

  final String asset;
  final double size;
  final Color? color;
  final BlendMode blendMode;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: color,
      colorBlendMode: blendMode,
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
    );
  }
}
