import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ResidentDashboardPage extends StatelessWidget {
  const ResidentDashboardPage({super.key});

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthProvider>().logout();

    if (!context.mounted) return;

    Navigator.pushReplacementNamed(context, AppRouter.login);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userName =
        auth.appUser?.name ?? auth.firebaseUser?.displayName ?? 'Warga';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Warga'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _WelcomeCard(
              title: 'Halo, $userName',
              subtitle:
                  'Gunakan aplikasi ini untuk mengirim SOS, membuat laporan keamanan, dan memantau status laporan.',
              icon: Icons.home_rounded,
              badge: StatusBadge.info('resident'),
            ),
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppColors.danger.withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 56,
                    color: AppColors.danger,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'SOS Darurat',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tekan tombol ini jika membutuhkan bantuan keamanan secepatnya.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  CustomButton(
                    label: 'Kirim SOS',
                    variant: ButtonVariant.danger,
                    icon: const Icon(Icons.warning_amber_rounded),
                    onPressed: () {
                      Navigator.pushNamed(context, AppRouter.sos);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _DashboardMenuCard(
              icon: Icons.report_problem_outlined,
              title: 'Buat Laporan Keamanan',
              subtitle:
                  'Laporkan kejadian mencurigakan atau gangguan keamanan.',
              status: 'Phase berikutnya',
              onTap: () {},
            ),
            _DashboardMenuCard(
              icon: Icons.history_rounded,
              title: 'Riwayat SOS',
              subtitle: 'Lihat status SOS darurat yang pernah kamu kirim.',
              status: 'Aktif',
              onTap: () {
                Navigator.pushNamed(context, AppRouter.sosHistory);
              },
            ),
            _DashboardMenuCard(
              icon: Icons.notifications_active_outlined,
              title: 'Notifikasi',
              subtitle: 'Pantau update laporan, SOS, dan informasi keamanan.',
              status: 'Belum aktif',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget badge;

  const _WelcomeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 54, color: AppColors.accent),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 14),
          badge,
        ],
      ),
    );
  }
}

class _DashboardMenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final VoidCallback onTap;

  const _DashboardMenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),
        leading: CircleAvatar(
          backgroundColor: AppColors.accent.withValues(alpha: 0.12),
          child: Icon(icon, color: AppColors.accent),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle),
        ),
        trailing: StatusBadge.neutral(status),
        onTap: onTap,
      ),
    );
  }
}
