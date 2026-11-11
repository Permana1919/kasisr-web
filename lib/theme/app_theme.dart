import 'package:flutter/material.dart';

/// Palet warna hasil sampling dari video referensi.
class AppColors {
  const AppColors._();

  static const Color ink = Color(0xFF161616);
  static const Color inkSoft = Color(0xFF2C2C2C);

  // Latar hijau gelap (Login / Daftar)
  static const Color darkGreen = Color(0xFF1E5B2C);
  static const Color darkGreenDeep = Color(0xFF14411F);

  // Latar Home / halaman Quran
  static const Color homeTop = Color(0xFF175A27);
  static const Color homeBottom = Color(0xFF81B47C);

  static const Color teal = Color(0xFF2B6F34);
  static const Color tealDark = Color(0xFF205C2B);
  static const Color tealLight = Color(0xFF3E8446);

  static const Color sheet = Color(0xFFFFFFFF);
  static const Color sheetSoft = Color(0xFFF7FBF4);
  static const Color field = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFFDCDCDC);
  static const Color greyBar = Color(0xFFFFFFFF);
  static const Color navIcon = Color(0xFF9E9E9E);
  static const Color navActive = Color(0xFF4E8F33);
  static const Color mint = Color(0xFFE0F3DB);
  static const Color tile = Color(0xFFE0F3DB);
  static const Color cream = Color(0xFFF9F1DA);
  static const Color latin = Color(0xFF8A7A4A);
  static const Color white = Color(0xFFFFFFFF);

  static const LinearGradient loginGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1B5A29), Color(0xFF2E7537)],
  );

  static const LinearGradient homeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [homeTop, Color(0xFF266A2F), homeBottom],
    stops: [0, 0.32, 1],
  );

  /// Latar bottom navigation: hijau transparan di atas gradien halaman.
  static const LinearGradient navGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x2EFFFFFF), Color(0x1FFFFFFF)],
  );
}

class AppFonts {
  const AppFonts._();

  static const String serif = 'PlayfairDisplay';
  static const String sans = 'Inter';
  static const String arabic = 'Amiri';
}

/// Helper singkat supaya pemakaian gaya teks konsisten.
TextStyle serifStyle(
  double size, {
  FontWeight weight = FontWeight.w500,
  Color color = AppColors.ink,
  double? height,
  double? letterSpacing,
}) {
  return TextStyle(
    fontFamily: AppFonts.serif,
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );
}

TextStyle sansStyle(
  double size, {
  FontWeight weight = FontWeight.w400,
  Color color = AppColors.ink,
  double? height,
  double? letterSpacing,
}) {
  return TextStyle(
    fontFamily: AppFonts.sans,
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );
}

/// Teks Arab memakai Amiri (naskh) supaya harakat terlihat rapi.
TextStyle arabicStyle(
  double size, {
  FontWeight weight = FontWeight.w400,
  Color color = AppColors.ink,
  double? height,
}) {
  return TextStyle(
    fontFamily: AppFonts.arabic,
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height ?? 1.8,
  );
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.darkGreen,
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      fontFamily: AppFonts.sans,
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    ),
    splashFactory: InkRipple.splashFactory,
  );
}
