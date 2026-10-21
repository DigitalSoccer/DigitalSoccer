import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Fila de chips (`SerieChips` en `docs/diseno.md`): 44 de alto; el elegido
/// con fondo rojo y texto blanco, el resto blanco con borde. Sirve para
/// series, tipos de noticia u otros filtros.
class PillChips extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  /// En varias líneas (sin desplazamiento horizontal ni margen lateral),
  /// como en la pantalla de elegir equipo.
  final bool wrap;

  const PillChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.wrap = false,
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
          color: isSelected ? c.primary : c.surface,
          shape: StadiumBorder(
            side: BorderSide(color: isSelected ? c.primary : c.borderStrong),
          ),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: () => onSelected(option),
            child: Container(
              height: 44,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                option,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? c.onPrimary : c.text,
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (wrap) {
      return Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [for (final option in options) chip(option)],
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
      child: Row(
        children: [
          for (final option in options)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              // El elegido se desplaza a la vista (p. ej. "General", que va
              // al final de la fila).
              child: option == selected
                  ? _RevealOnShow(key: ValueKey(option), child: chip(option))
                  : chip(option),
            ),
        ],
      ),
    );
  }
}

/// Al aparecer, desplaza la fila para que el chip quede a la vista.
class _RevealOnShow extends StatefulWidget {
  final Widget child;

  const _RevealOnShow({super.key, required this.child});

  @override
  State<_RevealOnShow> createState() => _RevealOnShowState();
}

class _RevealOnShowState extends State<_RevealOnShow> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = context.findRenderObject();
      if (!mounted || box == null) return;
      // Solo la fila horizontal (no la página): por eso no se usa
      // Scrollable.ensureVisible, que mueve todos los desplazables.
      Scrollable.of(context).position.ensureVisible(
            box,
            alignment: 0.5,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
