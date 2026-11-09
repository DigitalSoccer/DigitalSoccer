import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Selector segmentado del mockup ("Ver la app como", equipos de la
/// papeleta): pista gris y la opción elegida invertida.
class SegmentedChoice<T> extends StatelessWidget {
  final List<(T, String)> options;

  /// `null` = ninguna elegida.
  final T? selected;
  final ValueChanged<T> onSelected;

  const SegmentedChoice({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(child: _option(context, options[i])),
          ],
        ],
      ),
    );
  }

  Widget _option(BuildContext context, (T, String) option) {
    final c = context.colors;
    final active = option.$1 == selected;

    return Semantics(
      button: true,
      selected: active,
      child: Material(
        color: active ? c.inverse : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onSelected(option.$1),
          child: Container(
            constraints: const BoxConstraints(minHeight: 44),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              option.$2,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppFonts.family,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: active ? c.onInverse : c.text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
