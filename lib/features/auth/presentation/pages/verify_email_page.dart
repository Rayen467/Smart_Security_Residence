import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../shared/widgets/auth_header.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../providers/auth_provider.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  Timer? _resendTimer;
  bool _resendCooldown = false;
  int _countdown = 60;

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkVerification() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.checkEmailVerified();

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, AppRouter.dashboard);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          auth.errorMessage ??
              'Email belum terverifikasi. Silakan cek inbox email kamu.',
        ),
        backgroundColor: auth.status == AuthStatus.error
            ? AppColors.danger
            : AppColors.warning,
      ),
    );
  }

  Future<void> _resendEmail() async {
    if (_resendCooldown) return;

    await context.read<AuthProvider>().resendVerificationEmail();

    if (!mounted) return;

    setState(() {
      _resendCooldown = true;
      _countdown = 60;
    });

    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        _countdown--;
      });

      if (_countdown <= 0) {
        timer.cancel();

        if (!mounted) return;

        setState(() {
          _resendCooldown = false;
        });
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email verifikasi berhasil dikirim ulang')),
    );
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, AppRouter.login);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userEmail = auth.firebaseUser?.email ?? '-';

    return LoadingOverlay(
      isLoading: auth.isLoading,
      message: 'Mengecek verifikasi email...',
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AuthHeader(
                  icon: Icons.mark_email_unread_outlined,
                  title: 'Verifikasi Email',
                  subtitle:
                      'Kami sudah mengirim link verifikasi. Klik link tersebut, lalu kembali ke aplikasi.',
                  iconColor: AppColors.warning,
                ),
                const SizedBox(height: 26),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Email tujuan:',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        userEmail,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                CustomButton(
                  label: 'Saya Sudah Verifikasi',
                  icon: const Icon(Icons.verified_outlined),
                  onPressed: _checkVerification,
                ),
                const SizedBox(height: 14),

                CustomButton(
                  label: _resendCooldown
                      ? 'Kirim Ulang ($_countdown detik)'
                      : 'Kirim Ulang Email',
                  variant: ButtonVariant.outlined,
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: _resendCooldown ? null : _resendEmail,
                ),
                const SizedBox(height: 14),

                CustomButton(
                  label: 'Ganti Akun / Logout',
                  variant: ButtonVariant.text,
                  icon: const Icon(Icons.logout_rounded),
                  onPressed: _logout,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
