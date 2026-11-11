/// Daftar path ikon PNG di `assets/images/`.
///
/// Semua ikon berwarna hitam dengan latar transparan, kecuali `campfire`
/// (berwarna) dan `googleButton` (gambar tombol lengkap).
class AppIcons {
  const AppIcons._();

  // Ikon navigasi bawah.
  static const String home = 'assets/images/icon-home.png';
  static const String menghafal = 'assets/images/icon-menghafal.png';
  static const String pengaturan = 'assets/images/icon-pengaturan.png';

  // Ikon menu Fitur.
  static const String jadwalSalat = 'assets/images/icon-jadwa-shalat.png';
  static const String doa = 'assets/images/icon-doa.png';
  static const String quran = 'assets/images/icon-quran.png';

  // Lain-lain.
  static const String campfire = 'assets/images/campfire.png';
  static const String campfireBw = 'assets/images/campfire_bw.png';

  /// Tombol Google. File ini adalah hasil potong dari
  /// `icon-sign in with google.png` (dibuang margin kosongnya).
  static const String googleButton = 'assets/images/icon-google.png';

  /// Banner halaman daftar surah.
  static const String quranBanner = 'assets/images/banner-quran.png';

  /// Foto masjid untuk latar halaman.
  static const String masjidBackground = 'assets/images/bg-masjid.png';
}
