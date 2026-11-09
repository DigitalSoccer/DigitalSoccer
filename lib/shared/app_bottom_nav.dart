import 'package:flutter/material.dart';

import '../core/theme.dart';

class AppNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const AppNavItem(this.icon, this.selectedIcon, this.label);
}

/// Barra inferior del mockup: 72 de alto, la pestaña activa con una píldora
/// amarilla de 52×30 detrás del ícono y la etiqueta en negrita.
class AppBottomNav extends StatelessWidget {
  final List<AppNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const AppBottomNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(child: _item(context, i)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(BuildContext context, int index) {
    final c = context.colors;
    final item = items[index];
    final active = index == selectedIndex;

    return Semantics(
      button: true,
      selected: active,
      label: item.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: () => onSelected(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              height: 30,
              decoration: BoxDecoration(
                color: active ? c.brand : Colors.transparent,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                active ? item.selectedIcon : item.icon,
                size: 22,
                color: active ? c.onBrand : c.textMuted,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              style: TextStyle(
                fontFamily: AppFonts.family,
                fontSize: 11,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                color: active ? c.text : c.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
