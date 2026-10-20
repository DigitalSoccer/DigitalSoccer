import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Pestañas segmentadas estilo píldora: la pestaña activa es una píldora
/// blanca con sombra sobre una pista slate-100. Usa el `TabController` del
/// `DefaultTabController` más cercano.
class SegmentedTabBar extends StatelessWidget {
  final List<String> labels;

  /// Con muchas pestañas se desplaza en vez de repartir el ancho.
  final bool scrollable;

  const SegmentedTabBar({
    super.key,
    required this.labels,
    this.scrollable = false,
  });

  static const double height = 44;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: context.colors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: TabBar(
        isScrollable: scrollable,
        tabAlignment: scrollable ? TabAlignment.start : TabAlignment.fill,
        labelPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        splashBorderRadius: BorderRadius.circular(AppRadius.pill),
        tabs: [
          for (final label in labels)
            Tab(text: label, height: height - AppSpacing.sm),
        ],
      ),
    );
  }
}
