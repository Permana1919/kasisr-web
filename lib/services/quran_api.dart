import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:app_hafalan_quran/data/quran_data.dart';

/// Klien API Quran dari equran.id (v2).
///
/// Dokumentasi: https://equran.id/apidev/v2
/// Endpoint yang dipakai:
/// - `GET /surat`      -> daftar 114 surah
/// - `GET /surat/{n}`  -> detail surah + ayat + audio
class QuranApi {
  QuranApi({http.Client? client, this.baseUrl = 'https://equran.id/api/v2'})
    : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;

  static const Duration _timeout = Duration(seconds: 15);

  Future<List<Surah>> fetchSurahs() async {
    final json = await _get('/surat');
    final data = json['data'];
    if (data is! List) {
      throw const QuranApiException('Format daftar surah tidak dikenali.');
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(_surahFromJson)
        .toList(growable: false);
  }

  Future<SurahDetail> fetchSurah(int number) async {
    final json = await _get('/surat/$number');
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      throw const QuranApiException('Detail surah tidak ditemukan.');
    }

    final ayatJson = data['ayat'];
    final ayat = ayatJson is List
        ? ayatJson
              .whereType<Map<String, dynamic>>()
              .map(_ayahFromJson)
              .toList(growable: false)
        : const <Ayah>[];

    return SurahDetail(
      surah: _surahFromJson(data),
      ayat: ayat,
      next: _optionalSurah(data['suratSelanjutnya']),
      previous: _optionalSurah(data['suratSebelumnya']),
    );
  }

  /// `suratSelanjutnya`/`suratSebelumnya` bisa berisi objek surah atau `false`
  /// (pada surah pertama/terakhir).
  Surah? _optionalSurah(dynamic value) {
    if (value is Map<String, dynamic>) return _surahFromJson(value);
    return null;
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final response = await _client
        .get(Uri.parse('$baseUrl$path'))
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw QuranApiException(
        'Server mengembalikan status ${response.statusCode}.',
      );
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map<String, dynamic>) {
      throw const QuranApiException('Respons server tidak valid.');
    }
    return decoded;
  }

  Surah _surahFromJson(Map<String, dynamic> json) {
    return Surah(
      number: _int(json['nomor']),
      name: _string(json['namaLatin']),
      arabic: _string(json['nama']),
      meaning: _string(json['arti']),
      ayahCount: _int(json['jumlahAyat']),
      revelation: _string(json['tempatTurun']),
      description: _description(json['deskripsi']),
      audioUrl: _audioUrl(json['audioFull']),
    );
  }

  Ayah _ayahFromJson(Map<String, dynamic> json) {
    return Ayah(
      number: _int(json['nomorAyat']),
      arabic: _string(json['teksArab']),
      latin: _string(json['teksLatin']),
      translation: _string(json['teksIndonesia']),
      audioUrl: _audioUrl(json['audio']),
    );
  }

  /// Audio bisa berupa string langsung atau map qari -> URL.
  String? _audioUrl(dynamic value) {
    if (value is String && value.isNotEmpty) return value;
    if (value is Map) {
      for (final item in value.values) {
        if (item is String && item.isNotEmpty) return item;
      }
    }
    return null;
  }

  /// Deskripsi surah dari API masih mengandung HTML (`<i>`, `<br>`, dll),
  /// jadi dibersihkan dulu sebelum ditampilkan.
  static String _description(dynamic value) {
    final raw = _string(value);
    if (raw.isEmpty) return '';

    final text = raw
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");

    return text.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
  }

  static String _string(dynamic value) => value is String ? value : '';

  static int _int(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  void dispose() => _client.close();
}

/// Detail satu surah beserta ayat-ayatnya.
class SurahDetail {
  const SurahDetail({
    required this.surah,
    required this.ayat,
    this.next,
    this.previous,
  });

  final Surah surah;
  final List<Ayah> ayat;

  /// Surah berikutnya (null pada surah ke-114).
  final Surah? next;

  /// Surah sebelumnya (null pada surah ke-1).
  final Surah? previous;
}

class QuranApiException implements Exception {
  const QuranApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
