import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:app_hafalan_quran/theme/app_theme.dart';
import 'package:app_hafalan_quran/widgets/app_icon.dart';

class AppNavItem {
  const AppNavItem({required this.asset, this.size = 27});

  final String asset;

  /// Ukuran ikon abu-abu di dalam bar.
  final double size;
}

/// Bottom navigation putih dengan lekukan lebar dan ikon terpilih
/// berupa lingkaran putih berisi ikon hijau.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.items,
    required this.index,
    required this.onChanged,
    this.bottomPadding = 0,
  });

  final List<AppNavItem> items;
  final int index;
  final ValueChanged<int> onChanged;

  /// Ruang aman di bawah layar (gesture bar). Bar putih diperpanjang
  /// sampai tepi bawah, tetapi ikon tetap berada di area atasnya.
  final double bottomPadding;

  /// Jarak dari tepi atas widget ke tepi atas bar putih.
  static const double barTop = 24;
  static const double barHeight = 120;
  static const double totalHeight = barTop + barHeight;
  static const double _circleRadius = 25;

  /// Titik tengah lingkaran aktif, diukur dari tepi atas bar.
  static const double _circleCenterBelowBarTop = 14;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: barTop + barHeight + bottomPadding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final slot = constraints.maxWidth / items.length;
          final centerX = slot * (index + 0.5);

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: barTop,
                left: 0,
                right: 0,
                height: barHeight + bottomPadding,
                child: ClipPath(
                  clipper: _NavBarClipper(notchCenterX: centerX),
                  child: const ColoredBox(color: AppColors.white),
                ),
              ),
              Positioned(
                top: barTop,
                left: 0,
                right: 0,
                height: barHeight,
                child: Row(
                  children: [
                    for (var i = 0; i < items.length; i++)
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onChanged(i),
                          child: Align(
                            alignment: Alignment(0, 0.3),
                            child: AppIcon(
                              items[i].asset,
                              size: items[i].size,
                              color: AppColors.navIcon,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Lingkaran putih dengan ikon hijau di atas bar.
              Positioned(
                top:
                    barTop +
                    _circleCenterBelowBarTop -
                    _circleRadius,
                left: centerX - _circleRadius,
                width: _circleRadius * 2,
                height: _circleRadius * 2,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: AppIcon(
                      items[index].asset,
                      size: items[index].size * 1.28,
                      color: AppColors.navActive,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Membuat bar putih dengan lekukan halus (valley) di sekitar tab aktif.
///
/// Lekukan memakai kurva kosinus sehingga tepinya menyatu mulus dan
/// dasarnya agak datar, sama seperti prototipe.
class _NavBarClipper extends CustomClipper<Path> {
  const _NavBarClipper({required this.notchCenterX});

  final double notchCenterX;

  static const double _notchHalfWidth = 70;
  static const double _notchDepth = 48;
  static const double _cornerRadius = 26;

  double _topEdgeY(double x) {
    final left = notchCenterX - _notchHalfWidth;
    final right = notchCenterX + _notchHalfWidth;
    if (x <= left || x >= right) return 0;

    final u = (x - left) / (right - left);
    return _notchDepth * 0.5 * (1 - math.cos(2 * math.pi * u));
  }

  @override
  Path getClip(Size size) {
    const r = _cornerRadius;
    final width = size.width;
    final height = size.height;
    final leftMerged = _topEdgeY(0) > 0.01;
    final rightMerged = _topEdgeY(width) > 0.01;

    final path = Path()..moveTo(0, height);

    double startX;
    if (leftMerged) {
      path.lineTo(0, _topEdgeY(0));
      startX = 0;
    } else {
      path.lineTo(0, r);
      path.quadraticBezierTo(0, 0, r, 0);
      startX = r;
    }

    final endX = rightMerged ? width : width - r;
    const step = 2.0;
    for (var x = startX + step; x < endX; x += step) {
      path.lineTo(x, _topEdgeY(x));
    }

    if (rightMerged) {
      path.lineTo(width, _topEdgeY(width));
    } else {
      path.lineTo(width - r, 0);
      path.quadraticBezierTo(width, 0, width, r);
    }

    path.lineTo(width, height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_NavBarClipper oldClipper) {
    return oldClipper.notchCenterX != notchCenterX;
  }
}
