import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Marcador TEMPORAL de una pantalla que se construye en una etapa
/// siguiente del plan (se reemplaza al construirla).
class ComingSoon extends StatelessWidget {
  final String title;
  final int stage;

  /// Con botón de volver (pantallas abiertas desde "Más").
  final bool pushed;

  const ComingSoon({
    super.key,
    required this.title,
    required this.stage,
    this.pushed = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final body = SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          if (!pushed) Text(title, style: AppText.title(context)),
          const SizedBox(height: 40),
          Icon(Icons.construction_rounded, size: 40, color: c.textFaint),
          const SizedBox(height: 12),
          Text(
            'Esta pantalla se construye en la etapa $stage.',
            textAlign: TextAlign.center,
            style: AppText.muted(context, size: 14),
          ),
        ],
      ),
    );

    if (!pushed) return body;
    return Scaffold(appBar: AppBar(title: Text(title)), body: body);
  }
}
