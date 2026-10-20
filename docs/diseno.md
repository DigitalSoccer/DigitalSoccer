# Diseño de la app ANFA Caupolicán (PMV)

Documento de traspaso entre el mockup y la app en Flutter. Referencia visual: carpeta `mockup/` (archivos `.dc.html`, un archivo por pantalla). Los archivos con sufijo `-oscuro` son la versión en modo oscuro de cada pantalla; los demás, la versión clara. Los archivos HTML sirven para leer colores, medidas y textos; no se ejecutan dentro de Flutter.

**Datos reales en el mockup:** los 17 clubes de la ANFA Caupolicán y los puntos de cada serie (planilla entregada por el equipo del proyecto, ver sección 12). **Datos de ejemplo:** fixture, horarios, canchas, noticias y plantel.

---

## 1. Principios

1. Cero fricción para el hincha: sin registro, y en pocos segundos ve su posición y cuándo juega.
2. La **serie** es el eje de todo. Un club tiene equipos en varias series, y puntos y posición pertenecen al **equipo** (club + serie), no al club.
3. El **fixture se consulta solo en la pestaña Fixture**. El Inicio apenas muestra el próximo partido en una línea.
4. Se diseña para dos usuarios: el hincha joven y el dirigente mayor. Letra legible, objetivos táctiles de al menos 44 px.
5. Preparado para crecer: el jugador será una entidad propia (perfiles a futuro) y los datos no deben quedar escritos dentro de las pantallas.

## 2. Estructura de navegación

Barra inferior con 5 pestañas, en este orden:

| # | Pestaña | Pantalla |
|---|---------|----------|
| 1 | Inicio | `Inicio.dc.html` |
| 2 | Fixture | `Fixture.dc.html` |
| 3 | Tabla | `Tabla.dc.html` |
| 4 | Noticias | `Noticias.dc.html` |
| 5 | Clubes | `Clubes.dc.html` (lista) → `Club.dc.html` (ficha) |

Pantallas fuera de la barra:
- **Elegir equipo** (`Main.dc.html`): solo la primera vez. Club con buscador y luego serie. Incluye "Solo quiero mirar".
- **Ajustes** (`Ajustes.dc.html`): se abre con el ícono de ajustes del Inicio. Contiene la elección de apariencia (claro, oscuro o automático) y el acceso a cambiar de equipo (ver 6.8).
- **Panel directiva / turno** (`Admin.dc.html`): **no se implementa todavía** (ver sección 8).

La **serie seleccionada** y el **equipo elegido** se mantienen en todas las pantallas y se guardan en el teléfono (por ejemplo con `shared_preferences`).

## 3. Colores

Rojo de marca (valor de referencia; confirmar con el rojo real del proyecto y cambiarlo en un solo lugar).

| Token | Valor | Uso |
|-------|-------|-----|
| primary | `#B3202A` | Botones, chip seleccionado, pestaña activa, tarjeta de posición |
| primaryDark | `#7A1219` | Encabezado del panel directiva |
| onPrimary | `#FFFFFF` | Texto sobre primary |
| onPrimaryMuted | `#F8D4D6` | Textos secundarios sobre primary |
| onPrimaryLine | `#D0505A` | Líneas divisorias sobre primary |
| primaryTint | `#FBE9EA` | Fondo suave de selección |
| primaryTint2 | `#F6DADC` | Fondo de miniatura de noticias |
| background | `#F6F3F2` | Fondo de pantalla |
| surface | `#FFFFFF` | Tarjetas |
| ink | `#1A1112` | Texto principal |
| muted | `#625857` | Texto secundario |
| line | `#E5DEDD` | Bordes de tarjetas |
| lineSoft | `#F1ECEB` | Separadores dentro de tarjetas, encabezado de tabla |
| border | `#D2C9C8` | Bordes de campos y chips no seleccionados |
| accent | `#F5C400` | Posición en tarjeta roja, escudo de Los Aromos |
| ownTeamHighlight | `#FDF3C4` | Fila o tarjeta del equipo del usuario (borde `#E5CF73` en leyenda) |
| noticeBg / noticeText | `#FDEBD9` / `#8A3A00` | Avisos y estado Suspendido |
| noticeBody | `#4A3019` | Cuerpo del aviso fijado |
| tagNeutralBg / tagNeutralText | `#F1ECEB` / `#4A3F3E` | Estado "Programado" |

Colores de escudo de ejemplo (círculo con iniciales). Los reales se reemplazan por los logos de cada club cuando existan.

| Club | Iniciales | Fondo | Texto |
|------|-----------|-------|-------|
| A. Prat | AP | `#0F766E` | blanco |
| Bdo. O'Higgins | BO | `#1E40AF` | blanco |
| Chiguayante Sur | CS | `#0E7490` | blanco |
| El Tigre | ET | `#A16207` | blanco |
| El Valle | EV | `#4D7C0F` | blanco |
| Ferrobadminton | FB | `#374151` | blanco |
| Independiente | IN | `#86198F` | blanco |
| Jackson | JA | `#9A3412` | blanco |
| Leinenweber | LE | `#BE185D` | blanco |
| Maestranza | ME | `#3730A3` | blanco |
| Magallanes | MG | `#166534` | blanco |
| Nacional | NA | `#92400E` | blanco |
| San Pablo | SP | `#0369A1` | blanco |
| Shaub F.C. | SF | `#57534E` | blanco |
| U.L. Bolzhauser | UB | `#7E22CE` | blanco |
| U.L. Carrera | UC | `#1F2937` | blanco |
| Unión Angamos | UA | `#B45309` | blanco |

Los colores son provisorios: no son los colores reales de cada club. Las iniciales no se repiten entre los 17 clubes.

Cuidado: un escudo rojo se parece al color de marca. Revisarlo con los logos reales.

### Modo oscuro

La app tiene dos temas, claro y oscuro, y el usuario elige entre **Automático** (sigue el modo del teléfono, es el valor por defecto), **Claro** y **Oscuro** (ver 6.8). La referencia visual del modo oscuro son los archivos `*-oscuro.dc.html`. Mismos tokens, con estos valores:

| Token | Claro | Oscuro |
|-------|-------|--------|
| background | `#F6F3F2` | `#14100F` |
| surface (tarjetas, barra inferior, campos) | `#FFFFFF` | `#1F1918` |
| ink | `#1A1112` | `#F4ECEA` |
| muted | `#625857` | `#B3A6A4` |
| line | `#E5DEDD` | `#3A302F` |
| lineSoft | `#F1ECEB` | `#2A2221` |
| border | `#D2C9C8` | `#4A3F3E` |
| primary (fondo de botones, chips, tarjeta de posición) | `#B3202A` | `#B3202A` (igual) |
| primary usado como **texto o ícono** (enlaces, pestaña activa, check) | `#B3202A` | `#FF7A82` |
| primaryTint (fila seleccionada) | `#FBE9EA` | `#3A1A1D` |
| primaryTint2 (miniatura de noticias) | `#F6DADC` | `#4A2023` |
| ownTeamHighlight | `#FDF3C4` | `#3D3410` (borde `#E5CF73` → `#7A6A1F`) |
| noticeBg | `#FDEBD9` | `#3A2414` |
| noticeText | `#8A3A00` | `#FFB27A` |
| noticeBody | `#4A3019` | `#F2D3BC` |
| noticeMeta (fecha del aviso) | `#6E4A2B` | `#E0B999` |
| tagNeutralText | `#4A3F3E` | `#D8CCCA` |
| perilla del interruptor | `#FFFFFF` | `#F4ECEA` |

Sin cambios entre temas: `onPrimary` (`#FFFFFF`), `onPrimaryMuted`, `onPrimaryLine`, `primaryDark`, `accent` (amarillo) y los colores de escudo, con una excepción: en oscuro se aclaran tres escudos que casi no se veían (U.L. Carrera `#1F2937` → `#475569`, Ferrobadminton `#374151` → `#6B7280`, Shaub F.C. `#57534E` → `#78716C`).

Regla importante: **el rojo sobre fondo oscuro como texto no contrasta**, por eso se usa `#FF7A82` para texto e íconos y se mantiene `#B3202A` solo como fondo con texto blanco encima.

## 4. Tipografía

Google Fonts (en Flutter, paquete `google_fonts`):
- **Barlow Condensed** (600, 700): títulos, números grandes, horas, nombres de sección.
- **Barlow** (400, 500, 600, 700): cuerpo, etiquetas, botones.

| Uso | Fuente | Tamaño | Peso |
|-----|--------|--------|------|
| Título de pantalla | Barlow Condensed | 36 (pantalla de elegir equipo: 44) | 700 |
| Posición en tarjeta del Inicio | Barlow Condensed | 76 | 700 |
| Puntos en tarjeta del Inicio | Barlow Condensed | 48 | 700 |
| Hora del partido | Barlow Condensed | 28 | 700 |
| Marcador en panel | Barlow Condensed | 56 | 700 |
| Título de sección / tarjeta | Barlow Condensed | 22 a 26 | 700 |
| Texto de cuerpo y filas | Barlow | 15 | 400 a 600 |
| Texto secundario | Barlow | 13 a 14 | 400 |
| Etiquetas en mayúscula | Barlow | 12 a 13, espaciado 0.06em | 700 |
| Estados (píldoras) | Barlow | 12 | 700 |

Los números de tabla usan cifras tabulares.

## 5. Medidas y componentes

- Marco de referencia: **390 × 844**.
- Margen lateral de pantalla: **20**.
- Radios: tarjetas 14 a 18, tarjeta de posición 20, chips y botones circulares totalmente redondos, botón principal 14, campos 12.
- Objetivo táctil mínimo: **44**.
- Barra inferior: alto **72**, fondo blanco, borde superior `line`. Cada pestaña muestra una barra de 28×3 arriba (solo la activa), ícono 24 y etiqueta de 12. Activa: color primary y peso 700. Inactiva: muted.
- Íconos de trazo (stroke 2, esquinas redondeadas). Rutas SVG en cada archivo del mockup, dentro del arreglo `T`.

**Componentes que se repiten (conviene hacerlos widgets propios):**
1. `SerieChips`: fila con scroll horizontal, chips de 44 de alto. Seleccionado: fondo primary, texto blanco. No seleccionado: blanco con borde `border`.
2. `ClubShield`: círculo con iniciales (28 a 92 según el contexto), con respaldo cuando no hay logo.
3. `MatchCard`: hora a la izquierda, separador vertical, dos filas (escudo + nombre), pie con cancha y estado.
4. `StandingsRow`: posición, escudo, nombre, PJ, PG, PE, PP, DG, Pts.
5. `NewsCard`: etiqueta de tipo, fecha, título, extracto y miniatura opcional de 76.
6. `AppBottomNav`: la barra de 5 pestañas.
7. `SectionHeader`: título en Barlow Condensed y enlace "Ver todas" o "Ver completa".

## 6. Pantallas

### 6.1 Elegir equipo (solo primera vez)
- Eyebrow "ANFA Caupolicán · Chiguayante", título "¿Cuál es tu equipo?", subtítulo breve.
- Campo de búsqueda y lista de clubes con escudo; el elegido se marca con un check.
- Selector de serie con chips.
- Botón "Continuar" y enlace "Solo quiero mirar".
- Se puede volver a esta pantalla desde el botón de cambiar equipo del Inicio. Se debe poder seguir más de un equipo.

### 6.2 Inicio
De arriba abajo:
1. Escudo, nombre del club, "ANFA Caupolicán", botón de ajustes (lleva a Ajustes) y botón para cambiar de equipo.
2. `SerieChips` (recuerda la última serie).
3. **Tarjeta roja de posición**: "Posición · [serie]", posición grande en amarillo con "de 17 equipos", puntos a la derecha, y debajo "A N puntos del líder" y "A N puntos del 3°" (se calculan con los puntos; no dependen de PJ ni DG, que aún no tenemos).
4. **Línea del próximo partido** (tarjeta blanca, lleva al Fixture): "Próximo partido" y "vs Rival · Sáb 24, 16:00".
5. **Mini tabla**: tres filas (equipo del usuario al medio con la fila de arriba y la de abajo), columnas #, Club, Pts, y enlace "Ver completa" hacia la Tabla. Con empates, los clubes comparten número de posición.
6. **Últimas noticias**: aviso fijado (fondo naranja suave) y una noticia más; "Ver todas" lleva a Noticias.

### 6.3 Fixture
- Búsqueda por club, `SerieChips`.
- Selector de **fecha del campeonato** con flechas ("Fecha 6", "Sáb 24 – Dom 25 de octubre").
- Tarjeta **"Turno de la fecha"**: con 17 clubes, uno descansa cada fecha. Ese club se llama **turno**, y es quien anota los resultados de esa jornada. La tarjeta muestra su nombre y "Descansa y anota los resultados". Son 8 partidos por fecha.
- Interruptor "Solo mis partidos" (apagado por defecto).
- Partidos agrupados por día ("Sábado 24", "Domingo 25") y **ordenados por hora**.
- Cada `MatchCard` muestra los dos equipos, la cancha y un estado: Programado, Tu equipo (con fondo `ownTeamHighlight`) o Suspendido (con colores de aviso). En partidos jugados se muestra el marcador (no está dibujado en el mockup).

### 6.4 Tabla
- Título "Tabla de posiciones", subtítulo "Campeonato 2026 · después de la fecha N".
- `SerieChips`.
- Columnas por ahora: #, Club, Pts. Es lo único que entrega la planilla actual. Cuando la ANFA entregue PJ, PG, PE, PP, GF, GC y DG, se agregan (pensar scroll horizontal o ficha del club para las que no caben).
- 17 filas: la lista hace scroll. Fila del equipo del usuario resaltada con `ownTeamHighlight`. Tocar una fila abre la ficha del club.
- **Empates:** los clubes con los mismos puntos comparten número de posición (1, 2, 3, 4, 5, 5, 7...). El orden dentro del empate y el desempate **deben seguir el reglamento de la ANFA** (pendiente de confirmar).

### 6.5 Noticias
- Filtros por tipo: Todas, Avisos, Resúmenes, Previas, Asociación.
- Línea "Serie: Todas / Cambiar".
- Aviso fijado arriba (fondo `noticeBg`) y luego tarjetas de noticias.
- Tipos: Aviso, Resumen de la fecha, Previa de la fecha, Asociación.

### 6.6 Clubes
- Título con conteo, búsqueda y lista con escudo de 44, nombre y "Plantel y partidos". El club del usuario aparece resaltado.

### 6.7 Ficha del club
- Botón de volver, escudo grande (92), nombre, `SerieChips`.
- Tres tarjetas: Posición, Puntos y "Del líder" (diferencia de puntos con el primero). GF y GC se agregan cuando existan los datos.
- "Próximos partidos" con día, rival, hora, cancha y fecha del campeonato.
- "Plantel" con dorsal, nombre y posición. En el mockup los nombres están como `[Nombre jugador]`.

### 6.8 Ajustes
- Botón de volver, título "Ajustes".
- Sección **Apariencia** ("Elige cómo quieres ver la app"): tres opciones tipo radio, cada una con ícono, título y descripción:
  - **Automático**: "Sigue el modo de tu teléfono" (valor por defecto).
  - **Claro**: "Fondo claro, ideal de día y al sol".
  - **Oscuro**: "Fondo oscuro, más cómodo de noche".
- Nota: "Tu elección se guarda en este teléfono."
- Sección **Mi equipo**: fila con escudo, nombre del club y serie ("1ª Adulta · Cambiar"), que lleva a la pantalla de elegir equipo.
- En el mockup, la opción que se muestra marcada depende de la versión (la clara parte en "Claro" y la oscura en "Oscuro") y cambiar de una a otra navega entre las dos versiones. En la app real no hay dos versiones de cada pantalla: es **un solo conjunto de pantallas** que lee los colores del tema activo.

## 7. Estados que el mockup no dibuja y hay que resolver

- Carga de datos y error de conexión.
- Serie sin partidos o sin noticias (estado vacío).
- Club sin logo (usa iniciales y color).
- Partido jugado (marcador), en juego y postergado.
- Fecha sin partidos.

## 8. Fuera del alcance de esta primera etapa

- **Panel del turno / directiva**: depende de la API y de saber qué anotan los turnos hoy en su hoja de papel. El mockup `Admin.dc.html` es solo una idea inicial.
  - **El turno es un club, no una persona**: es el club que descansa en cada fecha y que anota los resultados de esa jornada. Por lo tanto el permiso de cargar resultados **rota por fecha** según el fixture, y hay que decidir quién del club tiene acceso (un delegado).
  - Notas para cuando se haga: la directiva puede editar todo, el turno solo los partidos de su jornada; ver primero los partidos del día; funcionamiento sin internet con envío posterior; registro de quién corrige qué; ingreso simple sin contraseñas complicadas.
- Goleadores, tarjetas y suspensiones, alineaciones.
- Perfiles de jugador y habilidades.
- App de partidos entre amigos.
- Pagos.

## 9. Datos: cómo preparar las pantallas para MongoDB

Hoy los datos están en JSON local. Las pantallas **no deben leer el JSON directamente**. Crear una capa (por ejemplo un repositorio por entidad) que hoy lea el JSON y mañana llame a la API. Modelo provisional:

- **Club**: id, nombre, iniciales, color, logo (opcional).
- **Serie**: id, nombre (Honor, Primera Adulta, Segunda Adulta, Senior, Infantil...).
- **Equipo**: id, club, serie. **Aquí viven los puntos y la posición.** Un club no necesariamente tiene equipo en todas las series (ver sección 12, hay ceros por confirmar).
- **Partido**: id, serie, fecha del campeonato, día y hora, cancha, equipo local, equipo visitante, goles, estado (programado, jugado, suspendido, postergado).
- **Cancha**: id, nombre.
- **Fecha del campeonato**: número, serie, día(s), club en turno (el que descansa).
- **Noticia**: id, título, cuerpo, tipo, serie (opcional), imagen (opcional), fijada, fecha de publicación.
- **Jugador**: entidad propia, con id propio y separado de "usuario". Se asocia a equipo y temporada, no se guarda dentro del equipo. Dejarlo así aunque el PMV solo muestre nombre y dorsal.

La **tabla de posiciones se calcula a partir de los partidos jugados**, no se escribe a mano.

## 10. Orden sugerido de implementación

1. Tema: colores, tipografías y barra inferior de 5 pestañas, con `lib/theme/` (colores y estilos de texto). Dos temas, claro y oscuro, con los valores de la tabla de modo oscuro de la sección 3. Notas para Flutter:
   - Definir `ThemeData` claro y oscuro, y pasar `themeMode` (`ThemeMode.system`, `light` o `dark`) a `MaterialApp`.
   - Los tokens que Material no cubre (ownTeamHighlight, notice*, primaryTint, texto de rojo claro) van en una `ThemeExtension`, con valores para cada tema.
   - **Ningún widget debe tener colores escritos a mano**: todo sale del tema. Así el cambio claro/oscuro funciona solo.
   - Guardar la elección (sistema, claro u oscuro) con `shared_preferences` y leerla al arrancar. Por defecto, sistema.
   - Pantalla de Ajustes con el selector (ver 6.8).
2. Capa de datos (repositorios) leyendo el JSON actual.
3. Widgets reutilizables (sección 5).
4. Pantallas: Tabla, Fixture, Inicio, Noticias, Clubes y ficha, Elegir equipo.
5. Estados vacíos, de carga y de error.
6. Revisión pantalla por pantalla contra el mockup y `flutter analyze`.

## 11. Prompt sugerido para Claude Code

> Lee `docs/diseno.md` y los archivos de `docs/mockup/`. Quiero que rediseñemos la app para que quede como ese mockup, pero **por etapas y sin romper lo que funciona**. Trabaja en una rama nueva. Empieza solo por el paso 1 (tema claro y oscuro con el selector de apariencia, y navegación de 5 pestañas) y detente para que yo revise. No implementes el panel admin. No leas el JSON desde las pantallas: usa una capa de repositorios. Corre `flutter analyze` antes de terminar cada paso. Los datos reales para precargar están en la sección 12 de `docs/diseno.md`.

## 12. Datos reales entregados (puntos por serie)

Planilla actual de la ANFA Caupolicán. Son **solo puntos**: aún no hay PJ, PG, PE, PP, GF, GC ni DG. Nombres con la mayúscula normalizada (el original venía en mayúsculas): "BDO. O'HIGGINS" se muestra como "Bdo. O'Higgins"; confirmar la forma oficial.

| Club | 1ª Adulta | 2ª Adulta | Senior | Honor |
|------|-----------|-----------|--------|-------|
| Bdo. O'Higgins | 36 | 31 | 43 | 34 |
| El Valle | 35 | 24 | 15 | 0 |
| Chiguayante Sur | 44 | 29 | 50 | 47 |
| El Tigre | 19 | 17 | 0 | 0 |
| Ferrobadminton | 9 | 37 | 48 | 3 |
| Independiente | 28 | 28 | 35 | 0 |
| Jackson | 30 | 23 | 33 | 10 |
| Leinenweber | 10 | 39 | 38 | 0 |
| Maestranza | 6 | 45 | 36 | 22 |
| Magallanes | 34 | 47 | 15 | 37 |
| Nacional | 20 | 6 | 30 | 27 |
| San Pablo | 35 | 20 | 31 | 34 |
| Shaub F.C. | 6 | 17 | 3 | 0 |
| Unión Angamos | 37 | 30 | 12 | 33 |
| U.L. Carrera | 49 | 9 | 24 | 0 |
| U.L. Bolzhauser | 28 | 8 | 10 | 0 |
| A. Prat | 14 | 21 | 19 | 4 |

**Pendientes de confirmar con la ANFA:**
- **Los ceros.** Hay 7 clubes con 0 en Honor y uno con 0 en Senior. No se sabe si significa "no tiene equipo en esa serie" o "tiene equipo con cero puntos". Cambia lo que debe mostrar la tabla (¿se listan o se ocultan?). El mockup solo dibuja 1ª Adulta.
- **Series infantiles:** no vienen en la planilla.
- **Desempates y orden dentro de un empate:** hay empates (por ejemplo, en 1ª Adulta: El Valle y San Pablo con 35, Independiente y U.L. Bolzhauser con 28, Maestranza y Shaub F.C. con 6).
- **Turno:** confirmar que el club que descansa cada fecha es el mismo que anota los resultados, y cómo se asigna la rotación.
