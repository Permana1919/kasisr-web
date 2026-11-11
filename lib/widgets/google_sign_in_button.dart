import 'package:flutter/material.dart';

import 'package:app_hafalan_quran/theme/app_icons.dart';
import 'package:app_hafalan_quran/theme/app_theme.dart';

/// Tombol "Sign in with Google" memakai gambar PNG dari assets.
///
/// Bagian dalam gambar transparan, jadi di belakangnya dipasang pill putih
/// agar latar tombol tetap putih seperti referensi.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    this.onPressed,
    this.width = 180,
  });

  final VoidCallback? onPressed;
  final double width;

  // Proporsi gambar `icon-google.png` (422x98).
  static const double _aspectRatio = 422 / 98;

  @override
  Widget build(BuildContext context) {
    final height = width / _aspectRatio;

    return Semantics(
      button: true,
      label: 'Sign in with Google',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(height / 2),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(height / 2),
            ),
            child: Image.asset(
              AppIcons.googleButton,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.medium,
            ),
          ),
        ),
      ),
    );
  }
}
