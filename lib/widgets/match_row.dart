import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';
import 'app_components.dart';

class MatchRow extends StatefulWidget {
  final String matchId;
  final String time;
  final String home;
  final String away;
  final String category;
  final String fieldName;
  final String status;

  const MatchRow({
    super.key,
    required this.matchId,
    required this.time,
    required this.home,
    required this.away,
    required this.category,
    required this.fieldName,
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

    setState(() {
      isFavorite = favs.contains(widget.matchId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 64,
              decoration: BoxDecoration(
                color: MatchStatusBadge.colorFor(widget.status),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            SizedBox(
              width: 52,
              child: Text(
                widget.time,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.home} vs ${widget.away}',
                    style: textTheme.titleSmall,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Chip(
                        label: Text(
                          widget.category,
                        ),
                      ),
                      MatchStatusBadge(status: widget.status),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  Text(
                    widget.fieldName,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            IconButton(
              tooltip: isFavorite
                  ? 'Quitar de favoritos'
                  : 'Marcar como favorito',
              icon: Icon(
                isFavorite
                    ? Icons.star
                    : Icons.star_border,
                color: isFavorite
                    ? AppColors.favorite
                    : AppColors.outline,
              ),
              onPressed: toggleFavorite,
            ),
          ],
        ),
      ),
    );
  }
}
