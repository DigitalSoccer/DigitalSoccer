# Decisiones técnicas

Registro breve de decisiones. Estado: **Aprobada**, **Propuesta** (pendiente de revisión) o **Pendiente**.

## DT-01 — Alcance de la primera versión (Aprobada, 2026-10-12, Roberto)

App pública de consulta, centrada en el Club Arturo Prat de Chiguayante, con información de la
asociación cuando esté disponible y validada. Fuera de alcance por ahora: actas digitales, turnos,
autenticación y panel administrativo.

## DT-02 — Identificadores estables de club (Propuesta, 2026-10-12)

- Cada club tiene un `id` (`arturo-prat`, `bdo-ohiggins`, …) en `clubs.json`.
- `fixture.json` referencia a los equipos con `homeId`/`awayId`; `standings.json` con `clubId`.
- El código relaciona clubes, partidos y tabla **solo por id**. Los nombres son para mostrar.
- Los textos originales se conservan (`"A. Prat"`, `"Bdo. O’Higgins"` con apóstrofo tipográfico) para
  no alterar las fuentes. Se verificó que, quitando los ids, los JSON quedan idénticos al commit
  `3fdc296`.
- Supuesto: `"A. Prat"` en la tabla corresponde al club Arturo Prat (coincide con su `shortName`).
  Validar con la fuente.
- Excepción: `ClubService` compara por nombre solo para migrar el club favorito que antes se guardaba
  por nombre (`favorite_club` → `favorite_club_id`).

## DT-03 — Desempates en la tabla (Propuesta)

Se ordena por puntos y, con puntos iguales, se respeta el orden de la fuente. No se aplica ningún
desempate propio mientras no se conozcan las reglas oficiales del campeonato.

## DT-04 — Tema visual (Actualizada 2026-10-12)

Primero se corrigió el tema verde (`primarySwatch` se ignora en Material 3; por eso la app se veía
morada). Luego el equipo pidió una paleta **gris azulada y blanca**, implementada con un `ColorScheme`
explícito y tokens centralizados en `lib/theme/app_theme.dart`. No son colores oficiales. Detalle en
`DISENO_VISUAL.md`.

## DT-05 — Carga de datos y errores (Propuesta)

`loadJsonAsset` centraliza la lectura de JSON con tiempo límite (10 s) y convierte cualquier falla en
`DataLoadException`. Las pantallas usan `AsyncBody` (carga / error con "Reintentar" / contenido) y
`EmptyView` para ausencia de datos. Sin nuevas dependencias.

## DT-06 — Versión de Flutter del equipo (Pendiente, decide Diego)

El proyecto se creó con Flutter **3.35.7** (`.metadata`, revisión `adc9010`). En el PC de desarrollo
está instalada la **3.47.7**, con la que se ejecutaron todas las pruebas; usarla actualizó en
`pubspec.lock` 6 paquetes fijados por el SDK y agregó exclusiones en `analysis_options.yaml`.
Recomendación: adoptar 3.47.7 para todo el equipo, commitear esos dos archivos y fijar la versión
(en el README y, opcionalmente, con FVM y un archivo `.fvmrc`).

## DT-07 — Flujo de ramas y versiones (Aprobada, 2026-10-12)

- `main`: versión estable y validada. No se desarrolla directamente en ella.
- `develop`: integración del desarrollo. Las ramas de trabajo (`fix/…`, `feature/…`) salen de `develop`.
- `Release/01.00.01`: preparación de la versión 01.00.01, a partir de `develop` validado.
- Una versión pasa a `main` solo tras validación y autorización. Merges explícitos y revisables.
- El número de versión de `pubspec.yaml` (hoy `1.0.0+1`) **no se ha cambiado**. Pendiente decidir
  cómo se corresponde con el nombre de rama `01.00.01` (ver informe).

## DT-08 — Fixture con el formato de la planilla de la asociación (Propuesta, 2026-10-12)

- La programación oficial llega como planilla de la **Asociación de Fútbol Caupolicán de Chiguayante**:
  fecha → día con fecha → cancha → bloques separados por "TURNO:" → hora, cruce y serie, más "LIBRE:".
- El modelo agrega `date` y `libre` al día, `blocks`/`turno` a la cancha y `source` a la fecha. El
  formato anterior (`matches` sin bloques) sigue siendo válido.
- Se transcribió la **fecha 21** desde dos fotos. Las filas sin equipos se interpretaron como
  continuación del cruce anterior; queda pendiente validar la transcripción con el club.
- La pantalla de Fixture reproduce la planilla: selector de fecha, pestañas con día y fecha, una
  tarjeta por cancha siempre abierta, cruces agrupados con sus series, separadores de turno, aviso de
  club libre, filtro por serie y Mi Club resaltado.
- Detalle de carga de datos en `DATOS_FIXTURE.md`.
- **Actualización (mismo día, a pedido de Diego):** la lista del fixture pasó de "por cancha" a "por
  cruce", con tarjetas de estilo clásico (equipos a los lados, hora al centro) y una pantalla de
  detalle con la cancha y los horarios de cada serie. Los turnos siguen en los datos.

## DT-09 — Planteles por serie (Propuesta, 2026-10-15)

- Se prepara la estructura (modelo `Player`/`Squad`, `SquadService`, pantalla Plantel) sin datos reales.
- Estadísticas: partidos jugados, goles, amarillas y rojas: lo que registra el acta de un partido amateur.
- **Riesgo a resolver antes de cargar datos:** las series infantiles y juveniles son de **menores de
  edad**. Antes de publicar sus nombres hay que definir con Roberto y el club qué se muestra (por ejemplo,
  solo nombre e inicial del apellido, o nada en series infantiles) y contar con autorización. Con la API
  futura, esa regla puede aplicarse en el servidor según el rol de quien consulta.

## DT-10 — Tabla de posiciones desde el puntaje parcial oficial 2026 (Propuesta, 2026-10-18)

- La tabla general pasa a ser el **Total acumulado** de la planilla oficial de la asociación. Reemplaza
  los puntos anteriores de `standings.json` (p. ej. Chiguayante Sur 161), cuyo origen nunca se verificó
  y no coinciden con la planilla; siguen disponibles en el historial de Git.
- Se cargan las tablas de las 10 series (incluida **Femenina**, que no está en el fixture) y los dos
  subtotales. Menú: Tabla general, Acumulado infantil y juvenil, Acumulado adultos y cada serie.
- Empates: posición compartida. Se muestra la fuente y la advertencia oficial de la planilla.
