import 'dart:async';

import 'package:flutter/material.dart';

import 'package:app_hafalan_quran/data/quran_data.dart';
import 'package:app_hafalan_quran/theme/app_theme.dart';
import 'package:app_hafalan_quran/widgets/ayah_marker.dart';

/// Halaman/tab Menghafal.
///
/// Tampilan mengikuti prototipe: satu kartu putih berisi ayat, terjemahan
/// yang disamarkan, indikator round, dan kontrol di bawah.
///
/// Fitur hafalan meniru video referensi: saat tombol rekam ditekan, kata
/// pada ayat muncul satu per satu (seolah sedang dilafalkan). Rekaman suara
/// asli belum terhubung karena aplikasi masih UI-only.
class MenghafalScreen extends StatefulWidget {
  const MenghafalScreen({super.key, this.embedded = true});

  /// `true` saat dipakai sebagai tab di [HomeShell] (menu membuka drawer).
  /// `false` saat dibuka lewat rute `/mushaf` (menu kembali ke halaman
  /// sebelumnya).
  final bool embedded;

  static const String _appName = 'Nama apk';
  static const int _roundCount = 4;

  @override
  State<MenghafalScreen> createState() => _MenghafalScreenState();
}

class _MenghafalScreenState extends State<MenghafalScreen> {
  /// Empat round memakai ayat 2-5 Al-Fatihah.
  static final List<Ayah> _ayahs = alFatihah.sublist(1, 5);

  static const Duration _wordDuration = Duration(milliseconds: 550);

  int _round = 0;
  int _revealed = 0;
  bool _recording = false;
  bool _showTranslation = false;

  /// Round yang sudah selesai dilafalkan.
  final Set<int> _completed = <int>{};

  /// Jeda satu tick sebelum pindah ke round berikutnya.
  int _pause = 0;

  Timer? _timer;

  Ayah get _ayah => _ayahs[_round];
  List<String> get _words => _ayah.arabic.split(' ');

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleRecording() {
    if (_recording) {
      _stopRecording();
      return;
    }

    // Kalau round sudah selesai, mulai lagi dari awal.
    if (_revealed >= _words.length) {
      setState(() {
        _revealed = 0;
        _completed.remove(_round);
      });
    }

    setState(() {
      _recording = true;
      _pause = 0;
      if (_revealed == 0) _revealed = 1;
    });

    _timer?.cancel();
    _timer = Timer.periodic(_wordDuration, _onTick);
  }

  void _stopRecording() {
    _timer?.cancel();
    setState(() {
      _recording = false;
      _pause = 0;
    });
  }

  void _onTick(Timer timer) {
    if (!mounted) return;

    if (_revealed < _words.length) {
      setState(() => _revealed++);
      if (_revealed >= _words.length) {
        setState(() => _completed.add(_round));
        if (_round >= MenghafalScreen._roundCount - 1) {
          timer.cancel();
          setState(() => _recording = false);
        } else {
          // Beri jeda sebentar, lalu lanjut ke round berikutnya.
          _pause = 1;
        }
      }
      return;
    }

    // Semua kata sudah muncul: tunggu satu tick lalu ganti round.
    if (_pause > 0) {
      _pause--;
      if (_pause == 0 && _round < MenghafalScreen._roundCount - 1) {
        setState(() {
          _round++;
          _revealed = 1;
        });
      }
    }
  }

  void _previousRound() {
    if (_round == 0) return;
    _timer?.cancel();
    setState(() {
      _round--;
      _revealed = 0;
      _recording = false;
      _pause = 0;
      _completed.remove(_round);
    });
  }

  /// Mundur satu kata (seperti tombol mundur 5 detik di video).
  void _rewindWord() {
    if (_revealed == 0) return;
    setState(() {
      _revealed--;
      _pause = 0;
      _completed.remove(_round);
    });
  }

  void _toggleTranslation() {
    setState(() => _showTranslation = !_showTranslation);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTopBar(context),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: _buildCard(),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Round : ${_round + 1} of ${MenghafalScreen._roundCount}',
              style: sansStyle(10, color: AppColors.white),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _RoundProgress(
            count: MenghafalScreen._roundCount,
            completed: _completed,
          ),
        ),
        const SizedBox(height: 16),
        _buildControls(),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (widget.embedded) {
                Scaffold.of(context).openDrawer();
              } else {
                Navigator.of(context).maybePop();
              }
            },
            behavior: HitTestBehavior.opaque,
            child: const Icon(
              Icons.menu,
              size: 26,
              color: AppColors.white,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            MenghafalScreen._appName,
            style: serifStyle(24, color: AppColors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AyahMarker(number: _ayah.number),
              const SizedBox(width: 10),
              Flexible(child: _buildAyahText()),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: _showTranslation
                  ? _buildTranslation()
                  : _buildRedactedTranslation(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '1. Al - Fatihah',
                style: serifStyle(
                  13,
                  weight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _toggleTranslation,
                behavior: HitTestBehavior.opaque,
                child: Icon(
                  _showTranslation
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAyahText() {
    // Saat diam, ayat tampil utuh seperti prototipe.
    if (_revealed == 0) {
      return Text(
        _ayah.arabic,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        style: arabicStyle(24, height: 1.9),
      );
    }

    final words = _words;
    return Text.rich(
      TextSpan(
        children: [
          for (var i = 0; i < words.length; i++)
            TextSpan(
              text: '${words[i]} ',
              style: arabicStyle(24, height: 1.9).copyWith(
                color: i < _revealed
                    ? AppColors.tealDark
                    : const Color(0x00000000),
                backgroundColor: i == _revealed - 1
                    ? AppColors.mint
                    : null,
                fontWeight: i < _revealed
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
        ],
      ),
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
    );
  }

  Widget _buildRedactedTranslation() {
    return LayoutBuilder(
      key: const ValueKey('redacted'),
      builder: (context, constraints) {
        const gap = 16.0;
        final barHeight = ((constraints.maxHeight - gap * 3) / 4).clamp(
          10.0,
          42.0,
        );
        return Column(
          children: [
            for (var i = 0; i < 4; i++) ...[
              if (i > 0) const SizedBox(height: gap),
              Container(
                width: double.infinity,
                height: barHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFFB7AFA9),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ],
            const Spacer(),
          ],
        );
      },
    );
  }

  Widget _buildTranslation() {
    return Center(
      key: const ValueKey('translation'),
      child: SingleChildScrollView(
        child: Text(
          _ayah.translation,
          textAlign: TextAlign.center,
          style: sansStyle(13, height: 1.7, color: AppColors.inkSoft),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Row(
        children: [
          _CircleButton(
            icon: Icons.skip_previous,
            size: 34,
            iconSize: 18,
            onTap: _previousRound,
            opacity: _round == 0 ? 0.5 : 1,
            semanticLabel: 'Round sebelumnya',
          ),
          const SizedBox(width: 26),
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.grey,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _toggleTranslation,
                  behavior: HitTestBehavior.opaque,
                  child: Icon(
                    _showTranslation
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 15,
                  ),
                ),
                const SizedBox(width: 14),
                GestureDetector(
                  onTap: _rewindWord,
                  behavior: HitTestBehavior.opaque,
                  child: const Icon(Icons.chevron_left, size: 17),
                ),
              ],
            ),
          ),
          const Spacer(),
          _CircleButton(
            icon: _recording ? Icons.stop : Icons.mic,
            size: 44,
            iconSize: 19,
            iconColor: AppColors.tealDark,
            onTap: _toggleRecording,
            semanticLabel: _recording ? 'Berhenti menghafal' : 'Mulai menghafal',
          ),
        ],
      ),
    );
  }
}

class _RoundProgress extends StatelessWidget {
  const _RoundProgress({required this.count, required this.completed});

  final int count;
  final Set<int> completed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(width: 14),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              height: 5,
              decoration: BoxDecoration(
                color: completed.contains(i)
                    ? AppColors.white
                    : AppColors.white.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.size,
    required this.iconSize,
    this.iconColor = AppColors.ink,
    this.onTap,
    this.opacity = 1,
    this.semanticLabel,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final Color iconColor;
  final VoidCallback? onTap;
  final double opacity;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Semantics(
        button: true,
        label: semanticLabel,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: iconSize, color: iconColor),
          ),
        ),
      ),
    );
  }
}
