import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Buscador de los listados (Fixture, Clubes): fondo de tarjeta, borde y
/// lupa a la izquierda, como el mockup.
class SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String hint;
  final double height;

  const SearchField({
    super.key,
    required this.onChanged,
    this.hint = 'Buscar club',
    this.height = 44,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    OutlineInputBorder border(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: color),
        );

    return SizedBox(
      height: height,
      child: TextField(
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: TextStyle(fontSize: 16, color: c.text),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(Icons.search_rounded, color: c.textMuted),
          filled: true,
          fillColor: c.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
          border: border(c.borderStrong),
          enabledBorder: border(c.borderStrong),
          focusedBorder: border(c.primaryText),
        ),
      ),
    );
  }
}
