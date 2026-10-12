# Pruebas

## Cómo ejecutarlas

```bash
flutter analyze
flutter test
```

## Suites

| Archivo | Qué cubre |
|---|---|
| `test/models_test.dart` | `Club`, `Match`, `FixtureRound`, `Standing`: lectura de JSON, ids obligatorios, `Match.involves`, orden de la tabla (empates conservan el orden de la fuente), `positionOf` |
| `test/club_relations_test.dart` | Integridad de los datos reales de `assets/data`: ids únicos, todo partido y fila de tabla apunta a un club existente; casos **Arturo Prat** (`A. Prat` en la tabla) y **Bdo. O'Higgins** (apóstrofo distinto) |
| `test/club_service_test.dart` | Club favorito guardado por id y migración del valor antiguo (guardado por nombre) |
| `test/asset_json_test.dart` | Errores de carga: archivo ausente, JSON mal formado, tipo de dato incorrecto, tiempo límite |
| `test/widget_test.dart` | Arranque de la app, paleta centralizada y contraste WCAG AA, ausencia de desbordes a 320 y 1280 px, detalle de club (posición/puntos), estados de error con reintento, JSON mal formado, tabla vacía, búsqueda sin resultados, Mi Club |
| `test/helpers/fake_asset_bundle.dart` | Utilidad: bundle de assets en memoria para inyectar datos reales, vacíos o con errores |

Las pantallas leen los datos desde `DefaultAssetBundle.of(context)`, por eso las pruebas pueden
envolverlas en un `DefaultAssetBundle` con datos controlados.

## Resultados

| Fecha | Flutter | Rama | `flutter analyze` | `flutter test` |
|---|---|---|---|---|
| 2026-10-12 | 3.47.7 (Dart 3.13.5) | `fix/identidad-clubes-pruebas-ui` | Sin problemas | **39 pasan, 0 fallan** |
| 2026-10-12 | 3.47.7 (Dart 3.13.5) | `feature/rediseno-visual` | Sin problemas | **44 pasan, 0 fallan** |

Las líneas `Error al cargar datos: DataLoadException(...)` que aparecen durante `flutter test` son
esperadas: las imprimen las pruebas que simulan errores de carga.

## Verificación manual realizada

- `flutter build web` y ejecución en navegador (375×812): tema verde aplicado; el detalle de
  Arturo Prat muestra "Posición: 17" y "Puntos: 42".
- Rediseño (`feature/rediseno-visual`): `flutter build web` correcto. Revisado en navegador: fixture
  (móvil y escritorio), filas de partido (móvil), tabla y clubes (escritorio). La ficha de club no se
  pudo revisar en el navegador porque el panel dejó de refrescarse; está cubierta por pruebas de widgets.
- **No verificado**: compilación y ejecución en Android/iOS.

## Pendiente de cubrir

- Pruebas en dispositivo Android real.
- Partidos favoritos (`MatchRow`).
