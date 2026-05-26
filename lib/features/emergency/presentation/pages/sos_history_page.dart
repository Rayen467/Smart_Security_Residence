import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../providers/emergency_provider.dart';

class SosHistoryPage extends StatefulWidget {
  const SosHistoryPage({super.key});

  @override
  State<SosHistoryPage> createState() => _SosHistoryPageState();
}

class _SosHistoryPageState extends State<SosHistoryPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmergencyProvider>().fetchMySosHistory();
    });
  }

  Future<void> _refresh() async {
    await context.read<EmergencyProvider>().fetchMySosHistory();
  }

  @override
  Widget build(BuildContext context) {
    final emergencyProvider = context.watch<EmergencyProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat SOS')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Builder(
          builder: (context) {
            if (emergencyProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (emergencyProvider.errorMessage != null) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: AppColors.danger,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    emergencyProvider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton.icon(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Coba Lagi'),
                  ),
                ],
              );
            }

            if (emergencyProvider.alerts.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: const [
                  SizedBox(height: 80),
                  Icon(
                    Icons.history_rounded,
                    size: 72,
                    color: AppColors.textHint,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada riwayat SOS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'SOS yang kamu kirim akan muncul di halaman ini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: emergencyProvider.alerts.length,
              itemBuilder: (context, index) {
                final alert = emergencyProvider.alerts[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.danger.withValues(
                                alpha: 0.12,
                              ),
                              child: const Icon(
                                Icons.warning_amber_rounded,
                                color: AppColors.danger,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _formatEmergencyType(alert.emergencyType),
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    alert.locationText,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _statusBadge(alert.status),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          alert.message,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatDate(alert.createdAt),
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const Spacer(),
                            StatusBadge.danger(alert.priority.toUpperCase()),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _formatEmergencyType(String type) {
    return switch (type) {
      'security' => 'Keamanan',
      'fire' => 'Kebakaran',
      'medical' => 'Medis',
      'other' => 'Lainnya',
      _ => type,
    };
  }

  Widget _statusBadge(String status) {
    return switch (status) {
      'waiting' => StatusBadge.warning('Menunggu'),
      'accepted' => StatusBadge.info('Diterima'),
      'in_progress' => StatusBadge.info('Diproses'),
      'completed' => StatusBadge.success('Selesai'),
      'cancelled' => StatusBadge.neutral('Dibatalkan'),
      'false_alarm' => StatusBadge.danger('False Alarm'),
      _ => StatusBadge.neutral(status),
    };
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';

    final local = date.toLocal();

    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();

    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }
}
