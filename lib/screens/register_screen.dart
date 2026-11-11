import 'package:flutter/material.dart';

import 'package:app_hafalan_quran/screens/home_screen.dart';
import 'package:app_hafalan_quran/theme/app_theme.dart';
import 'package:app_hafalan_quran/widgets/app_text_field.dart';
import 'package:app_hafalan_quran/widgets/mosque_background.dart';
import 'package:app_hafalan_quran/widgets/primary_button.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  static const String route = '/daftar';

  void _openHome(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(HomeShell.route, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkGreen,
      body: MosqueBackground(
        gradient: AppColors.loginGradient,
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 120),
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    'Kembali',
                    style: sansStyle(
                      12.5,
                      weight: FontWeight.w500,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.sheet,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(44),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    left: false,
                    right: false,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(30, 84, 30, 26),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daftar',
                            style: serifStyle(
                              40,
                              color: AppColors.teal,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 40),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                AppTextField(
                                  hint: 'Email',
                                  icon: Icons.email,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                ),
                                SizedBox(height: 14),
                                AppPasswordField(
                                  hint: 'Password',
                                  icon: Icons.lock_outline,
                                  textInputAction: TextInputAction.next,
                                ),
                                SizedBox(height: 14),
                                AppPasswordField(
                                  hint: 'Konfirmasi password',
                                  icon: Icons.lock_outline,
                                  textInputAction: TextInputAction.done,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 34),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: PrimaryButton(
                              label: 'Daftar',
                              onPressed: () => _openHome(context),
                            ),
                          ),
                        ],
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
