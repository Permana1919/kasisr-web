/// URL audio bacaan per ayat.
///
/// Data surah/ayat tetap diambil dari equran.id, tetapi file audionya diputar
/// dari everyayah.com karena:
///
/// - CDN equran.id (`cdn.equran.id`) tidak mengirim header CORS, sedangkan
///   `audioplayers_web` memakai `crossOrigin = "anonymous"`, sehingga audio
///   gagal diputar di web.
/// - everyayah.com mengirim `Access-Control-Allow-Origin: *` dan memakai
///   penomoran file yang sama: 3 digit nomor surah + 3 digit nomor ayat
///   (contoh: surah 1 ayat 2 -> `001002.mp3`).
class QuranAudio {
  const QuranAudio._();

  static const String _base = 'https://everyayah.com/data/Alafasy_128kbps';

  /// URL audio ayat ke-[ayah] dari surah ke-[surah].
  static String ayahUrl(int surah, int ayah) {
    final surahPart = surah.toString().padLeft(3, '0');
    final ayahPart = ayah.toString().padLeft(3, '0');
    return '$_base/$surahPart$ayahPart.mp3';
  }
}
