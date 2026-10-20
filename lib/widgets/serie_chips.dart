import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Fila de chips con scroll horizontal (`SerieChips` en `docs/diseno.md`):
/// 44 de alto; el elegido con fondo rojo y texto blanco, el resto blanco con
/// borde. Sirve para series, tipos de noticia u otros filtros.
class PillChips extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  const PillChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
      child: Row(
        children: [
          for (final option in options)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: Semantics(
                button: true,
                selected: option == selected,
                child: Material(
                  color: option == selected ? c.primary : c.surface,
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: option == selected ? c.primary : c.borderStrong,
                    ),
                  ),
                  child: InkWell(
                    customBorder: const StadiumBorder(),
                    onTap: () => onSelected(option),
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: Text(
                        option,
                        style: TextStyle(
                          fontFamily: AppFonts.body,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: option == selected ? c.onPrimary : c.text,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
