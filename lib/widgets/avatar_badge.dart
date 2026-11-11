import 'package:flutter/material.dart';

import 'package:app_hafalan_quran/theme/app_theme.dart';

/// Lingkaran avatar dengan ikon orang, dipakai di Login dan Home.
class AvatarBadge extends StatelessWidget {
  const AvatarBadge({
    super.key,
    this.size = 54,
    this.iconSize = 30,
    this.borderWidth = 1.6,
  });

  final double size;
  final double iconSize;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.white, width: borderWidth),
      ),
      child: Icon(Icons.person, size: iconSize, color: AppColors.white),
    );
  }
}
