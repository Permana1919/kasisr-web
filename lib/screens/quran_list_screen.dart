import 'package:flutter/material.dart';

import 'package:app_hafalan_quran/data/quran_data.dart';
import 'package:app_hafalan_quran/screens/quran_search_screen.dart';
import 'package:app_hafalan_quran/screens/surah_detail_screen.dart';
import 'package:app_hafalan_quran/services/quran_api.dart';
import 'package:app_hafalan_quran/theme/app_icons.dart';
import 'package:app_hafalan_quran/theme/app_theme.dart';
import 'package:app_hafalan_quran/widgets/surah_card.dart';

/// Isi tab Quran: banner dan daftar surah dari API equran.id.
///
/// Data contoh di [surahList] dipakai lebih dulu supaya halaman langsung
/// tampil, lalu diganti dengan 114 surah dari server saat berhasil dimuat.
class QuranListScreen extends StatefulWidget {
  const QuranListScreen({super.key});

  static const String _appName = 'Nama apk';

  @override
  State<QuranListScreen> createState() => _QuranListScreenState();
}

class _QuranListScreenState extends State<QuranListScreen> {
  static const int _pageSize = 4;

  final QuranApi _api = QuranApi();
  final ScrollController _scroll = ScrollController();

  List<Surah> _surahs = surahList;
  bool _loading = true;
  bool _usingFallback = false;
  int _page = 0;

  int get _pageCount {
    final count = (_surahs.length / _pageSize).ceil();
    return count < 1 ? 1 : count;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _api.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final surahs = await _api.fetchSurahs();
      if (!mounted) return;
      if (surahs.isEmpty) {
        throw const QuranApiException('Daftar surah kosong.');
      }
      setState(() {
        _surahs = surahs;
        _page = 0;
        _loading = false;
        _usingFallback = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _usingFallback = true;
      });
    }
  }

  void _goToPage(int page) {
    if (page < 0 || page >= _pageCount || page == _page) return;
    setState(() => _page = page);
    if (_scroll.hasClients) {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final start = _page * _pageSize;
    final items = _surahs.skip(start).take(_pageSize).toList(growable: false);

    return Column(
      children: [
        _TopBar(
          title: QuranListScreen._appName,
          onSearch: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => QuranSearchScreen(surahs: _surahs),
            ),
          ),
        ),
        if (_loading)
          const LinearProgressIndicator(
            minHeight: 2,
            color: AppColors.white,
            backgroundColor: Color(0x33FFFFFF),
          ),
        if (_usingFallback)
          _OfflineNotice(onRetry: _loading ? null : _load),
        Expanded(
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 342 / 162,
                  child: Image.asset(
                    AppIcons.quranBanner,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              for (final surah in items) ...[
                SurahCard(
                  surah: surah,
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamed(SurahDetailScreen.route, arguments: surah),
                ),
                const SizedBox(height: 46),
              ],
              _Pagination(
                page: _page + 1,
                pageCount: _pageCount,
                onPrevious: _page > 0 ? () => _goToPage(_page - 1) : null,
                onNext: _page < _pageCount - 1
                    ? () => _goToPage(_page + 1)
                    : null,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }
}

class _OfflineNotice extends StatelessWidget {
  const _OfflineNotice({required this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      child: Row(
        children: [
          const Icon(Icons.cloud_off, size: 14, color: AppColors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Gagal memuat dari server, menampilkan data contoh.',
              style: sansStyle(10, color: AppColors.white),
            ),
          ),
          GestureDetector(
            onTap: onRetry,
            behavior: HitTestBehavior.opaque,
            child: Text(
              'Coba lagi',
              style: sansStyle(
                10,
                weight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.onSearch});

  final String title;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
      child: Row(
        children: [
          Builder(
            builder: (context) => GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              behavior: HitTestBehavior.opaque,
              child: const Icon(
                Icons.menu,
                size: 26,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(title, style: serifStyle(24, color: AppColors.white)),
          const Spacer(),
          GestureDetector(
            onTap: onSearch,
            behavior: HitTestBehavior.opaque,
            child: const Icon(
              Icons.search,
              size: 24,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _Pagination extends StatelessWidget {
  const _Pagination({
    required this.page,
    required this.pageCount,
    required this.onPrevious,
    required this.onNext,
  });

  final int page;
  final int pageCount;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onPrevious,
          behavior: HitTestBehavior.opaque,
          child: Icon(
            Icons.chevron_left,
            size: 20,
            color: AppColors.white.withValues(alpha: onPrevious == null ? 0.4 : 1),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$page / $pageCount',
          style: sansStyle(12, color: AppColors.white),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onNext,
          behavior: HitTestBehavior.opaque,
          child: Icon(
            Icons.chevron_right,
            size: 20,
            color: AppColors.white.withValues(alpha: onNext == null ? 0.4 : 1),
          ),
        ),
      ],
    );
  }
}
