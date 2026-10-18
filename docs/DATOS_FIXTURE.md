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

## Planteles (estructura preparada, sin datos)

`assets/data/planteles.json` está vacío (`{"planteles": []}`) hasta que el club entregue los datos.
Formato esperado:

```json
{
  "planteles": [
    {
      "clubId": "arturo-prat",
      "category": "Honor",
      "players": [
        {"id": "…", "name": "…", "number": 9,
         "stats": {"played": 18, "goals": 11, "yellow": 3, "red": 1}}
      ]
    }
  ]
}
```

- `category` usa el mismo nombre de serie que el fixture (`Honor`, `S. Senior`, `2° Infantil`…).
- `number` y cada estadística son opcionales (sin dato: "–" y 0).
- Más adelante estos datos vendrán de la API; la app solo cambia de dónde los lee (`SquadService`).

## Tabla de posiciones: puntaje parcial 2026

La asociación entrega el **"Puntaje parcial, competencia oficial año 2026"**: por club, los puntos de
cada serie, dos subtotales ("Puntaje acumulado" de series menores y de series adultas) y el **Total
acumulado**. La planilla advierte: *tabla sujeta a modificaciones por diversas causas de tipo
reglamentario*.

| Archivo | Contenido |
|---|---|
| `assets/data/standings.json` | Tabla general = **Total acumulado**, con `source` y `note` |
| `assets/data/tablas_series.json` | `series`: una tabla por serie; `acumulados`: "Infantil y juvenil" y "Adultos" |

Equivalencia de columnas de la planilla → series de la app: Segunda Infantil → `2° Infantil`,
Primera Infantil → `1° Infantil`, Juveniles, Super Senior → `S. Senior`, Segunda Adulta → `Segunda`,
Primera Adulta → `Primera`, Serie Senior → `Senior`, Serie Honor → `Honor`, H.Ortiz → `H. Ortiz`,
Femenina.

- Subtotal "Infantil y juvenil" = 2° Infantil + 1° Infantil + Juveniles.
- Subtotal "Adultos" = S. Senior + Segunda + Primera + Senior + Honor + H. Ortiz + Femenina.
- Total = ambos subtotales. Las pruebas (`club_relations_test.dart`) verifican estas sumas para los
  17 clubes, así un error de transcripción se detecta solo.
- La planilla trae **dos** columnas "Puntaje acumulado" antes de Super Senior; la primera repite la
  segunda salvo en O'Higgins (12) y El Valle (vacío), así que se usa la segunda, que sí cuadra.
- Formato de cada fila: `{"clubId": "...", "team": "...", "points": N}`; `played` y `goalDifference`
  son opcionales (la planilla no los trae: la app muestra "–").
- Con puntos iguales los clubes **comparten posición** (1, 1, 3…): no hay reglas de desempate oficiales.
- Para actualizar: transcribir la nueva planilla y regenerar ambos archivos; las pruebas validan las sumas.
