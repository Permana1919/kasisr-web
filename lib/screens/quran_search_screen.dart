import 'package:flutter/material.dart';

import 'package:app_hafalan_quran/data/quran_data.dart';
import 'package:app_hafalan_quran/screens/surah_detail_screen.dart';
import 'package:app_hafalan_quran/services/quran_api.dart';
import 'package:app_hafalan_quran/theme/app_theme.dart';
import 'package:app_hafalan_quran/widgets/mosque_background.dart';
import 'package:app_hafalan_quran/widgets/surah_card.dart';

/// Halaman pencarian surah.
///
/// Bisa dibuka dari ikon search di tab Quran maupun di halaman isi surah.
/// Pencarian mencocokkan nomor, nama, arti, dan teks Arab surah.
class QuranSearchScreen extends StatefulWidget {
  const QuranSearchScreen({super.key, this.surahs});

  /// Daftar surah yang sudah dimuat tab Quran. Bila `null`, daftar diambil
  /// sendiri dari API.
  final List<Surah>? surahs;

  @override
  State<QuranSearchScreen> createState() => _QuranSearchScreenState();
}

class _QuranSearchScreenState extends State<QuranSearchScreen> {
  final QuranApi _api = QuranApi();
  final TextEditingController _controller = TextEditingController();

  late List<Surah> _surahs = widget.surahs ?? surahList;
  late bool _loading = widget.surahs == null;
  bool _usingFallback = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    if (widget.surahs == null) _load();
  }

  @override
  void dispose() {
    _api.dispose();
    _controller.dispose();
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

  List<Surah> get _results {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _surahs;
    return _surahs
        .where((surah) {
          return '${surah.number}'.contains(query) ||
              surah.name.toLowerCase().contains(query) ||
              surah.meaning.toLowerCase().contains(query) ||
              surah.arabic.contains(query);
        })
        .toList(growable: false);
  }

  void _clear() {
    _controller.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;

    return Scaffold(
      backgroundColor: AppColors.homeBottom,
      body: MosqueBackground(
        child: SafeArea(
          child: Column(
            children: [
              _SearchBar(
                controller: _controller,
                query: _query,
                onChanged: (value) => setState(() => _query = value),
                onClear: _clear,
              ),
              if (_loading)
                const LinearProgressIndicator(
                  minHeight: 2,
                  color: AppColors.white,
                  backgroundColor: Color(0x33FFFFFF),
                ),
              if (_usingFallback)
                _FallbackNotice(onRetry: _loading ? null : _load),
              Expanded(
                child: results.isEmpty
                    ? _EmptyState(query: _query)
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                        itemCount: results.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final surah = results[index];
                          return SurahCard(
                            surah: surah,
                            onTap: () => Navigator.of(context).pushNamed(
                              SurahDetailScreen.route,
                              arguments: surah,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(
                Icons.chevron_left,
                size: 28,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 19, color: AppColors.teal),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      autofocus: true,
                      onChanged: onChanged,
                      textInputAction: TextInputAction.search,
                      style: sansStyle(13, color: AppColors.ink),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: 'Cari surah, arti, atau nomor',
                        hintStyle: sansStyle(12, color: AppColors.inkSoft),
                      ),
                    ),
                  ),
                  if (query.isNotEmpty)
                    GestureDetector(
                      onTap: onClear,
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(
                          Icons.close,
                          size: 17,
                          color: AppColors.inkSoft,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FallbackNotice extends StatelessWidget {
  const _FallbackNotice({required this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
      child: Row(
        children: [
          const Icon(Icons.cloud_off, size: 14, color: AppColors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Gagal memuat dari server, memakai data contoh.',
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: 36,
            color: AppColors.white.withValues(alpha: 0.85),
          ),
          const SizedBox(height: 10),
          Text(
            'Surah tidak ditemukan.',
            style: sansStyle(13, color: AppColors.white),
          ),
          const SizedBox(height: 4),
          Text(
            query.isEmpty ? 'Ketik nama surah.' : 'Coba kata kunci lain.',
            style: sansStyle(
              11,
              color: AppColors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
