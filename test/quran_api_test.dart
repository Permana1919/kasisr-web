import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:app_hafalan_quran/services/quran_api.dart';
import 'package:app_hafalan_quran/services/quran_audio.dart';

/// Membuat respons JSON UTF-8 seperti equran.id.
http.Response _jsonResponse(Object body, {int status = 200}) {
  return http.Response.bytes(
    utf8.encode(jsonEncode(body)),
    status,
    headers: const {'content-type': 'application/json; charset=utf-8'},
  );
}

void main() {
  group('QuranApi.fetchSurahs', () {
    test('membaca daftar surah dari API', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/api/v2/surat');
        return _jsonResponse({
          'code': 200,
          'message': 'Sukses',
          'data': [
            {
              'nomor': 1,
              'nama': 'الفاتحة',
              'namaLatin': 'Al-Fatihah',
              'jumlahAyat': 7,
              'tempatTurun': 'Mekah',
              'arti': 'Pembuka',
              'deskripsi': 'Surah pembuka Al-Quran.',
              'audioFull': {
                '01': 'https://cdn.equran.id/audio-full/001.mp3',
              },
            },
            {
              'nomor': 2,
              'nama': 'البقرة',
              'namaLatin': 'Al-Baqarah',
              'jumlahAyat': 286,
              'tempatTurun': 'Madinah',
              'arti': 'Sapi Betina',
              'deskripsi': 'Surah terpanjang.',
              'audioFull': {
                '01': 'https://cdn.equran.id/audio-full/002.mp3',
              },
            },
          ],
        });
      });

      final api = QuranApi(client: client);
      final surahs = await api.fetchSurahs();
      api.dispose();

      expect(surahs, hasLength(2));
      expect(surahs.first.number, 1);
      expect(surahs.first.name, 'Al-Fatihah');
      expect(surahs.first.arabic, 'الفاتحة');
      expect(surahs.first.meaning, 'Pembuka');
      expect(surahs.first.ayahCount, 7);
      expect(surahs.first.revelation, 'Mekah');
      expect(surahs.first.audioUrl, contains('001.mp3'));
    });

    test('melempar QuranApiException saat status bukan 200', () async {
      final client = MockClient((_) async => _jsonResponse({}, status: 500));
      final api = QuranApi(client: client);

      await expectLater(
        api.fetchSurahs(),
        throwsA(isA<QuranApiException>()),
      );
      api.dispose();
    });
  });

  group('QuranApi.fetchSurah', () {
    test('membaca detail surah beserta ayat dan audio', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/api/v2/surat/1');
        return _jsonResponse({
          'code': 200,
          'message': 'Sukses',
          'data': {
            'nomor': 1,
            'nama': 'الفاتحة',
            'namaLatin': 'Al-Fatihah',
            'jumlahAyat': 2,
            'tempatTurun': 'Mekah',
            'arti': 'Pembuka',
            'deskripsi': 'Surat <i>Al Faatihah</i><br>Pembukaan.&nbsp;',
            'audioFull': {
              '01': 'https://cdn.equran.id/audio-full/001.mp3',
            },
            'suratSebelumnya': false,
            'suratSelanjutnya': {
              'nomor': 2,
              'nama': 'البقرة',
              'namaLatin': 'Al-Baqarah',
              'jumlahAyat': 286,
            },
            'ayat': [
              {
                'nomorAyat': 1,
                'teksArab': 'بِسْمِ اللّٰهِ',
                'teksLatin': 'Bismillah',
                'teksIndonesia': 'Dengan nama Allah',
                'audio': {
                  '01': 'https://cdn.equran.id/audio-partial/001001.mp3',
                },
              },
              {
                'nomorAyat': 2,
                'teksArab': 'اَلْحَمْدُ لِلّٰهِ',
                'teksLatin': 'Alhamdulillah',
                'teksIndonesia': 'Segala puji bagi Allah',
                'audio': {
                  '01': 'https://cdn.equran.id/audio-partial/001002.mp3',
                },
              },
            ],
          },
        });
      });

      final api = QuranApi(client: client);
      final detail = await api.fetchSurah(1);
      api.dispose();

      expect(detail.surah.name, 'Al-Fatihah');
      expect(detail.surah.ayahCount, 2);
      expect(detail.surah.description, 'Surat Al Faatihah\nPembukaan.');
      expect(detail.previous, isNull);
      expect(detail.next?.number, 2);
      expect(detail.next?.name, 'Al-Baqarah');
      expect(detail.next?.ayahCount, 286);
      expect(detail.ayat, hasLength(2));
      expect(detail.ayat.first.number, 1);
      expect(detail.ayat.first.arabic, 'بِسْمِ اللّٰهِ');
      expect(detail.ayat.first.latin, 'Bismillah');
      expect(detail.ayat.first.translation, 'Dengan nama Allah');
      expect(detail.ayat.first.audioUrl, contains('001001.mp3'));
      expect(detail.ayat.last.number, 2);
    });

    test('menerima audio berupa string langsung', () async {
      final client = MockClient((_) async {
        return _jsonResponse({
          'code': 200,
          'data': {
            'nomor': 112,
            'nama': 'الإخلاص',
            'namaLatin': 'Al-Ikhlas',
            'jumlahAyat': 1,
            'tempatTurun': 'Mekah',
            'arti': 'Ikhlas',
            'deskripsi': '',
            'audioFull': 'https://cdn.equran.id/audio-full/112.mp3',
            'ayat': [
              {
                'nomorAyat': 1,
                'teksArab': 'قُلْ هُوَ اللّٰهُ اَحَدٌ',
                'teksLatin': 'Qul huwallahu ahad',
                'teksIndonesia': 'Katakanlah, Dialah Allah yang Maha Esa.',
                'audio': 'https://cdn.equran.id/audio-partial/112001.mp3',
              },
            ],
          },
        });
      });

      final api = QuranApi(client: client);
      final detail = await api.fetchSurah(112);
      api.dispose();

      expect(detail.surah.audioUrl, contains('112.mp3'));
      expect(detail.ayat.single.audioUrl, contains('112001.mp3'));
    });

    test('melempar QuranApiException saat data tidak ada', () async {
      final client = MockClient(
        (_) async => _jsonResponse({'code': 404, 'data': null}),
      );
      final api = QuranApi(client: client);

      await expectLater(
        api.fetchSurah(999),
        throwsA(isA<QuranApiException>()),
      );
      api.dispose();
    });
  });

  group('QuranAudio.ayahUrl', () {
    test('memakai penomoran 3 digit surah dan ayat', () {
      expect(
        QuranAudio.ayahUrl(1, 2),
        'https://everyayah.com/data/Alafasy_128kbps/001002.mp3',
      );
      expect(
        QuranAudio.ayahUrl(114, 6),
        'https://everyayah.com/data/Alafasy_128kbps/114006.mp3',
      );
      expect(
        QuranAudio.ayahUrl(2, 255),
        'https://everyayah.com/data/Alafasy_128kbps/002255.mp3',
      );
    });
  });
}
