import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/emergency_provider.dart';

class SosPage extends StatefulWidget {
  const SosPage({super.key});

  @override
  State<SosPage> createState() => _SosPageState();
}

class _SosPageState extends State<SosPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String _selectedType = 'security';

  final List<_EmergencyTypeOption> _types = const [
    _EmergencyTypeOption(
      value: 'security',
      label: 'Keamanan',
      icon: Icons.security_rounded,
      description: 'Ancaman, orang mencurigakan, pencurian, atau gangguan.',
    ),
    _EmergencyTypeOption(
      value: 'fire',
      label: 'Kebakaran',
      icon: Icons.local_fire_department_rounded,
      description: 'Api, asap, korsleting, atau potensi kebakaran.',
    ),
    _EmergencyTypeOption(
      value: 'medical',
      label: 'Medis',
      icon: Icons.medical_services_rounded,
      description: 'Butuh bantuan kesehatan segera.',
    ),
    _EmergencyTypeOption(
      value: 'other',
      label: 'Lainnya',
      icon: Icons.more_horiz_rounded,
      description: 'Darurat lain yang membutuhkan bantuan petugas.',
    ),
  ];

  @override
  void initState() {
    super.initState();

    final auth = context.read<AuthProvider>();
    final block = auth.appUser?.block ?? '';
    final houseNumber = auth.appUser?.houseNumber ?? '';

    if (block.isNotEmpty || houseNumber.isNotEmpty) {
      _locationController.text = 'Blok $block No. $houseNumber'.trim();
    } else {
      _locationController.text = 'Blok A No. 12';
    }

    _messageController.text = 'Butuh bantuan segera';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _sendSos() async {
    if (!_formKey.currentState!.validate()) return;

    final confirm = await _showConfirmDialog();

    if (!confirm) return;

    if (!mounted) return;

    final emergencyProvider = context.read<EmergencyProvider>();

    final success = await emergencyProvider.sendSos(
      emergencyType: _selectedType,
      message: _messageController.text.trim(),
      locationText: _locationController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      final alert = emergencyProvider.latestAlert;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            icon: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 54,
            ),
            title: const Text('SOS Berhasil Dikirim'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Petugas sekuriti akan menerima alert darurat dari sistem.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                if (alert != null) ...[
                  StatusBadge.danger(alert.priority.toUpperCase()),
                  const SizedBox(height: 10),
                  Text(
                    'Status: ${alert.status}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.pop(context);
                },
                child: const Text('Kembali ke Dashboard'),
              ),
            ],
          );
        },
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(emergencyProvider.errorMessage ?? 'Gagal mengirim SOS'),
        backgroundColor: AppColors.danger,
      ),
    );
  }

  Future<bool> _showConfirmDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.danger,
            size: 52,
          ),
          title: const Text('Kirim SOS Darurat?'),
          content: const Text(
            'SOS akan dikirim ke petugas sekuriti. Gunakan fitur ini hanya untuk kondisi darurat.',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Kirim SOS'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final emergencyProvider = context.watch<EmergencyProvider>();

    return LoadingOverlay(
      isLoading: emergencyProvider.isLoading,
      message: 'Mengirim SOS ke petugas...',
      child: Scaffold(
        appBar: AppBar(title: const Text('SOS Darurat')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
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
                    child: const Column(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 58,
                          color: AppColors.danger,
                        ),
                        SizedBox(height: 14),
                        Text(
                          'Kirim Bantuan Darurat',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Pilih jenis darurat dan pastikan lokasi sudah benar sebelum mengirim SOS.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Jenis Darurat',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  ..._types.map((type) {
                    final isSelected = _selectedType == type.value;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedType = type.value;
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accent.withValues(alpha: 0.1)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.accent
                                : AppColors.border,
                            width: isSelected ? 1.6 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: isSelected
                                  ? AppColors.accent
                                  : AppColors.accent.withValues(alpha: 0.12),
                              child: Icon(
                                type.icon,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.accent,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    type.label,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    type.description,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.accent,
                              ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 10),

                  CustomTextField(
                    label: 'Lokasi',
                    hint: 'Contoh: Blok A No. 12',
                    controller: _locationController,
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Lokasi wajib diisi';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'Pesan Darurat',
                    hint: 'Contoh: Butuh bantuan segera',
                    controller: _messageController,
                    prefixIcon: const Icon(Icons.message_outlined),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Pesan wajib diisi';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  CustomButton(
                    label: 'Kirim SOS Sekarang',
                    variant: ButtonVariant.danger,
                    icon: const Icon(Icons.warning_amber_rounded),
                    isLoading: emergencyProvider.isLoading,
                    onPressed: _sendSos,
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Data SOS akan dikirim ke backend dan masuk ke dashboard sekuriti/admin.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmergencyTypeOption {
  final String value;
  final String label;
  final IconData icon;
  final String description;

  const _EmergencyTypeOption({
    required this.value,
    required this.label,
    required this.icon,
    required this.description,
  });
}
