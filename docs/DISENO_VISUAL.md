# Diseño visual

> **Importante:** la paleta azul (base `#205375`) y blanca es la dirección visual acordada por el equipo
> (2026-10-12, cambiada a azul el 2026-10-15). **No** son colores oficiales del Club Arturo Prat ni de ANFA Chiguayante. Escudo, colores
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
| `brand` | `#5E8DB5` | Azul claro de acento: acentos, barra de estado "normal", borde del club favorito. No lleva texto encima |
| `primary` | `#205375` | Barra superior, bloque azul de Inicio, elementos interactivos, pestaña seleccionada, horas, puntos, botones |
| `primaryContainer` | `#DDE9F3` | Indicador de navegación, texto suave sobre azul, fondos de íconos |
| `background` | `#FFFFFF` | Fondo predominante y tarjetas |
| `surfaceLow` / `surfaceMid` / `surfaceHigh` | `#F5F8FB` / `#ECF2F7` / `#E2EAF2` | Buscador, encabezado de tabla, chips, insignias |
| `border` | `#D5DFE8` | Bordes de tarjetas y separadores |
| `text` / `textMuted` | `#15293A` / `#4F6275` | Texto principal / secundario (azul marino) |
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

- **Inicio sin club elegido:** bloque azul de bienvenida (centrado) y lista de clubes para elegir.
- Títulos de la barra superior centrados en todas las pantallas.
- **Inicio con club:** bloque azul con el club centrado y botón "Cambiar" (abre la lista en una hoja inferior),
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
- **Menú desplegable "Tabla"** arriba (2026-10-15): "Tabla general" (por defecto) y "Serie …" para
  cada serie del fixture, de menor a mayor. Sin datos de una serie: "La tabla de <serie> aún no está
  disponible." Título de la pantalla: "Tabla de posiciones".
