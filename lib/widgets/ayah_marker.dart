import 'package:flutter/material.dart';

import 'package:app_hafalan_quran/theme/app_theme.dart';

/// Penanda nomor ayat: dua lingkaran tipis dengan angka Arab di tengah.
class AyahMarker extends StatelessWidget {
  const AyahMarker({super.key, required this.number, this.size = 32});

  final int number;
  final double size;

  static const List<String> _digits = [
    '٠',
    '١',
    '٢',
    '٣',
    '٤',
    '٥',
    '٦',
    '٧',
    '٨',
    '٩',
  ];

  @override
  Widget build(BuildContext context) {
    final label = number < _digits.length ? _digits[number] : '$number';

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.ink, width: 1.2),
      ),
      child: Container(
        width: size - 7,
        height: size - 7,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.ink, width: 0.7),
        ),
        child: Text(
          label,
          style: arabicStyle(size * 0.42, height: 1),
        ),
      ),
    );
  }
}
