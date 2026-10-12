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

## DT-04 — Tema visual provisional (Propuesta)

`ColorScheme.fromSeed(seedColor: Colors.green)` en `lib/theme/app_theme.dart`. El verde **no** es un color
oficial confirmado del club ni de ANFA. El tema anterior usaba `primarySwatch`, que Material 3 ignora,
por eso la app se veía morada.

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
