import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SecurityGuardDashboardPage extends StatelessWidget {
  const SecurityGuardDashboardPage({super.key});

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthProvider>().logout();

    if (!context.mounted) return;

    Navigator.pushReplacementNamed(context, AppRouter.login);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userName =
        auth.appUser?.name ?? auth.firebaseUser?.displayName ?? 'Sekuriti';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Sekuriti'),
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
            _HeaderCard(
              icon: Icons.shield_rounded,
              title: 'Halo, $userName',
              subtitle:
                  'Pantau SOS masuk, laporan warga, dan alert CCTV motion detection.',
              badge: StatusBadge.info('security_guard'),
            ),
            const SizedBox(height: 20),

            Row(
              children: const [
                Expanded(
                  child: _StatCard(
                    title: 'SOS Aktif',
                    value: '0',
                    icon: Icons.sos_rounded,
                    color: AppColors.danger,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Laporan',
                    value: '0',
                    icon: Icons.assignment_rounded,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(
                  child: _StatCard(
                    title: 'CCTV Alert',
                    value: '0',
                    icon: Icons.videocam_rounded,
                    color: AppColors.motionDetected,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Selesai',
                    value: '0',
                    icon: Icons.check_circle_rounded,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            _ActionTile(
              icon: Icons.warning_amber_rounded,
              title: 'SOS Masuk',
              subtitle: 'Lihat daftar permintaan darurat dari warga.',
              badge: StatusBadge.danger('Prioritas'),
            ),
            _ActionTile(
              icon: Icons.report_problem_outlined,
              title: 'Laporan Keamanan',
              subtitle: 'Tangani laporan warga yang masuk.',
              badge: StatusBadge.warning('Menunggu'),
            ),
            _ActionTile(
              icon: Icons.videocam_rounded,
              title: 'CCTV Motion Alert',
              subtitle:
                  'Verifikasi alert dari Smart CCTV Motion Detection Module.',
              badge: StatusBadge.danger('Motion'),
            ),
            _ActionTile(
              icon: Icons.task_alt_rounded,
              title: 'Tugas Aktif',
              subtitle: 'Pantau tugas penanganan yang sedang berjalan.',
              badge: StatusBadge.info('Aktif'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget badge;

  const _HeaderCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Icon(icon, size: 56, color: Colors.white),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, height: 1.5),
          ),
          const SizedBox(height: 14),
          badge,
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 126,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget badge;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
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
        trailing: badge,
      ),
    );
  }
}
