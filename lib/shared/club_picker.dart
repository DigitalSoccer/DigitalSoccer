import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/league_data.dart';
import 'club_shield.dart';

/// Grilla de los clubes con su escudo para elegir uno (ingreso del
/// visitante y "Mi club").
class ClubPicker extends StatelessWidget {
  final List<Club> clubs;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  const ClubPicker({
    super.key,
    required this.clubs,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 3 columnas en teléfono; más en pantallas anchas.
        final columns = (constraints.maxWidth / 110).floor().clamp(3, 6);
        final width =
            (constraints.maxWidth - AppSpacing.sm * (columns - 1)) / columns;
        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final club in clubs)
              SizedBox(
                width: width,
                child: _ClubOption(
                  club: club,
                  selected: club.id == selectedId,
                  onTap: () => onSelected(club.id),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ClubOption extends StatelessWidget {
  final Club club;
  final bool selected;
  final VoidCallback onTap;

  const _ClubOption({
    required this.club,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Semantics(
      button: true,
      selected: selected,
      label: club.name,
      excludeSemantics: true,
      child: Material(
        color: selected ? c.brandSoft : c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(
            color: selected ? c.brand : c.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
            child: Column(
              children: [
                ClubShield(club: club, size: 40),
                const SizedBox(height: 6),
                Text(
                  club.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.strong(context, size: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
