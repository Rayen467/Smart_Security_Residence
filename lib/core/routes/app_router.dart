import 'package:flutter/material.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/verify_email_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_router_page.dart';
import '../../features/emergency/presentation/pages/sos_page.dart';
import '../../features/emergency/presentation/pages/sos_history_page.dart';
import '../../features/emergency/presentation/pages/security_sos_page.dart';
import 'auth_guard.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String dashboard = '/dashboard';
  static const String sos = '/sos';
  static const String securitySos = '/security-sos';
  static const String sosHistory = '/sos-history';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (_) => const SplashPage(),
      login: (_) => const LoginPage(),
      register: (_) => const RegisterPage(),
      verifyEmail: (_) => const VerifyEmailPage(),
      dashboard: (_) => const AuthGuard(child: DashboardRouterPage()),
      sos: (_) => const AuthGuard(child: SosPage()),
      sosHistory: (_) => const AuthGuard(child: SosHistoryPage()),
      securitySos: (_) => const AuthGuard(child: SecuritySosPage()),
    };
  }
}
