import 'package:flutter/material.dart';

import 'package:app_hafalan_quran/data/quran_data.dart';
import 'package:app_hafalan_quran/theme/app_theme.dart';

/// Kartu satu surah pada daftar Quran dan hasil pencarian.
class SurahCard extends StatelessWidget {
  const SurahCard({super.key, required this.surah, required this.onTap});

  final Surah surah;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.grey,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                '${surah.number}',
                style: serifStyle(
                  34,
                  weight: FontWeight.w400,
                  color: AppColors.teal,
                  height: 1,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surah.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: serifStyle(
                        17,
                        weight: FontWeight.w400,
                        color: AppColors.teal,
                      ),
                    ),
                    Text(
                      surah.meaning,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: sansStyle(9, color: AppColors.teal),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      surah.arabic,
                      textDirection: TextDirection.rtl,
                      style: arabicStyle(
                        22,
                        height: 1.3,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
