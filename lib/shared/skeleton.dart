import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Esqueleto de carga con brillo animado (para tabla, fixture y noticias).
class Skeleton extends StatefulWidget {
  final Widget child;

  const Skeleton({super.key, required this.child});

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      label: 'Cargando',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value;
          return ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (rect) => LinearGradient(
              begin: Alignment(-1 + 3 * t - 1, 0),
              end: Alignment(-1 + 3 * t, 0),
              colors: [c.surfaceMuted, c.divider, c.surfaceMuted],
            ).createShader(rect),
            child: child,
          );
        },
        child: ExcludeSemantics(child: widget.child),
      ),
    );
  }
}

/// Bloque gris del esqueleto.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    this.width,
    this.height = 14,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.colors.surfaceMuted,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Lista de filas esqueleto (tarjetas de partido, filas de tabla, noticias).
class SkeletonList extends StatelessWidget {
  final int rows;
  final double rowHeight;

  const SkeletonList({super.key, this.rows = 6, this.rowHeight = 64});

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      child: Column(
        children: [
          for (var i = 0; i < rows; i++)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: SkeletonBox(height: rowHeight, radius: AppRadius.lg),
            ),
        ],
      ),
    );
  }
}
