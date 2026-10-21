# Diseño visual

> **Importante:** el sistema rojo deportivo (`#B91C1C`) sobre superficies blancas y fondo slate es la
> dirección visual en revisión (rama `feature/sistema-diseno-rojo`, 2026-10-18; antes: azul `#205375`).
> **No** son colores oficiales del Club Arturo Prat ni de ANFA Chiguayante. Escudo, colores y recursos
> de marca deben verificarse y autorizarse antes de considerarse definitivos.

## Referencia

El sistema sigue un brief escrito con tokens estilo Tailwind (rojo `#B91C1C`/`#DC2626`, fondo
`#F8FAFC`, tarjetas blancas con `border-slate-100` y `shadow-sm`/`shadow-md`, Inter o Roboto). Aquí se
traducen a Flutter: cada token de Tailwind tiene su equivalente en `lib/theme/app_theme.dart`.

## Dónde está

| Archivo | Contenido |
|---|---|
| `lib/theme/app_theme.dart` | Tokens: `AppColors`, `AppSpacing`, `AppRadius`, `AppShadows`, `AppText` y `buildAppTheme()` con los temas de cada componente Material |
| `lib/widgets/app_components.dart` | Primitivas (`ClubAvatar`, `PositionBadge`, `MatchStatusBadge`, `TagChip`, `SectionHeader`, `GroupLabel`, `CircleIconButton`, `ContentWidth`, `DisciplineCard`). Además reexporta los módulos de abajo: las pantallas importan solo este archivo |
| `lib/widgets/surface_card.dart` | `SurfaceCard`: tarjeta blanca con borde suave, `rounded-2xl` y sombra difusa (reemplaza a `Card`) |
| `lib/widgets/segmented_tab_bar.dart` | `SegmentedTabBar`: pestañas píldora (ficha del club y días del fixture) |
| `lib/widgets/stats_card.dart` | `StatTile` y `StatsCard` (tarjeta de métricas POSICIÓN · PUNTOS) |
| `lib/widgets/app_bottom_sheet.dart` | `showAppBottomSheet`, `showSelectionSheet`, `SheetOptionTile` y `SelectorField` (campo que abre la hoja) |
| `lib/widgets/info_banner.dart` | `InfoBanner`: avisos en línea (club libre, sin fechas futuras) |
| `lib/widgets/club_tile.dart` | `ClubTile`, `FieldLabel` y `FavoriteStarButton` |
| `lib/widgets/club_header.dart` | `ClubHeroHeader`: encabezado de club con tarjeta flotante (Inicio y ficha) |
| `lib/widgets/async_views.dart` | `LoadingView`, `ErrorView`, `EmptyView`, `AsyncBody` |

**Regla:** las pantallas no usan colores directos (`Colors.red`, `Color(0x…)`). Usan `AppColors` o
`Theme.of(context).colorScheme`.

## Paleta

| Token | Color | Tailwind | Uso |
|---|---|---|---|
| `primary` | `#B91C1C` | red-700 | Elementos interactivos, ítem activo de la navegación, "FECHA 21", borde e insignia de Mi Club |
| `primaryBright` | `#DC2626` | red-600 | Solo acentos sin texto: franja de Mi Club en la tabla |
| `primaryContainer` / `primarySoft` | `#FEE2E2` / `#FEF2F2` | red-100 / red-50 | Insignia MI CLUB / fila de Mi Club, opción elegida, fondos de íconos |
| `navIndicator` | `#B91C1C` al 12 % | — | Píldora translúcida del ítem activo de la barra inferior |
| `background` | `#F8FAFC` | slate-50 | Fondo global de las pantallas, cabecera de la tabla, campos de texto |
| `surface` | `#FFFFFF` | white | Tarjetas, hojas inferiores, barra superior y encabezados |
| `surfaceMuted` | `#F1F5F9` | slate-100 | Pista de pestañas, avatares, chips, avisos |
| `border` / `borderStrong` | `#F1F5F9` / `#E2E8F0` | slate-100 / slate-200 | Borde de tarjetas y filas / campos y divisores |
| `text` | `#0F172A` | slate-900 | Títulos y texto principal |
| `textSecondary` | `#475569` | slate-600 | Subtítulos y texto sobre `surfaceMuted` |
| `textMuted` | `#64748B` | slate-500 | Etiquetas y metadatos. Solo sobre blanco o `background` |
| `outline` | `#94A3B8` | slate-400 | Íconos decorativos |
| `favorite` | `#F59E0B` | amber-500 | Estrella de Mi Club |
| `gold*` / `silver*` / `bronze*` | ámbar / slate / naranja | 100 + 800 | Píldoras del podio (1° a 3°) |
| `error` / `statusRescheduled` | `#B4443C` / `#B45309` | — | Partidos suspendidos / reprogramados |

Sombras (`AppShadows`): `sm` = `0 1px 2px` al 5 %; `md` = `0 4px 6px -1px` + `0 2px 4px -2px`,
teñidas con slate-900. Radios (`AppRadius`): 8, 12 (`rounded-xl`: campos y botones), 16
(`rounded-2xl`: tarjetas), 24 (hojas inferiores) y píldora.

Contraste: los pares de texto y fondo cumplen WCAG AA (≥ 4.5:1). Hay una prueba automática
(`test/widget_test.dart`) que lo verifica si alguien cambia la paleta.

## Criterios

- El rojo es puntual: navegación activa, acciones, Mi Club y la etiqueta de la fecha. Nunca es fondo de
  pantalla ni de barras. Los íconos de listas y estados vacíos son grises.
- Tarjetas blancas sobre fondo slate, con borde slate-100 y sombra difusa (`shadow-sm`; la tarjeta de
  métricas y el detalle del partido usan `shadow-md`).
- Tipografía: Roboto (sistema en Android y web), sin dependencias nuevas. Inter exigiría agregar
  `google_fonts` o empaquetar la fuente (ver DT-04). Títulos en negrita slate-900; etiquetas en
  mayúsculas `AppText.eyebrow` (12 px, w500, slate-500, espaciado 0.6).
- Espaciado en múltiplos de 4 (`AppSpacing`: 4, 8, 12, 16, 24, 32).
- En pantallas anchas el contenido se limita a 720 px y se centra (`ContentWidth`).
- Sin escudos: `ClubAvatar` es un ícono genérico de escudo de Material, marcado como "sin escudo".
- Las medallas emoji de la tabla se reemplazaron por insignias de posición: además, los emojis no se
  veían en la versión web sin conexión.

## Pantallas con el sistema rojo (2026-10-18)

- **Barra superior:** blanca y compacta (56 px), título centrado de 17 px y botón de retroceso en las
  pantallas secundarias. Muestra una sombra leve al desplazar el contenido.
- **Barra inferior:** blanca con sombra hacia arriba; el ítem activo lleva una píldora roja translúcida
  e ícono y etiqueta en rojo.
- **Inicio y ficha del club:** `ClubHeroHeader` con avatar, nombre y cancha sobre una banda blanca, y
  la tarjeta de POSICIÓN y PUNTOS montada entre la banda y el fondo. En la ficha siguen las pestañas
  píldora **Plantel** / **Próximas fechas**, fijas al desplazar.
- **Fixture:** panel blanco superior con el selector de fecha (flechas circulares, "FECHA 21" en rojo,
  rango y fuente), buscador `rounded-xl` y días en pestañas píldora. Tarjetas de cruce en tres columnas
  (local · hora y cantidad de partidos o estado · visita) y un chip gris con las series.
- **Tabla:** `SelectorField` en vez del menú desplegable; abre una hoja inferior deslizable con las
  secciones "General" y "Por serie". Columnas POS · CLUB · PJ · DIF · PTS; el podio en píldoras oro,
  plata y bronce, y la fila de Mi Club con fondo rojo suave, franja roja a la izquierda y estrella.
- **Clubes:** tarjetas con avatar circular, nombre en negrita, cancha con ícono de ubicación y la
  estrella de Mi Club (animada) a la derecha.

## Fixture (por cruce)

- Encabezado de fecha con flechas para cambiar de fecha y enlace al origen de los datos.
- Pestañas por día (sin filtro por serie: se quitó el 2026-10-15 a pedido de Diego).
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

## Navegación (2026-10-15)

Barra inferior: **Inicio · Fixture · Tabla · Clubes** (Inicio reemplaza a "Mi Club").

- **Inicio sin club elegido:** bienvenida centrada (2026-10-18: banda blanca con ícono rojo suave) y lista de clubes para elegir.
- Títulos de la barra superior centrados en todas las pantallas.
- **Inicio con club:** encabezado del club (2026-10-18: `ClubHeroHeader`) y botón "Cambiar" (abre la lista en una hoja inferior),
  posición y puntos, y los cruces del club en la fecha más reciente agrupados por día, con las mismas
  tarjetas clásicas del fixture. Si el club queda libre, se indica. Botón "Ver fixture completo".
- Las tarjetas abren la pantalla "Partido" (cancha y horarios por serie).

## Ficha del club (2026-10-15)

- Encabezado compacto: ícono genérico, nombre, cancha, estrella "Mi Club" y posición/puntos. Al
  desplazar se recoge y las pestañas quedan fijas arriba.
- Dos pestañas: **Plantel** y **Próximas fechas**.
  - **Plantel:** una fila desplegable por cada serie en que juega el club (según las fechas cargadas,
    de menor a mayor). Al abrirla, la tabla N° · Jugador · PJ · G · tarjeta amarilla · tarjeta roja
    (goles en azul), o "El plantel de <serie> aún no está disponible". Leyenda al final.
  - **Próximas fechas:** cruces del club en fechas desde hoy en adelante, con tarjetas clásicas que
    abren el detalle. Si no hay fechas futuras cargadas, muestra la última programada con un aviso.
    Si el club queda libre, se indica.
- Hoy no hay jugadores cargados. Colores de tarjetas en `AppColors.cardYellow` / `AppColors.cardRed`,
  componentes `DisciplineCard`, `SquadTable` y `SquadLegend`.

## Tabla general (2026-10-15)

- Columnas: **# · Club · PJ · DIF · PTS** (anchos fijos alineados entre encabezado y filas).
- PJ y DIF son opcionales en los datos (`played`, `goalDifference` en `standings.json`). La fuente
  actual solo trae puntos, así que se muestran como **"–"**. No se cargan valores inventados en la
  app; solo se simularon en una copia aparte para revisar el diseño.
- DIF se muestra con signo: `+5`, `0`, `-3`.
- **Selector "Tabla"** arriba (2026-10-15; desde 2026-10-18 abre una hoja inferior): "Tabla general" (por defecto) y "Serie …" para
  cada serie del fixture, de menor a mayor. Sin datos de una serie: "La tabla de <serie> aún no está
  disponible." Título de la pantalla: "Tabla de posiciones".
- **Datos oficiales (2026-10-18):** tabla general = Total acumulado de la planilla de la asociación;
  menú con "Acumulado infantil y juvenil", "Acumulado adultos" y las 10 series (incluida Femenina).
  Bajo el menú, la fuente y la advertencia "sujeta a modificaciones". Empates con posición compartida.

## Inicio estilo maqueta (2026-10-18)

Basado en la maqueta compartida por Diego ("Design 21"):

- **Barra superior roja** (`primary`) con título blanco de 19 px en todas las pantallas (antes blanca).
- **Inicio con club:** encabezado rojo con esquinas inferiores redondeadas y el panel **MI CLUB** en
  `primaryDeep` (#991B1B): escudo genérico sobre círculo blanco, nombre, cancha y botón píldora blanco
  "Cambiar". Debajo, **dos tarjetas** POSICIÓN y PUNTOS (cifras en rojo) montadas sobre el borde del rojo.
- **Tarjetas de partido** del club: día y "FECHA N" arriba, escudos rojos genéricos, hora al centro,
  cancha y series abajo. Abren el detalle.
- **Resumen de la tabla:** los 3 primeros y, si está más abajo, la fila de Mi Club (fondo rojo suave)
  tras "···"; "Ver tabla" abre la pestaña Tabla.
- **Barra inferior propia** (`AppBottomNav`): línea roja sobre el ítem activo, ícono y etiqueta en rojo.
- **Escudos:** `ClubCrest` es un escudo rojo **genérico**; la maqueta muestra escudos reales que no
  tenemos ni están autorizados. Es el lugar para poner el escudo de cada club cuando exista.
- **Tarjeta de partido común (2026-10-18):** el formato de Inicio (día y "FECHA N" arriba, escudos,
  hora al centro, cancha y series abajo) es ahora `MatchupCard` y se usa también en la pestaña
  Fixture y en "Próximas fechas" de la ficha del club. En el Fixture, el cruce de Mi Club lleva borde
  rojo e insignia "MI CLUB"; un partido suspendido o reprogramado muestra su estado bajo la hora.
- **Tabla:** cada fila lleva `ClubCrest` junto al nombre (genérico por ahora; ahí irá el escudo de
  cada club).

## Mockup nuevo — etapa 1 (2026-10-20)

Referencia: `docs/diseno.md` y `docs/mockup/`. Se adopta por etapas; los
datos de la app no cambian, solo lo visual.

Hecho en esta etapa:

- **Paleta nueva** rojo `#B3202A` sobre fondos cálidos (`#F6F3F2`), con
  **modo oscuro**. Los colores viven en `AppColors.light` / `AppColors.dark`
  (un `ThemeExtension`) y en el código se usan con `context.colors.x`, nunca
  con valores fijos. El contraste AA (4,5:1) se prueba para ambas paletas.
- **Tipografías** Barlow (texto) y Barlow Condensed (títulos y cifras),
  incluidas en `assets/fonts/` con su licencia OFL (no se descargan en
  tiempo de ejecución).
- **Escudos provisorios**: círculo de color con las iniciales del club
  (`InitialsShield`). Iniciales y colores vienen de `clubs.json`
  (`initials`, `color`, `colorDark`) y son los del mockup: **no son los
  colores oficiales** de cada club. Sin datos se muestra el escudo genérico.
- **Barra inferior de 5 pestañas**: Inicio · Fixture · Tabla · Noticias ·
  Clubes.
- **Noticias**: filtros por tipo y un estado vacío. Las noticias del mockup
  son de ejemplo y no se cargan.
- **Ajustes** (botón en Inicio): apariencia Automático / Claro / Oscuro
  (guardada en el teléfono; por defecto Automático) y "Mi equipo".

Pendiente (etapa 2, pantalla por pantalla): Inicio con chips de serie y
tarjeta de posición, Fixture, Tabla (#/Club/Pts con fila de mi equipo),
Clubes, Ficha y la pantalla "Elegir equipo". Los cruces de "Turno" de la
planilla se mostrarán como **Libre**, como en el mockup.

## Mockup nuevo — etapa 2: Inicio y Tabla (2026-10-20)

- **Inicio** sin barra superior, como el mockup: escudo, nombre del club,
  botones de Ajustes y de cambiar equipo; chips de serie; tarjeta roja de
  posición (puesto en amarillo, puntos y distancia al líder y al 3°, solo
  con puntos); una línea con el partido de la fecha (lleva al Fixture);
  mini tabla de 3 filas con el equipo al medio; "Últimas noticias" vacío.
  La línea dice "Tu partido · Fecha N" y no "Próximo partido", porque la
  fecha cargada puede ya haberse jugado.
- **Tabla** con título propio, chips y columnas #, Club, Pts (las que trae
  la planilla). Se quitan PJ y DIF, que solo mostraban guiones; vuelven
  cuando la ANFA entregue esos datos. Fila de mi equipo en amarillo
  (`ownTeam`) y tocar un club abre su ficha.
- Chips: General, series de mayor a menor y los acumulados ("Total
  adultos", "Total infantil y juvenil"). La elección se guarda y la
  comparten Inicio y Tabla.
- Las tablas se leen desde `StandingsCatalog` (capa de datos), no desde
  las pantallas.

## Mockup nuevo — etapa 2: Fixture, Clubes y Noticias (2026-10-21)

- **Sin barra superior**: cada pestaña lleva su título en Barlow Condensed
  (36), como el mockup.
- **Fixture**: buscador, selector de fecha con flechas (la fuente se
  explica al tocarlo), "Solo mis partidos" (si hay equipo elegido),
  tarjeta "Libre" y los cruces de **todos los días** de la fecha en una
  sola lista, agrupados por día y ordenados por hora.
  - Se mantiene la tarjeta **por cruce** (local contra visita, con todas
    sus series), que pidió el equipo; al tocarla se abre el detalle con
    canchas y horarios. La tarjeta sigue el `MatchCard` del mockup: hora a
    la izquierda, equipos con escudo, cancha y etiqueta (Tu equipo,
    Suspendido o "N partidos").
  - **Sin chips de serie** en el Fixture: el equipo pidió quitar el filtro
    por serie, y cada cruce ya agrupa todas las series.
  - El club que descansa se muestra como **Libre**, no como "Turno": la
    planilla no confirma que quien descansa sea quien anota resultados.
- **Clubes**: título con conteo, buscador y la lista en una tarjeta;
  mi equipo resaltado ("Tu equipo · Plantel y partidos"). La estrella para
  elegir equipo queda en la ficha del club, en Inicio y en Ajustes.
- **Noticias**: título y subtítulo del mockup.

## Chips de serie en toda la app y Elegir equipo (2026-10-21)

Pedido del equipo: los chips se ven bien y hacen más amigable la app.

- **Mismos chips en Inicio, Fixture y Tabla**, con la misma elección
  guardada: al elegir una serie en una pantalla, las otras abren en ella.
  Orden: series de mayor a menor, acumulados y **General al final** (sigue
  siendo la elegida por defecto). La fila se desplaza sola hasta el chip
  elegido.
- **Fixture con chips** (reemplaza la decisión anterior de no tenerlos):
  con una serie, cada cruce muestra solo ese partido (su hora y su serie
  en la etiqueta); General y los acumulados muestran todas las series.
  La línea "Tu partido" de Inicio también sigue la serie elegida.
- **Elegir equipo** (`ChooseTeamPage`, `docs/mockup/Main.dc.html`): club
  con buscador y serie; "Continuar" guarda ambos. Aparece en Inicio la
  primera vez y se abre al cambiar de equipo (Inicio y Ajustes). "Solo
  quiero mirar" lleva al Fixture sin guardar equipo. Aún no se pueden
  seguir varios equipos (el mockup lo menciona; queda pendiente).
- Ajustes muestra "Mi equipo" con su serie ("Honor · Cambiar").
