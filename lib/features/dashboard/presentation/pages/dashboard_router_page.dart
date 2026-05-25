import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import 'master_admin_dashboard_page.dart';
import 'resident_dashboard_page.dart';
import 'security_admin_dashboard_page.dart';
import 'security_guard_dashboard_page.dart';

class DashboardRouterPage extends StatelessWidget {
  const DashboardRouterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().userRole;

    return switch (role) {
      'resident' => const ResidentDashboardPage(),
      'security_guard' => const SecurityGuardDashboardPage(),
      'security_admin' => const SecurityAdminDashboardPage(),
      'master_admin' => const MasterAdminDashboardPage(),
      _ => const ResidentDashboardPage(),
    };
  }
}
