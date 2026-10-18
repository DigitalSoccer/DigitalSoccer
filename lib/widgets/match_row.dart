import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';
import 'app_components.dart';

/// Una línea del fixture, como en la planilla: hora y serie de un partido.
/// Los equipos se muestran en el encabezado del cruce (`Matchup`).
class MatchRow extends StatefulWidget {
  final String matchId;
  final String time;
  final String category;
  final String status;

  const MatchRow({
    super.key,
    required this.matchId,
    required this.time,
    required this.category,
    required this.status,
  });

  @override
  State<MatchRow> createState() => _MatchRowState();
}

class _MatchRowState extends State<MatchRow> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    loadFavorite();
  }

  Future<void> loadFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('favorites') ?? [];

    if (!mounted) return;

    setState(() {
      isFavorite = favs.contains(widget.matchId);
    });
  }

  Future<void> toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();

    final favs =
        prefs.getStringList('favorites') ?? [];

    if (favs.contains(widget.matchId)) {
      favs.remove(widget.matchId);
    } else {
      favs.add(widget.matchId);
    }

    await prefs.setStringList(
      'favorites',
      favs,
    );

    if (!mounted) return;

    setState(() {
      isFavorite = favs.contains(widget.matchId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.xs,
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 20,
            decoration: BoxDecoration(
              color: MatchStatusBadge.colorFor(widget.status),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          SizedBox(
            width: 52,
            child: Text(
              widget.time,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),

          Expanded(
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  widget.category,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.text,
                  ),
                ),
                MatchStatusBadge(status: widget.status),
              ],
            ),
          ),

          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: isFavorite
                ? 'Quitar de favoritos'
                : 'Marcar como favorito',
            icon: Icon(
              isFavorite
                  ? Icons.star
                  : Icons.star_border,
              size: 20,
              color: isFavorite
                  ? AppColors.favorite
                  : AppColors.outline,
            ),
            onPressed: toggleFavorite,
          ),
        ],
      ),
    );
  }
}
