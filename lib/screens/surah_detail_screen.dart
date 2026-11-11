import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'package:app_hafalan_quran/data/quran_data.dart';
import 'package:app_hafalan_quran/screens/mushaf_screen.dart';
import 'package:app_hafalan_quran/screens/quran_search_screen.dart';
import 'package:app_hafalan_quran/services/quran_api.dart';
import 'package:app_hafalan_quran/services/quran_audio.dart';
import 'package:app_hafalan_quran/theme/app_theme.dart';
import 'package:app_hafalan_quran/widgets/ayah_marker.dart';

/// Halaman isi surah: teks Arab, transliterasi, dan terjemahan dari API.
class SurahDetailScreen extends StatefulWidget {
  const SurahDetailScreen({super.key, this.surah});

  static const String route = '/surah';

  final Surah? surah;

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  final QuranApi _api = QuranApi();

  Surah? _surah;
  Surah? _next;
  Surah? _previous;
  List<Ayah> _ayat = const [];
  bool _initialized = false;
  bool _loading = true;
  bool _usingFallback = false;
  bool _descriptionExpanded = false;

  // Pemutar audio dibuat saat pertama kali dipakai agar widget test tidak
  // menyentuh plugin platform.
  AudioPlayer? _player;
  String? _sourceUrl;
  int _current = 0;
  bool _playing = false;
  bool _preparing = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  /// Waktu percobaan terakhir mengambil durasi audio. Di web, kejadian
  /// `duration` kadang baru tersedia setelah pemutaran berjalan, jadi durasi
  /// dicek ulang secara berkala selama masih nol.
  DateTime _lastDurationCheck = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    final surah = widget.surah ?? (args is Surah ? args : surahList.first);
    _surah = surah;
    _ayat = _fallbackAyahs(surah.number);
    _load(surah.number);
  }

  @override
  void dispose() {
    _api.dispose();
    _player?.dispose();
    super.dispose();
  }

  List<Ayah> _fallbackAyahs(int surahNumber) {
    return surahNumber == 1 ? alFatihah : const [];
  }

  Future<void> _load(int number) async {
    setState(() {
      _loading = true;
      _usingFallback = false;
    });

    try {
      final detail = await _api.fetchSurah(number);
      if (!mounted) return;
      setState(() {
        _surah = detail.surah;
        _next = detail.next;
        _previous = detail.previous;
        _ayat = detail.ayat;
        _loading = false;
        _current = 0;
        _usingFallback = false;
        _descriptionExpanded = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _usingFallback = true;
      });
    }
  }

  void _openSurah(Surah surah) {
    Navigator.of(context).pushReplacementNamed(
      SurahDetailScreen.route,
      arguments: surah,
    );
  }

  void _openSearch() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const QuranSearchScreen()),
    );
  }

  String? get _currentAudioUrl {
    final surah = _surah;
    if (surah == null || _ayat.isEmpty) return null;
    final index = _current.clamp(0, _ayat.length - 1);
    // `Ayah.audioUrl` dari equran.id tidak dipakai untuk pemutaran karena
    // CDN-nya tanpa header CORS (gagal di web). Lihat [QuranAudio].
    return QuranAudio.ayahUrl(surah.number, _ayat[index].number);
  }

  AudioPlayer _ensurePlayer() {
    final existing = _player;
    if (existing != null) return existing;

    final player = AudioPlayer();
    player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _playing = state == PlayerState.playing);
    });
    player.onPositionChanged.listen((position) {
      if (!mounted) return;
      setState(() => _position = position);
      if (_duration == Duration.zero) _refreshDuration(player);
    });
    player.onDurationChanged.listen((duration) {
      if (!mounted) return;
      if (duration > Duration.zero) setState(() => _duration = duration);
    });
    player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      if (_current < _ayat.length - 1) {
        _selectAyah(_current + 1, autoplay: true);
      } else {
        setState(() {
          _playing = false;
          _position = Duration.zero;
        });
      }
    });
    _player = player;
    return player;
  }

  /// Mengambil durasi audio dari pemutar. Di web, kejadian `duration` bisa
  /// datang sebelum pemutaran benar-benar siap (nilainya 0), jadi durasi
  /// dicoba ulang paling banyak sekali per detik selama masih nol.
  Future<void> _refreshDuration(AudioPlayer player) async {
    if (!mounted) return;
    final now = DateTime.now();
    if (now.difference(_lastDurationCheck) < const Duration(seconds: 1)) {
      return;
    }
    _lastDurationCheck = now;

    final duration = await player.getDuration();
    if (!mounted) return;
    if (duration != null && duration > Duration.zero) {
      setState(() => _duration = duration);
    }
  }

  Future<void> _togglePlay() async {
    final url = _currentAudioUrl;
    if (url == null) return;

    if (_playing) {
      await _player?.pause();
      return;
    }

    if (_player?.state == PlayerState.paused && _sourceUrl == url) {
      await _player?.resume();
      return;
    }

    await _playUrl(url);
  }

  Future<void> _playUrl(String url) async {
    if (!mounted) return;
    setState(() {
      _preparing = true;
      _position = Duration.zero;
      _duration = Duration.zero;
      _lastDurationCheck = DateTime.fromMillisecondsSinceEpoch(0);
    });

    try {
      final player = _ensurePlayer();
      await player.stop();
      await player.play(UrlSource(url));
      _sourceUrl = url;
      // Jangan set durasi ke nol setelah play: kejadian `duration` bisa saja
      // sudah masuk lebih dulu.
      await _refreshDuration(player);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio tidak dapat diputar.')),
      );
    } finally {
      if (mounted) setState(() => _preparing = false);
    }
  }

  void _selectAyah(int index, {bool autoplay = false}) {
    if (_ayat.isEmpty) return;
    final next = index.clamp(0, _ayat.length - 1);
    setState(() {
      _current = next;
      _position = Duration.zero;
      _duration = Duration.zero;
    });

    if (!autoplay) return;
    final url = _currentAudioUrl;
    if (url != null) _playUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final surah = _surah!;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              surah: surah,
              onSearch: _openSearch,
              onPrevious: _previous == null
                  ? null
                  : () => _openSurah(_previous!),
              onNext: _next == null ? null : () => _openSurah(_next!),
            ),
            if (_loading)
              const LinearProgressIndicator(
                minHeight: 2,
                color: AppColors.teal,
                backgroundColor: Color(0x22FFFFFF),
              ),
            if (_usingFallback)
              _FallbackNotice(onRetry: _loading ? null : () => _load(surah.number)),
            Expanded(child: _buildContent(surah)),
            _AudioBar(
              playing: _playing,
              preparing: _preparing,
              position: _position,
              duration: _duration,
              label: _ayat.isEmpty
                  ? 'Belum ada audio'
                  : 'Ayat ${_current + 1} / ${_ayat.length}',
              canPlay: _currentAudioUrl != null,
              onPlayPause: _currentAudioUrl == null ? null : _togglePlay,
              onPrevious: _ayat.isEmpty || _current == 0
                  ? null
                  : () => _selectAyah(_current - 1, autoplay: true),
              onNext: _ayat.isEmpty || _current >= _ayat.length - 1
                  ? null
                  : () => _selectAyah(_current + 1, autoplay: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Surah surah) {
    if (_ayat.isEmpty) {
      return Center(
        child: _loading
            ? const CircularProgressIndicator(color: AppColors.teal)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Gagal memuat surah ini.',
                    style: sansStyle(13, color: AppColors.inkSoft),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => _load(surah.number),
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
      );
    }

    // Surah panjang (mis. Al-Baqarah 286 ayat) tetap ringan karena daftar
    // dibangun per item, bukan sekaligus.
    return ListView.builder(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      itemCount: _ayat.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return _buildIntro(surah);
        final i = index - 1;
        return _AyahTile(
          ayah: _ayat[i],
          first: i == 0,
          active: i == _current,
          onTap: () => _selectAyah(i),
        );
      },
    );
  }

  Widget _buildIntro(Surah surah) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _SurahBadge(arabic: surah.arabic),
        ),
        if (surah.description.isNotEmpty) ...[
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  surah.description,
                  maxLines: _descriptionExpanded ? null : 3,
                  overflow: _descriptionExpanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                  style: sansStyle(10.5, color: AppColors.inkSoft, height: 1.4),
                ),
                // Deskripsi panjang diringkas 3 baris; tombol ini membuka
                // atau menutup sisanya.
                if (surah.description.length > 140) ...[
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => setState(
                      () => _descriptionExpanded = !_descriptionExpanded,
                    ),
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _descriptionExpanded
                              ? 'Sembunyikan'
                              : 'Baca selengkapnya',
                          style: sansStyle(
                            10,
                            weight: FontWeight.w600,
                            color: AppColors.teal,
                          ),
                        ),
                        Icon(
                          _descriptionExpanded
                              ? Icons.expand_less
                              : Icons.expand_more,
                          size: 15,
                          color: AppColors.teal,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 18),
      ],
    );
  }
}

class _FallbackNotice extends StatelessWidget {
  const _FallbackNotice({required this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Row(
        children: [
          const Icon(Icons.cloud_off, size: 13, color: AppColors.inkSoft),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Gagal memuat data terbaru.',
              style: sansStyle(10, color: AppColors.inkSoft),
            ),
          ),
          GestureDetector(
            onTap: onRetry,
            behavior: HitTestBehavior.opaque,
            child: Text(
              'Coba lagi',
              style: sansStyle(10, weight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.surah,
    required this.onSearch,
    this.onPrevious,
    this.onNext,
  });

  final Surah surah;
  final VoidCallback onSearch;

  /// `null` saat surah pertama (tidak ada surah sebelumnya).
  final VoidCallback? onPrevious;

  /// `null` saat surah terakhir (tidak ada surah berikutnya).
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 6, 18, 2),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.chevron_left, size: 28),
                ),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${surah.number}. ${surah.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: sansStyle(13, weight: FontWeight.w700),
                    ),
                    if (surah.meaning.isNotEmpty)
                      Text(
                        '${surah.number}. ${surah.meaning}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: sansStyle(10, color: AppColors.inkSoft),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onSearch,
                behavior: HitTestBehavior.opaque,
                child: const Icon(Icons.search, size: 23),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () =>
                    Navigator.of(context).pushNamed(MushafScreen.route),
                behavior: HitTestBehavior.opaque,
                child: const Icon(Icons.settings_outlined, size: 22),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 14, 6),
          child: Row(
            children: [
              if (onPrevious != null)
                GestureDetector(
                  onTap: onPrevious,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.chevron_left, size: 18),
                      Text(
                        'Sebelumnya',
                        style: sansStyle(11, weight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              if (onNext != null)
                GestureDetector(
                  onTap: onNext,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Selanjutnya',
                        style: sansStyle(11, weight: FontWeight.w600),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.chevron_right, size: 18),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Container(height: 1, color: AppColors.ink.withValues(alpha: 0.55)),
      ],
    );
  }
}

class _SurahBadge extends StatelessWidget {
  const _SurahBadge({required this.arabic});

  final String arabic;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.teal,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        arabic,
        textDirection: TextDirection.rtl,
        style: arabicStyle(28, color: AppColors.white, height: 1.6),
      ),
    );
  }
}

class _AyahTile extends StatelessWidget {
  const _AyahTile({
    required this.ayah,
    required this.first,
    required this.active,
    required this.onTap,
  });

  final Ayah ayah;
  final bool first;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ColoredBox(
        color: active ? AppColors.teal.withValues(alpha: 0.06) : Colors.transparent,
        child: Column(
          children: [
            if (!first)
              Container(
                height: 1,
                color: AppColors.ink.withValues(alpha: 0.55),
                margin: const EdgeInsets.only(top: 4),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AyahMarker(number: ayah.number),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          ayah.arabic,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: arabicStyle(30, height: 1.9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      ayah.latin,
                      textAlign: TextAlign.right,
                      style: sansStyle(11, color: AppColors.latin, height: 1.3),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ayah.translation,
                    style: sansStyle(12.5, height: 1.35),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AudioBar extends StatelessWidget {
  const _AudioBar({
    required this.playing,
    required this.preparing,
    required this.position,
    required this.duration,
    required this.label,
    required this.canPlay,
    required this.onPlayPause,
    required this.onPrevious,
    required this.onNext,
  });

  final bool playing;
  final bool preparing;
  final Duration position;
  final Duration duration;
  final String label;
  final bool canPlay;
  final VoidCallback? onPlayPause;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final progress = duration.inMilliseconds > 0
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.tealDark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: onPlayPause,
                      behavior: HitTestBehavior.opaque,
                      child: SizedBox(
                        width: 26,
                        height: 26,
                        child: preparing
                            ? const Padding(
                                padding: EdgeInsets.all(5),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                            : Icon(
                                playing
                                    ? Icons.pause_circle_outline
                                    : Icons.play_circle_outline,
                                size: 26,
                                color: AppColors.white.withValues(
                                  alpha: canPlay ? 1 : 0.4,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: sansStyle(
                          10.5,
                          color: AppColors.white.withValues(
                            alpha: canPlay ? 1 : 0.5,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onPrevious,
                      behavior: HitTestBehavior.opaque,
                      child: Icon(
                        Icons.skip_previous,
                        size: 20,
                        color: AppColors.white.withValues(
                          alpha: onPrevious == null ? 0.35 : 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    GestureDetector(
                      onTap: onNext,
                      behavior: HitTestBehavior.opaque,
                      child: Icon(
                        Icons.skip_next,
                        size: 20,
                        color: AppColors.white.withValues(
                          alpha: onNext == null ? 0.35 : 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 2,
                color: AppColors.mint,
                backgroundColor: AppColors.white.withValues(alpha: 0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
