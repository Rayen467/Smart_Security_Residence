import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../data/models/emergency_alert_model.dart';
import '../providers/emergency_provider.dart';

class SecuritySosPage extends StatefulWidget {
  const SecuritySosPage({super.key});

  @override
  State<SecuritySosPage> createState() => _SecuritySosPageState();
}

class _SecuritySosPageState extends State<SecuritySosPage> {
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmergencyProvider>().fetchSosAlerts();
    });
  }

  Future<void> _refresh() async {
    await context.read<EmergencyProvider>().fetchSosAlerts(
      status: _selectedStatus,
    );
  }

  Future<void> _changeStatus(EmergencyAlertModel alert, String status) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Update Status SOS'),
          content: Text('Ubah status SOS menjadi "${_statusLabel(status)}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Ya, Update'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    if (!mounted) return;

    final provider = context.read<EmergencyProvider>();

    final success = await provider.updateSosStatus(
      alertId: alert.id,
      status: status,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Status SOS berhasil diperbarui'
              : provider.errorMessage ?? 'Gagal update status SOS',
        ),
        backgroundColor: success ? AppColors.success : AppColors.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final emergencyProvider = context.watch<EmergencyProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('SOS Masuk')),
      body: Column(
        children: [
          _FilterBar(
            selectedStatus: _selectedStatus,
            onChanged: (status) {
              setState(() {
                _selectedStatus = status;
              });

              context.read<EmergencyProvider>().fetchSosAlerts(status: status);
            },
          ),
          Expanded(
            child: RefreshIndicator(
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
                          color: AppColors.danger,
                          size: 64,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          emergencyProvider.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
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
                          Icons.notifications_none_rounded,
                          size: 72,
                          color: AppColors.textHint,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Belum ada SOS masuk',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'SOS dari warga akan muncul di halaman ini.',
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

                      return _SosIncomingCard(
                        alert: alert,
                        onAccept: () => _changeStatus(alert, 'accepted'),
                        onProgress: () => _changeStatus(alert, 'in_progress'),
                        onComplete: () => _changeStatus(alert, 'completed'),
                        onFalseAlarm: () => _changeStatus(alert, 'false_alarm'),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    return switch (status) {
      'waiting' => 'Menunggu',
      'accepted' => 'Diterima',
      'in_progress' => 'Diproses',
      'completed' => 'Selesai',
      'cancelled' => 'Dibatalkan',
      'false_alarm' => 'False Alarm',
      _ => status,
    };
  }
}

class _FilterBar extends StatelessWidget {
  final String? selectedStatus;
  final ValueChanged<String?> onChanged;

  const _FilterBar({required this.selectedStatus, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final options = <String?, String>{
      null: 'Semua',
      'waiting': 'Menunggu',
      'accepted': 'Diterima',
      'in_progress': 'Diproses',
      'completed': 'Selesai',
      'false_alarm': 'False Alarm',
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: options.entries.map((entry) {
            final isSelected = selectedStatus == entry.key;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(entry.value),
                selected: isSelected,
                onSelected: (_) => onChanged(entry.key),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SosIncomingCard extends StatelessWidget {
  final EmergencyAlertModel alert;
  final VoidCallback onAccept;
  final VoidCallback onProgress;
  final VoidCallback onComplete;
  final VoidCallback onFalseAlarm;

  const _SosIncomingCard({
    required this.alert,
    required this.onAccept,
    required this.onProgress,
    required this.onComplete,
    required this.onFalseAlarm,
  });

  @override
  Widget build(BuildContext context) {
    final userName = alert.user?.name.isNotEmpty == true
        ? alert.user!.name
        : 'Warga #${alert.userId}';

    final userEmail = alert.user?.email ?? '-';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.danger.withValues(alpha: 0.12),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.danger,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _typeLabel(alert.emergencyType),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _statusBadge(alert.status),
              ],
            ),
            const SizedBox(height: 14),
            _InfoRow(icon: Icons.person_outline_rounded, label: userName),
            const SizedBox(height: 6),
            _InfoRow(icon: Icons.email_outlined, label: userEmail),
            const SizedBox(height: 6),
            _InfoRow(
              icon: Icons.location_on_outlined,
              label: alert.locationText,
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 16),
            _ActionButtons(
              status: alert.status,
              onAccept: onAccept,
              onProgress: onProgress,
              onComplete: onComplete,
              onFalseAlarm: onFalseAlarm,
            ),
          ],
        ),
      ),
    );
  }

  static String _typeLabel(String type) {
    return switch (type) {
      'security' => 'SOS Keamanan',
      'fire' => 'SOS Kebakaran',
      'medical' => 'SOS Medis',
      'other' => 'SOS Lainnya',
      _ => 'SOS Darurat',
    };
  }

  static Widget _statusBadge(String status) {
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

  static String _formatDate(DateTime? date) {
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final String status;
  final VoidCallback onAccept;
  final VoidCallback onProgress;
  final VoidCallback onComplete;
  final VoidCallback onFalseAlarm;

  const _ActionButtons({
    required this.status,
    required this.onAccept,
    required this.onProgress,
    required this.onComplete,
    required this.onFalseAlarm,
  });

  @override
  Widget build(BuildContext context) {
    if (status == 'completed' || status == 'false_alarm') {
      return const SizedBox.shrink();
    }

    if (status == 'waiting') {
      return Column(
        children: [
          CustomButton(
            label: 'Terima SOS',
            icon: const Icon(Icons.check_circle_outline_rounded),
            onPressed: onAccept,
          ),
          const SizedBox(height: 10),
          CustomButton(
            label: 'False Alarm',
            variant: ButtonVariant.outlined,
            icon: const Icon(Icons.cancel_outlined),
            onPressed: onFalseAlarm,
          ),
        ],
      );
    }

    if (status == 'accepted') {
      return Column(
        children: [
          CustomButton(
            label: 'Tandai Diproses',
            icon: const Icon(Icons.directions_run_rounded),
            onPressed: onProgress,
          ),
          const SizedBox(height: 10),
          CustomButton(
            label: 'False Alarm',
            variant: ButtonVariant.outlined,
            icon: const Icon(Icons.cancel_outlined),
            onPressed: onFalseAlarm,
          ),
        ],
      );
    }

    if (status == 'in_progress') {
      return CustomButton(
        label: 'Selesaikan SOS',
        icon: const Icon(Icons.task_alt_rounded),
        onPressed: onComplete,
      );
    }

    return const SizedBox.shrink();
  }
}
