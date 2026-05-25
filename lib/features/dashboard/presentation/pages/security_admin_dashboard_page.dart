import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SecurityAdminDashboardPage extends StatelessWidget {
  const SecurityAdminDashboardPage({super.key});

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthProvider>().logout();

    if (!context.mounted) return;

    Navigator.pushReplacementNamed(context, AppRouter.login);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userName =
        auth.appUser?.name ?? auth.firebaseUser?.displayName ?? 'Admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Sekuriti'),
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
            _AdminHeader(
              title: 'Halo, $userName',
              subtitle:
                  'Kelola warga, petugas sekuriti, CCTV, dan statistik keamanan residence.',
            ),
            const SizedBox(height: 20),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.08,
              children: const [
                _AdminStatCard(
                  title: 'Warga',
                  value: '0',
                  icon: Icons.groups_rounded,
                  color: AppColors.accent,
                ),
                _AdminStatCard(
                  title: 'Sekuriti',
                  value: '0',
                  icon: Icons.security_rounded,
                  color: AppColors.success,
                ),
                _AdminStatCard(
                  title: 'CCTV',
                  value: '0',
                  icon: Icons.videocam_rounded,
                  color: AppColors.motionDetected,
                ),
                _AdminStatCard(
                  title: 'Laporan',
                  value: '0',
                  icon: Icons.assignment_rounded,
                  color: AppColors.warning,
                ),
              ],
            ),

            const SizedBox(height: 22),

            _AdminMenuTile(
              icon: Icons.verified_user_rounded,
              title: 'Validasi Warga Baru',
              subtitle: 'Setujui atau tolak data warga yang baru mendaftar.',
              badge: StatusBadge.warning('Pending'),
            ),
            _AdminMenuTile(
              icon: Icons.badge_rounded,
              title: 'Kelola Sekuriti',
              subtitle: 'Tambah, ubah, atau nonaktifkan akun petugas.',
              badge: StatusBadge.info('Admin'),
            ),
            _AdminMenuTile(
              icon: Icons.videocam_rounded,
              title: 'Kelola CCTV',
              subtitle:
                  'Daftarkan CCTV, lokasi kamera, dan perangkat mockup CCTV.',
              badge: StatusBadge.danger('CCTV'),
            ),
            _AdminMenuTile(
              icon: Icons.analytics_rounded,
              title: 'Statistik Keamanan',
              subtitle: 'Lihat ringkasan SOS, laporan, dan motion alert.',
              badge: StatusBadge.success('Monitoring'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _AdminHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.admin_panel_settings_rounded,
            size: 58,
            color: Colors.white,
          ),
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
          StatusBadge.info('security_admin'),
        ],
      ),
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _AdminStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget badge;

  const _AdminMenuTile({
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
          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
          child: Icon(icon, color: AppColors.primary),
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
