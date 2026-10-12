# Diseño visual

> **Importante:** la paleta gris azulada y blanca es la dirección visual acordada por el equipo
> (2026-10-12). **No** son colores oficiales del Club Arturo Prat ni de ANFA Chiguayante. Escudo, colores
> y recursos de marca deben verificarse y autorizarse antes de considerarse definitivos.

## Referencia

Se pidió basarse en una "primera propuesta visual" previa, pero no existe en el repositorio, en
`docs/` ni en la carpeta del plan (no hay imágenes ni maquetas). El diseño se construyó a partir de la
descripción escrita: gris azulado claro como identidad, fondo blanco, grises suaves para separar
superficies y texto gris azulado oscuro.

## Dónde está

| Archivo | Contenido |
|---|---|
| `lib/theme/app_theme.dart` | `AppColors`, `AppSpacing`, `AppRadius` y `buildAppTheme()` con los temas de cada componente Material |
| `lib/widgets/app_components.dart` | `ClubAvatar`, `StatTile`, `PositionBadge`, `MatchStatusBadge`, `SectionHeader`, `ContentWidth` |
| `lib/widgets/async_views.dart` | `LoadingView`, `ErrorView`, `EmptyView`, `AsyncBody` |

**Regla:** las pantallas no usan colores directos (`Colors.red`, `Color(0x…)`). Usan `AppColors` o
`Theme.of(context).colorScheme`.

## Paleta

| Token | Color | Uso |
|---|---|---|
| `brand` | `#8FA3B8` | Gris azulado claro de identidad: acentos, barra de estado "normal", borde del club favorito. No lleva texto encima |
| `primary` | `#48607A` | Elementos interactivos, pestaña seleccionada, horas, puntos, botones |
| `primaryContainer` | `#E1E8EF` | Indicador de navegación, cabecera de Mi Club, fondos de íconos |
| `background` | `#FFFFFF` | Fondo predominante y tarjetas |
| `surfaceLow` / `surfaceMid` / `surfaceHigh` | `#F5F7F9` / `#EEF2F5` / `#E6EBF0` | Buscador, encabezado de tabla, chips, insignias |
| `border` | `#DCE2E8` | Bordes de tarjetas y separadores |
| `text` / `textMuted` | `#1F2A37` / `#5A6776` | Texto principal / secundario |
| `error` | `#B4443C` | Errores y partidos suspendidos |
| `statusRescheduled` | `#A86A12` | Partidos reprogramados |
| `favorite` | `#B8860B` | Estrella de favorito |

Contraste: los pares de texto y fondo cumplen WCAG AA (≥ 4.5:1). Hay una prueba automática
(`test/widget_test.dart`) que lo verifica si alguien cambia la paleta.

## Criterios

- Tarjetas planas (elevación 0) con borde gris suave y radio de 12 px.
- Espaciado en múltiplos de 4 (`AppSpacing`: 4, 8, 12, 16, 24).
- Tipografía del sistema (Roboto en Android/web), sin dependencias nuevas.
- En pantallas anchas el contenido se limita a 720 px y se centra (`ContentWidth`).
- Sin escudos: `ClubAvatar` es un ícono genérico de escudo de Material, marcado como "sin escudo".
- Las medallas emoji de la tabla se reemplazaron por insignias de posición: además, los emojis no se
  veían en la versión web sin conexión.

## Fixture (por cruce)

- Encabezado de fecha con flechas para cambiar de fecha y enlace al origen de los datos.
- Pestañas por día y filtro por serie.
- Una tarjeta "clásica" por cruce (local vs visita del día): cancha(s) arriba, equipos a los lados
  con ícono genérico y, al centro, la hora del primer partido y la cantidad de partidos. Abajo, las
  series. No hay marcador porque aún no se cargan resultados.
- Al tocarla, la pantalla "Partido" muestra el cruce y, por cancha, los horarios de cada serie hacia
  abajo (con favorito por partido). Siempre muestra todas las series, aunque la lista esté filtrada.
- Aviso "Libre: …" al final del día. Mi Club: borde `primary` e insignia "MI CLUB".
- Los turnos se guardan en los datos, pero no se muestran en la lista.

## Pendiente de decisión

- Escudo y colores oficiales del club (Roberto, con el club).
- Pantalla de inicio específica de Arturo Prat (ver propuesta en el informe de la tarea): no se
  construyó para no ampliar el alcance sin aprobación.
