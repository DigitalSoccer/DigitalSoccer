import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_components.dart';
import '../widgets/async_views.dart';
import '../widgets/serie_chips.dart';

/// Pestaña Noticias. Aún no hay una fuente de noticias: se muestran los
/// filtros por tipo del mockup y un estado vacío. Las noticias del mockup
/// son de ejemplo y no se cargan en la app.
class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  static const List<String> types = [
    'Todas',
    'Avisos',
    'Resúmenes',
    'Previas',
    'Asociación',
  ];

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  String _type = NewsPage.types.first;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: [
          ContentWidth(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.lg,
                AppSpacing.screen,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      'Noticias',
                      style: AppText.display(context, size: 36),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Lo que pasa en la ANFA Caupolicán',
                    style: TextStyle(fontSize: 14, color: c.textMuted),
                  ),
                ],
              ),
            ),
          ),
          PillChips(
            options: NewsPage.types,
            selected: _type,
            onSelected: (type) => setState(() => _type = type),
          ),
          const SizedBox(height: AppSpacing.xxl),
          EmptyView(
            icon: Icons.newspaper_outlined,
            message: _type == NewsPage.types.first
                ? 'Aún no hay noticias publicadas.'
                : 'Aún no hay noticias de tipo "$_type".',
          ),
        ],
      ),
    );
  }
}
