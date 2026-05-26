import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/emergency/presentation/providers/emergency_provider.dart';

import 'core/constants/app_strings.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const SmartSecurityApp());
}

class SmartSecurityApp extends StatelessWidget {
  const SmartSecurityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<EmergencyProvider>(
          create: (_) => EmergencyProvider(),
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRouter.splash,
        routes: AppRouter.routes,
      ),
    );
  }
}
