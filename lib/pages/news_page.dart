import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
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
    return ListView(
      padding: const EdgeInsets.only(
        top: AppSpacing.xs,
        bottom: AppSpacing.xl,
      ),
      children: [
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
    );
  }
}
