import 'package:flutter/material.dart';

import 'package:app_hafalan_quran/theme/app_theme.dart';

/// Kolom input bergaya pill dengan border tipis dan ikon di kiri.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.hint,
    this.controller,
    this.icon,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
  });

  final String hint;
  final TextEditingController? controller;
  final IconData? icon;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.ink, width: 1),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 17, color: AppColors.ink),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              style: serifStyle(13.5, color: AppColors.ink),
              cursorColor: AppColors.teal,
              cursorWidth: 1.4,
              decoration: InputDecoration.collapsed(
                hintText: hint,
                hintStyle: serifStyle(13.5, color: AppColors.ink),
              ),
            ),
          ),
          ?suffix,
        ],
      ),
    );
  }
}

/// Input password dengan tombol mata untuk menampilkan/menyembunyikan teks.
class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    super.key,
    required this.hint,
    this.controller,
    this.icon,
    this.textInputAction,
  });

  final String hint;
  final TextEditingController? controller;
  final IconData? icon;
  final TextInputAction? textInputAction;

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      hint: widget.hint,
      controller: widget.controller,
      icon: widget.icon,
      obscureText: _hidden,
      textInputAction: widget.textInputAction,
      suffix: GestureDetector(
        onTap: () => setState(() => _hidden = !_hidden),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Icon(
            _hidden
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 19,
            color: AppColors.ink,
          ),
        ),
      ),
    );
  }
}
