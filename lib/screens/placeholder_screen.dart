import 'package:flutter/material.dart';

/// Tab yang belum punya isi. Latar masjid dari HomeShell tetap terlihat.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconAsset,
  });

  final String title;
  final String subtitle;
  final String iconAsset;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand();
  }
}
