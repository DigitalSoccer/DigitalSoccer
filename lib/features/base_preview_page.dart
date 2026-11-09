import 'package:flutter/material.dart';

import '../core/appearance.dart';
import '../core/theme.dart';
import '../data/league_scope.dart';
import '../shared/club_shield.dart';
import '../shared/liga_logo.dart';
import '../shared/pill_chips.dart';
import '../shared/skeleton.dart';
import '../shared/striped_header.dart';

/// Vista previa TEMPORAL de la etapa 1 (base y tema): muestra la marca, los
/// componentes compartidos y los datos de muestra. En la etapa 2 se reemplaza
/// por la navegación real.
class BasePreviewPage extends StatefulWidget {
  const BasePreviewPage({super.key});

  @override
  State<BasePreviewPage> createState() => _BasePreviewPageState();
}

class _BasePreviewPageState extends State<BasePreviewPage> {
  String? _serieId;

  @override
  Widget build(BuildContext context) {
    final data = LeagueScope.of(context);
    final c = context.colors;
    final serie = data.serie(_serieId) ?? data.series[1];
    final table = data.standings(serie.id);
    final appearance = AppearanceScope.maybeOf(context);
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          StripedHeader(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.paddingOf(context).top + 16,
              20,
              24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const LigaLogo(),
                    const Spacer(),
                    IconButton(
                      tooltip: dark ? 'Modo claro' : 'Modo oscuro',
                      color: c.onHeader,
                      onPressed: () => appearance?.select(
                        dark ? ThemeMode.light : ThemeMode.dark,
                      ),
                      icon: Icon(dark
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text('ETAPA 1 · BASE Y TEMA',
                    style: AppText.eyebrow(context, color: c.brand)),
                const SizedBox(height: 6),
                Text(
                  'Liga SUR',
                  style: AppText.title(context, color: c.onHeader),
                ),
                Text(
                  '${data.clubs.length} clubes · ${data.series.length} series · '
                  '${data.rounds.length} fechas · ${data.matches.length} partidos',
                  style: AppText.muted(context, color: c.onHeaderMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          PillChips(
            options: [for (final s in data.series) s.name],
            selected: serie.name,
            onSelected: (name) => setState(() {
              _serieId = data.series.firstWhere((s) => s.name == name).id;
            }),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text('Tabla · ${serie.name} (calculada desde resultados)',
                style: AppText.section(context)),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: c.border),
            ),
            child: Column(
              children: [
                for (final row in table.take(6))
                  ListTile(
                    leading: SizedBox(
                      width: 60,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 24,
                            child: Text('${row.position}',
                                style: AppText.strong(context)),
                          ),
                          ClubShield(club: row.club),
                        ],
                      ),
                    ),
                    title: Text(row.club.name, style: AppText.strong(context)),
                    subtitle: Text(
                      'PJ ${row.played} · ${row.won}V ${row.drawn}E ${row.lost}D',
                      style: AppText.muted(context),
                    ),
                    trailing: Text('${row.points}',
                        style: AppText.number(context, size: 18)),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text('Escudos provisorios', style: AppText.section(context)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final club in data.clubs) ClubShield(club: club, size: 40),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text('Esqueleto de carga', style: AppText.section(context)),
          ),
          const SkeletonList(rows: 2),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}
