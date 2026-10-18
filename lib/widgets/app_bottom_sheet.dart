import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'surface_card.dart';

/// Hoja inferior deslizable con esquinas redondeadas, manilla y título.
/// [children] se muestran bajo el título en una lista desplazable; la hoja
/// se puede arrastrar entre el tamaño inicial y casi toda la pantalla.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required String title,
  required List<Widget> Function(BuildContext context) builder,
  double initialSize = 0.6,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: initialSize,
      minChildSize: 0.3,
      maxChildSize: 0.92,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              0,
              AppSpacing.xl,
              AppSpacing.md,
            ),
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          ...builder(context),
        ],
      ),
    ),
  );
}

/// Grupo de opciones de una hoja de selección, con título opcional.
class SheetSection<T> {
  final String? title;
  final List<SheetOption<T>> options;

  const SheetSection({this.title, required this.options});
}

class SheetOption<T> {
  final T value;
  final String label;

  const SheetOption(this.value, this.label);
}

/// Hoja de selección única: devuelve la opción tocada, o `null` si se
/// cierra sin elegir.
Future<T?> showSelectionSheet<T>({
  required BuildContext context,
  required String title,
  required List<SheetSection<T>> sections,
  required T selected,
}) {
  return showAppBottomSheet<T>(
    context: context,
    title: title,
    builder: (context) => [
      for (final section in sections) ...[
        if (section.title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.xl,
              AppSpacing.xs,
            ),
            child: Text(section.title!.toUpperCase(), style: AppText.eyebrow),
          ),
        for (final option in section.options)
          SheetOptionTile(
            label: option.label,
            selected: option.value == selected,
            onTap: () => Navigator.pop(context, option.value),
          ),
      ],
    ],
  );
}

/// Fila de una hoja de selección. La opción activa lleva fondo rojo suave
/// y un check.
class SheetOptionTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const SheetOptionTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 2,
      ),
      child: Material(
        color: selected ? AppColors.primarySoft : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? AppColors.primary : AppColors.text,
                    ),
                  ),
                ),
                if (selected)
                  const Icon(
                    Icons.check_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Campo que muestra la opción actual y abre una hoja de selección al
/// tocarlo. Reemplaza a los menús desplegables de formulario.
class SelectorField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const SelectorField({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      radius: AppRadius.md,
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(), style: AppText.eyebrow),
                const SizedBox(height: 2),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}
