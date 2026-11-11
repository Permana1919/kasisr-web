import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_hafalan_quran/main.dart';
import 'package:app_hafalan_quran/screens/menghafal_screen.dart';

void main() {
  testWidgets('Halaman Login tampil', (WidgetTester tester) async {
    await tester.pumpWidget(const SalamApp());

    expect(find.text('As salamualaikum'), findsOneWidget);
    expect(find.text('Login'), findsWidgets);
    expect(find.text('Belum punya akun? '), findsOneWidget);
  });

  testWidgets('Navigasi Login -> Daftar -> Home berjalan', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    tester.view.padding = const FakeViewPadding(top: 141, bottom: 102);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const SalamApp());

    final daftarLink = find.text('Daftar').last;
    await tester.ensureVisible(daftarLink);
    await tester.pumpAndSettle();
    await tester.tap(daftarLink);
    await tester.pumpAndSettle();
    expect(find.text('Konfirmasi password'), findsOneWidget);

    await tester.tap(find.text('Kembali'));
    await tester.pumpAndSettle();

    final loginButton = find.widgetWithText(ElevatedButton, 'Login');
    await tester.ensureVisible(loginButton);
    await tester.pumpAndSettle();
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.text('Activity'), findsOneWidget);
    expect(find.text('Streak Mingguan'), findsOneWidget);
  });

  testWidgets('Home tetap bisa dibuka di layar pendek', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3;
    tester.view.padding = const FakeViewPadding(top: 72, bottom: 48);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const SalamApp());

    final loginButton = find.widgetWithText(ElevatedButton, 'Login');
    await tester.ensureVisible(loginButton);
    await tester.pumpAndSettle();
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.text('Activity'), findsOneWidget);
    expect(find.text('Hari'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Quran -> daftar surah -> detail -> mushaf', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    tester.view.padding = const FakeViewPadding(top: 141, bottom: 102);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const SalamApp());

    final loginButton = find.widgetWithText(ElevatedButton, 'Login');
    await tester.ensureVisible(loginButton);
    await tester.pumpAndSettle();
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Quran'));
    await tester.pumpAndSettle();
    expect(find.text('Nama apk'), findsOneWidget);
    expect(find.text('Al - Baqarah'), findsOneWidget);

    await tester.tap(find.text('Al - Fatihah'));
    await tester.pumpAndSettle();
    expect(find.text('1. Pembuka'), findsOneWidget);
    expect(find.textContaining('Dengan nama Allah'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Round : 1 of 4'), findsOneWidget);
  });

  testWidgets('Quran memakai data contoh saat server tidak bisa diakses', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    tester.view.padding = const FakeViewPadding(top: 141, bottom: 102);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const SalamApp());

    final loginButton = find.widgetWithText(ElevatedButton, 'Login');
    await tester.ensureVisible(loginButton);
    await tester.pumpAndSettle();
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Quran'));
    await tester.pumpAndSettle();

    // Di widget test, HTTP diblokir sehingga API gagal dan data contoh dipakai.
    expect(
      find.text('Gagal memuat dari server, menampilkan data contoh.'),
      findsOneWidget,
    );
    expect(find.text('Coba lagi'), findsOneWidget);
    expect(find.text('Al - Baqarah'), findsOneWidget);
  });

  testWidgets('Pencarian surah menyaring daftar', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    tester.view.padding = const FakeViewPadding(top: 141, bottom: 102);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const SalamApp());

    final loginButton = find.widgetWithText(ElevatedButton, 'Login');
    await tester.ensureVisible(loginButton);
    await tester.pumpAndSettle();
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Quran'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Al - Fatihah'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'baqarah');
    await tester.pumpAndSettle();

    expect(find.text('Al - Baqarah'), findsOneWidget);
    expect(find.text('Al - Fatihah'), findsNothing);

    // Hasil pencarian membuka halaman isi surah.
    await tester.tap(find.text('Al - Baqarah'));
    await tester.pumpAndSettle();
    expect(find.text('2. Al - Baqarah'), findsOneWidget);
  });

  testWidgets('Menghafal: ayat muncul bertahap saat tombol rekam ditekan', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    tester.view.padding = const FakeViewPadding(top: 141, bottom: 102);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: MenghafalScreen())),
    );

    const ayah = 'اَلْحَمْدُ لِلّٰهِ رَبِّ الْعٰلَمِيْنَ';
    expect(find.text('Round : 1 of 4'), findsOneWidget);
    expect(find.text('1. Al - Fatihah'), findsOneWidget);
    expect(find.text(ayah), findsOneWidget);

    // Terjemahan masih disamarkan.
    expect(
      find.text('Segala puji bagi Allah, Tuhan semesta alam.'),
      findsNothing,
    );
    await tester.tap(find.byIcon(Icons.visibility_off_outlined).first);
    await tester.pumpAndSettle();
    expect(
      find.text('Segala puji bagi Allah, Tuhan semesta alam.'),
      findsOneWidget,
    );

    // Mulai "melafalkan": ayat utuh diganti teks bertahap.
    await tester.tap(find.byIcon(Icons.mic));
    await tester.pump();
    expect(find.byIcon(Icons.stop), findsOneWidget);
    expect(find.text(ayah), findsNothing);

    // Empat kata selesai, lalu otomatis lanjut ke round berikutnya.
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Round : 2 of 4'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.stop));
    await tester.pump();
    expect(find.byIcon(Icons.mic), findsOneWidget);
  });
}
