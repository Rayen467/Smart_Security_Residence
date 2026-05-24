import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  factory StatusBadge.success(String label) {
    return StatusBadge(
      label: label,
      color: AppColors.success,
      icon: Icons.check_circle_outline,
    );
  }

  factory StatusBadge.warning(String label) {
    return StatusBadge(
      label: label,
      color: AppColors.warning,
      icon: Icons.warning_amber_rounded,
    );
  }

  factory StatusBadge.danger(String label) {
    return StatusBadge(
      label: label,
      color: AppColors.danger,
      icon: Icons.error_outline_rounded,
    );
  }

  factory StatusBadge.info(String label) {
    return StatusBadge(
      label: label,
      color: AppColors.info,
      icon: Icons.info_outline_rounded,
    );
  }

  factory StatusBadge.neutral(String label) {
    return StatusBadge(
      label: label,
      color: AppColors.textSecondary,
      icon: Icons.circle_outlined,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
