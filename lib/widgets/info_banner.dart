import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Aviso discreto en línea: ícono y texto sobre fondo slate-100.
class InfoBanner extends StatelessWidget {
  final IconData icon;
  final String message;
  final bool strong;

  const InfoBanner({
    super.key,
    required this.message,
    this.icon = Icons.info_outline,
    this.strong = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: strong ? AppColors.text : AppColors.textSecondary,
                fontWeight: strong ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
