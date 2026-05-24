import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

import 'shared/widgets/auth_header.dart';
import 'shared/widgets/custom_button.dart';
import 'shared/widgets/divider_with_text.dart';
import 'shared/widgets/status_badge.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const SmartSecurityApp());
}

class SmartSecurityApp extends StatelessWidget {
  const SmartSecurityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SetupCheckPage(),
    );
  }
}

class SetupCheckPage extends StatelessWidget {
  const SetupCheckPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.appName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const AuthHeader(
              icon: Icons.security_rounded,
              title: 'Setup Berhasil',
              subtitle: 'Core layer dan reusable widgets sudah siap digunakan.',
            ),
            const SizedBox(height: 28),

            StatusBadge.success('System Ready'),
            const SizedBox(height: 12),

            StatusBadge.warning('Menunggu Verifikasi'),
            const SizedBox(height: 12),

            StatusBadge.danger('Motion Detected'),
            const SizedBox(height: 28),

            CustomButton(
              label: 'Tes Tombol Primary',
              icon: const Icon(Icons.check_circle_outline),
              onPressed: () {},
            ),
            const SizedBox(height: 14),

            CustomButton(
              label: 'Tes Tombol SOS',
              variant: ButtonVariant.danger,
              icon: const Icon(Icons.warning_amber_rounded),
              onPressed: () {},
            ),
            const SizedBox(height: 14),

            CustomButton(
              label: 'Tes Tombol Outline',
              variant: ButtonVariant.outlined,
              onPressed: () {},
            ),
            const SizedBox(height: 24),

            const DividerWithText(text: 'Reusable Widgets'),
          ],
        ),
      ),
    );
  }
}
