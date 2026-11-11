import 'package:flutter/material.dart';

import 'package:app_hafalan_quran/screens/home_screen.dart';
import 'package:app_hafalan_quran/screens/register_screen.dart';
import 'package:app_hafalan_quran/theme/app_theme.dart';
import 'package:app_hafalan_quran/widgets/app_text_field.dart';
import 'package:app_hafalan_quran/widgets/avatar_badge.dart';
import 'package:app_hafalan_quran/widgets/google_sign_in_button.dart';
import 'package:app_hafalan_quran/widgets/mosque_background.dart';
import 'package:app_hafalan_quran/widgets/primary_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const String route = '/';

  void _openHome(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(HomeShell.route, (route) => false);
  }

  void _openRegister(BuildContext context) {
    Navigator.of(context).pushNamed(RegisterScreen.route);
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
            children: [
              const SizedBox(height: 16),
              const AvatarBadge(),
              const SizedBox(height: 6),
              Text(
                'Logo',
                style: serifStyle(38, color: AppColors.white, height: 1.25),
              ),
              const SizedBox(height: 34),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'As salamualaikum',
                        style: serifStyle(
                          26,
                          weight: FontWeight.w600,
                          color: AppColors.white,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Baraya baraya',
                        style: sansStyle(
                          16,
                          color: AppColors.white.withValues(alpha: 0.94),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 64),
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
                      padding: const EdgeInsets.fromLTRB(30, 32, 30, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Login',
                            style: serifStyle(
                              42,
                              color: AppColors.teal,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 30),
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
                                SizedBox(height: 12),
                                AppPasswordField(
                                  hint: 'Password',
                                  icon: Icons.lock_outline,
                                  textInputAction: TextInputAction.done,
                                ),
                                SizedBox(height: 7),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 32),
                              child: Text(
                                'Lupa password',
                                style: sansStyle(11.5, height: 1.2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: PrimaryButton(
                              label: 'Login',
                              onPressed: () => _openHome(context),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Center(
                            child: GoogleSignInButton(
                              onPressed: () => _openHome(context),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  'Belum punya akun? ',
                                  style: sansStyle(11.5, height: 1.2),
                                ),
                                GestureDetector(
                                  onTap: () => _openRegister(context),
                                  child: Text(
                                    'Daftar',
                                    style: sansStyle(
                                      11.5,
                                      weight: FontWeight.w600,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                              ],
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
