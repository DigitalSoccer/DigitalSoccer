# Datos del fixture: cómo cargar una fecha

La programación llega como una planilla de la **Asociación de Fútbol Caupolicán de Chiguayante**
(foto o PDF por WhatsApp). La app la representa con la misma estructura:

```
Fecha → Día (con fecha calendario) → Cancha → Bloques (separados por "TURNO:") → Partidos
```

## Archivos

| Archivo | Contenido |
|---|---|
| `assets/data/fechas.json` | Índice: lista de archivos de fechas. La app muestra primero la de mayor número |
| `assets/data/fecha_21.json` | Fecha 21 (10 y 11 de octubre de 2026), transcrita de la planilla |
| `assets/data/fixture.json` | Fecha 11, formato antiguo (sin fechas ni turnos). **Origen sin verificar** |

Cada archivo nuevo debe agregarse a `fechas.json` **y** a la sección `assets:` de `pubspec.yaml`.

## Formato

```json
{
  "round": 21,
  "source": "Programación fecha 21 ... de la Asociación ..., recibida por WhatsApp",
  "days": [
    {
      "day": "Sábado",
      "date": "2026-10-10",
      "libre": ["independiente"],
      "fields": [
        {
          "fieldName": "Cancha Mario Osben",
          "blocks": [
            {"turno": null, "matches": [
              {"time":"13:00","home":"U.L. Carrera","homeId":"ul-carrera","away":"San Pablo","awayId":"san-pablo","category":"1° Infantil","status":"normal"}
            ]}
          ]
        }
      ]
    }
  ]
}
```

- `source`: obligatorio para datos reales. Sin `source`, la app muestra "Fuente sin verificar".
- `homeId` / `awayId` / `libre`: ids de `clubs.json` (`arturo-prat`, `bdo-ohiggins`, …). Las pruebas
  fallan si un id no existe.
- `blocks`: un bloque por cada línea "TURNO:" de la planilla. `turno` es el club a cargo si la planilla
  lo indica; hoy viene vacío (`null`).
- `status`: `normal`, `suspendido` o `reprogramado`.
- Horas en formato `HH:MM` (la planilla escribe `9:00`; se guarda `09:00`).

## Reglas de transcripción

- **Filas en blanco:** cuando la planilla trae solo hora y serie, se copia el cruce de la fila anterior
  (así se lee la planilla). La app vuelve a agruparlas al mostrarlas.
- No se agregan ni corrigen partidos que no estén en la planilla. Si algo parece un error de la
  planilla, se transcribe tal cual y se consulta.
- La nota de valores de arbitraje y tiempos de juego **no** se carga en la app (pendiente de decisión).

## Verificación

```bash
flutter test test/club_relations_test.dart
```

Comprueba ids válidos, clubes libres existentes y, para la fecha 21, el total de partidos por día y los
partidos de Arturo Prat contra la planilla.
