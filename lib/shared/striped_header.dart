import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Cabecera negra con franjas diagonales amarillas muy suaves (marca Liga
/// SUR): `repeating-linear-gradient(135deg, rgba(255,199,0,.06) 14px, …)`.
class StripedHeader extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const StripedHeader({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 16, 20, 20),
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return CustomPaint(
      painter: _StripesPainter(
        background: c.header,
        stripe: c.brand.withValues(alpha: 0.06),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: c.onHeader),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class _StripesPainter extends CustomPainter {
  final Color background;
  final Color stripe;

  const _StripesPainter({required this.background, required this.stripe});

  static const double band = 14;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);
    final paint = Paint()
      ..color = stripe
      ..strokeWidth = band
      ..style = PaintingStyle.stroke;

    // Franjas a 135°: líneas paralelas separadas 2 bandas, en diagonal.
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    final step = band * 2 * 1.4142;
    for (double x = -size.height; x < size.width + size.height; x += step) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_StripesPainter old) =>
      old.background != background || old.stripe != stripe;
}
