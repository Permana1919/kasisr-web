/// Data statis untuk tampilan Quran.
///
/// Aplikasi ini hanya menampilkan UI, jadi isinya masih contoh (hardcode).
class Surah {
  const Surah({
    required this.number,
    required this.name,
    required this.arabic,
    required this.meaning,
    this.ayahCount = 0,
    this.revelation = '',
    this.description = '',
    this.audioUrl,
  });

  final int number;
  final String name;
  final String arabic;
  final String meaning;

  /// Jumlah ayat (dari API). Data contoh tidak mengisinya.
  final int ayahCount;

  /// Tempat turun, misalnya "Mekah" atau "Madinah".
  final String revelation;

  /// Deskripsi singkat surah dari API.
  final String description;

  /// URL audio bacaan penuh satu surah.
  final String? audioUrl;
}

class Ayah {
  const Ayah({
    required this.number,
    required this.arabic,
    required this.latin,
    required this.translation,
    this.audioUrl,
  });

  final int number;
  final String arabic;
  final String latin;
  final String translation;

  /// URL audio bacaan ayat (dari API).
  final String? audioUrl;
}

const List<Surah> surahList = <Surah>[
  Surah(
    number: 1,
    name: 'Al - Fatihah',
    arabic: 'الفاتحة',
    meaning: 'Pembuka',
  ),
  Surah(
    number: 2,
    name: 'Al - Baqarah',
    arabic: 'البقرة',
    meaning: 'Sapi Betina',
  ),
  Surah(
    number: 3,
    name: 'Ali - Imran',
    arabic: 'آل عمران',
    meaning: 'Keluarga Imran',
  ),
  Surah(
    number: 4,
    name: 'An - Nisa',
    arabic: 'النساء',
    meaning: 'Wanita',
  ),
];

const List<Ayah> alFatihah = <Ayah>[
  Ayah(
    number: 1,
    arabic: 'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ',
    latin: 'Bismillāhir-raḥmānir-raḥīm',
    translation:
        'Dengan nama Allah Yang Maha Pengasih lagi Maha Penyayang.',
  ),
  Ayah(
    number: 2,
    arabic: 'اَلْحَمْدُ لِلّٰهِ رَبِّ الْعٰلَمِيْنَ',
    latin: 'Alḥamdulillāhi rabbil-‘ālamīn',
    translation: 'Segala puji bagi Allah, Tuhan semesta alam.',
  ),
  Ayah(
    number: 3,
    arabic: 'الرَّحْمٰنِ الرَّحِيْمِ',
    latin: 'Ar-raḥmānir-raḥīm',
    translation: 'Yang Maha Pengasih lagi Maha Penyayang.',
  ),
  Ayah(
    number: 4,
    arabic: 'مٰلِكِ يَوْمِ الدِّيْنِ',
    latin: 'Māliki yaumid-dīn',
    translation: 'Pemilik hari pembalasan.',
  ),
  Ayah(
    number: 5,
    arabic: 'اِيَّاكَ نَعْبُدُ وَاِيَّاكَ نَسْتَعِيْنُ',
    latin: 'Iyyāka na‘budu wa iyyāka nasta‘īn',
    translation:
        'Hanya kepada-Mu kami menyembah dan hanya kepada-Mu kami meminta pertolongan.',
  ),
  Ayah(
    number: 6,
    arabic: 'اِهْدِنَا الصِّرَاطَ الْمُسْتَقِيْمَ',
    latin: 'Ihdinaṣ-ṣirāṭal-mustaqīm',
    translation: 'Tunjukilah kami jalan yang lurus.',
  ),
  Ayah(
    number: 7,
    arabic:
        'صِرَاطَ الَّذِيْنَ اَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوْبِ عَلَيْهِمْ وَلَا الضَّآلِّيْنَ',
    latin:
        'Ṣirāṭal-lażīna an‘amta ‘alaihim gairil-magḍūbi ‘alaihim wa laḍ-ḍāllīn',
    translation:
        '(yaitu) jalan orang-orang yang telah Engkau beri nikmat, bukan (jalan) mereka yang dimurkai dan bukan (pula jalan) orang-orang yang sesat.',
  ),
];
