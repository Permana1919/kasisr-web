import 'package:flutter/material.dart';

import 'package:app_hafalan_quran/theme/app_theme.dart';

/// Kotak fitur pada bagian "Fitur" di Home.
class FeatureTile extends StatelessWidget {
  const FeatureTile({
    super.key,
    required this.label,
    this.icon,
    this.filled = false,
    this.onTap,
  });

  final String label;
  final Widget? icon;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: filled ? AppColors.mint : AppColors.tile,
        borderRadius: BorderRadius.circular(14),
      ),
      child: icon == null
          ? null
          : Center(
              child: IconTheme(
                data: const IconThemeData(color: AppColors.ink, size: 27),
                child: icon!,
              ),
            ),
    );

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        box,
        const SizedBox(height: 7),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: sansStyle(10, color: AppColors.white),
        ),
      ],
    );

    return SizedBox(
      width: 64,
      child: onTap == null
          ? content
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(14),
                child: content,
              ),
            ),
    );
  }
}
