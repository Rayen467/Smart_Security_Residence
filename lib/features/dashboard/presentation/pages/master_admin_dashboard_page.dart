import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class MasterAdminDashboardPage extends StatelessWidget {
  const MasterAdminDashboardPage({super.key});

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthProvider>().logout();

    if (!context.mounted) return;

    Navigator.pushReplacementNamed(context, AppRouter.login);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userName =
        auth.appUser?.name ?? auth.firebaseUser?.displayName ?? 'Master Admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Master'),
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.workspace_premium_rounded,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Halo, $userName',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Kelola sistem utama, admin sekuriti, area residence, role, dan audit log.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, height: 1.5),
                  ),
                  const SizedBox(height: 14),
                  StatusBadge.info('master_admin'),
                ],
              ),
            ),

            const SizedBox(height: 22),

            _MasterMenuTile(
              icon: Icons.admin_panel_settings_rounded,
              title: 'Kelola Admin Sekuriti',
              subtitle: 'Tambah dan atur admin sekuriti tiap area residence.',
              badge: StatusBadge.info('Master'),
            ),
            _MasterMenuTile(
              icon: Icons.location_city_rounded,
              title: 'Kelola Area Residence',
              subtitle:
                  'Atur data perumahan, blok, cluster, dan area keamanan.',
              badge: StatusBadge.success('Area'),
            ),
            _MasterMenuTile(
              icon: Icons.manage_accounts_rounded,
              title: 'Kelola Role & Akses',
              subtitle: 'Atur hak akses warga, sekuriti, dan admin.',
              badge: StatusBadge.warning('RBAC'),
            ),
            _MasterMenuTile(
              icon: Icons.receipt_long_rounded,
              title: 'Audit Log',
              subtitle: 'Pantau jejak aktivitas penting di dalam sistem.',
              badge: StatusBadge.danger('Security'),
            ),
            _MasterMenuTile(
              icon: Icons.monitor_heart_rounded,
              title: 'Monitoring Sistem',
              subtitle:
                  'Lihat ringkasan kesehatan sistem, laporan, SOS, dan CCTV.',
              badge: StatusBadge.info('System'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MasterMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget badge;

  const _MasterMenuTile({
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
          backgroundColor: AppColors.primaryDark.withValues(alpha: 0.12),
          child: Icon(icon, color: AppColors.primaryDark),
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
