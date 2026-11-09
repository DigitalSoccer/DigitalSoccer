import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Fila de chips con desplazamiento horizontal (series, tipos de noticia).
/// El elegido va invertido (negro con texto blanco en modo claro).
class PillChips extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;
  final EdgeInsetsGeometry padding;

  const PillChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    Widget chip(String option) {
      final isSelected = option == selected;
      return Semantics(
        button: true,
        selected: isSelected,
        child: Material(
          color: isSelected ? c.inverse : c.surface,
          shape: StadiumBorder(
            side: BorderSide(
              color: isSelected ? c.inverse : c.borderStrong,
              width: 1.5,
            ),
          ),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: () => onSelected(option),
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                option,
                style: TextStyle(
                  fontFamily: AppFonts.family,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? c.onInverse : c.text,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: [
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            chip(options[i]),
          ],
        ],
      ),
    );
  }
}
