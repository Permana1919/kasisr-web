import 'package:flutter/material.dart';

import 'package:app_hafalan_quran/theme/app_theme.dart';

/// Tombol utama berwarna hijau tosca dengan teks serif.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.teal,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          label,
          style: serifStyle(
            30,
            weight: FontWeight.w500,
            color: AppColors.white,
            height: 1.1,
          ),
        ),
      ),
    );
  }
}
