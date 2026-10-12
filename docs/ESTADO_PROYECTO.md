# Estado del proyecto — App ANFA / Club Arturo Prat Chiguayante

> Auditoría técnica inicial. Fecha: 2026-10-12. Autor: Claude Code (revisión pendiente: Diego).
> Base auditada: commit `3fdc296` ("Initial commit - ANFA Chiguayante"), rama `main`, remoto `github.com/DigitalSoccer/DigitalSoccer`.

> **Actualización 2026-10-12 (rama `fix/identidad-clubes-pruebas-ui`):** corregidos los problemas
> 1, 2, 6 y 7 de la §5 (ids de club, pruebas reales, tema verde, estados de carga/error/vacío).
> Ver `DECISIONES_TECNICAS.md` y `PRUEBAS.md`. El resto de este documento describe el estado auditado.

---

## 1. Resumen ejecutivo

El repositorio contiene una **app Flutter pequeña (≈1.250 líneas de Dart) y funcional** que muestra el
fixture de **una sola fecha (fecha 11)** de ANFA Chiguayante, una tabla general por puntos, un listado de
clubes y la opción de marcar un "Mi Club" y partidos favoritos. Todos los datos son **archivos JSON
estáticos dentro de la app**: no hay backend, no hay resultados (marcadores), no hay noticias ni
administración.

- `flutter analyze`: **sin problemas**.
- `flutter test`: **falla** (el único test es la plantilla "counter" por defecto de Flutter y no
  corresponde a esta app).
- `flutter build web`: **compila** y la app se ejecutó correctamente en el navegador (vista móvil).

Hay una **diferencia de visión que debe resolverse antes de seguir**: el código actual es un visor del
fixture de *toda la asociación*; el PDF `Plan_Proyecto_App_Futbol_Amateur.pdf` describe una plataforma de
*actas digitales para ANFA* (turnos, Supabase, panel admin); y el prompt maestro describe una *app del
Club Arturo Prat* (inicio del club, resultados, noticias). Ver §8 y "Decisiones".

## 2. Arquitectura actual

| Aspecto | Estado actual |
|---|---|
| Estructura | `lib/{models,services,pages,widgets,data}` — separación básica por tipo |
| Estado | `StatefulWidget` + `setState` + `FutureBuilder`. Sin gestor de estado |
| Navegación | `BottomNavigationBar` con 4 pestañas (Fixture, Mi Club, Tabla, Clubes) + `Navigator.push` al detalle de club |
| Datos | `rootBundle.loadString` de JSON en `assets/data/` mediante servicios estáticos |
| Modelos | `Club`, `FixtureRound` → `MatchDay` → `FieldSchedule` → `Match`, `Standing` (definido dentro del servicio), `MatchOverride` (sin uso) |
| Serialización | `fromJson` manual, sin validación de tipos ni nulos |
| Persistencia | `shared_preferences`: club favorito (`favorite_club`) y partidos favoritos (`favorites`) |
| Tema | `ThemeData(primarySwatch: Colors.green)` — **sin efecto** bajo Material 3: la app se ve en el morado por defecto |
| Inyección de dependencias | No hay; servicios con métodos `static` (dificulta pruebas) |
| Entornos / configuración | No hay |

Plataformas generadas: android, ios, web, windows, macos, linux. Android usa `applicationId`
`com.example.anfa_chiguayante` (debe cambiarse antes de publicar).

## 3. Funcionalidades existentes (verificadas ejecutando la app web)

| Funcionalidad | Estado | Observaciones |
|---|---|---|
| Fixture por día (Sábado/Domingo) agrupado por cancha | ✅ Funciona | Solo fecha 11 (57 partidos). Día como texto, sin fecha calendario |
| Búsqueda de club en fixture | ✅ Funciona | Coincidencia por subcadena (`"Prat"` coincide con cualquier nombre que la contenga) |
| Mi Club (favorito persistente) | ✅ Funciona | La pestaña no se refresca al cambiar el favorito desde otra pestaña (estado cargado solo en `initState`) |
| Tabla general | ✅ Muestra | Solo equipo + puntos; sin PJ/G/E/P/GF/GC/DG. Origen y criterio de los puntos desconocido |
| Listado de clubes + detalle | ⚠️ Parcial | En el detalle de **Arturo Prat no aparece posición ni puntos** (bug, ver §5) |
| Partidos favoritos (estrella) | ✅ Funciona | El ID del partido se construye con `home-away-time-category`: cambia si se reprograma |
| Estados de partido (suspendido/reprogramado) | ⚠️ Solo visual | Color por `status`; todos los datos vienen como `"normal"` |

## 4. Funcionalidades pendientes (vs. módulos del prompt maestro)

| Módulo | Estado |
|---|---|
| A. Inicio del club (identidad, próximo partido, últimos resultados) | ❌ No existe (la pestaña inicial es el fixture general) |
| B. Calendario y detalle de partido | ⚠️ Una sola fecha, sin fechas reales, sin pantalla de detalle |
| C. Resultados / marcadores | ❌ No existe; el modelo `Match` no tiene goles |
| D. Tabla de posiciones completa por serie | ❌ Solo puntos agregados; sin desglose ni desempates |
| E. Noticias y comunicados | ❌ No existe |
| F. Administración / actualización sin recompilar | ❌ No existe: actualizar datos exige publicar una nueva versión de la app |
| Estados de error / vacío | ❌ Ningún `FutureBuilder` maneja `snapshot.hasError`: un JSON mal formado deja un spinner infinito |
| Pruebas | ❌ Ninguna válida |

## 5. Problemas detectados

**Comprobados** (verificados ejecutando o leyendo el código):

1. **Test roto**: `test/widget_test.dart` es la plantilla del contador. `flutter test` → 1 fallo.
2. **Nombres de equipos inconsistentes entre archivos** → `standings.json` usa `"A. Prat"` y
   `"Bdo. O’Higgins"` (apóstrofo tipográfico), mientras `clubs.json` y `fixture.json` usan `"Arturo Prat"`
   y `"Bdo. O'Higgins"`. Resultado: el detalle de Arturo Prat y de Bdo. O'Higgins no muestra posición.
   Causa raíz: los equipos se relacionan por **nombre de texto**, no por un identificador.
3. **`OverrideService` es código de ejemplo sin efecto**: busca `Bdo. O’Higgins vs Arturo Prat 12:00`, un
   partido que no existe en `fixture.json`.
4. **Código y datos sin uso**: `lib/data/mock_data.dart` (otro fixture distinto, no referenciado),
   `lib/models/match_override.dart` (no referenciado), `assets/data/fixture_fecha_11/12/13.json`
   (vacíos, 0 bytes, no declarados en `pubspec.yaml`).
5. **Categorías inconsistentes**: `categories.json` dice `"Super Senior"`; el fixture usa `"S. Senior"`.
6. **Tema verde sin efecto** (Material 3 ignora `primarySwatch`).
7. **Sin manejo de errores** en la carga de datos (spinner infinito si falla).
8. `README.md` es el texto por defecto de `flutter create`.

**Entorno** (no son errores del código):

9. **Flutter no está en el PATH**. Se usó el SDK encontrado en
   `C:\Users\diego\Downloads\flutter_windows_3.47.7-stable\flutter` (Flutter 3.47.7, Dart 3.13.5).
   El proyecto fue creado con una versión anterior (revisión `adc9010`); no hay versión fijada para el equipo.
10. `flutter pub get` con 3.47.7 **modificó `pubspec.lock`** (6 paquetes fijados por el SDK: `characters`,
    `matcher`, `material_color_utilities`, `meta`, `test_api`, `vector_math`) y **agregó exclusiones a
    `analysis_options.yaml`**. Cambios sin commitear, pendientes de decisión del equipo.
11. **Windows sin Modo Desarrollador**: Flutter avisa que compilar con plugins (`shared_preferences`)
    requiere symlinks. Probablemente impida `flutter build apk`/`run` en Android desde este PC hasta
    activarlo. No se probó la compilación Android.
12. **Repositorio Git anidado**: `C:\DigitalSoccerSoftware` es un repo vacío (sin commits) que contiene el
    repo real `DigitalSoccer/` como carpeta sin seguimiento. Riesgo de commits en el repo equivocado.

**Requieren validación** (no se pueden comprobar desde el código):

13. ¿Los datos de `fixture.json` y `standings.json` son **reales/oficiales**? ¿De qué fuente y fecha?
    ¿Qué representan los puntos de la tabla general (¿suma de todas las series?)?
14. ¿Las canchas asignadas a cada club en `clubs.json` son correctas?

## 6. Dependencias e integraciones

| Dependencia | Uso | Comentario |
|---|---|---|
| `flutter` SDK `^3.9.2` | — | Compatible con 3.47.7 (verificado) |
| `shared_preferences ^2.2.2` | Favoritos | Justificada |
| `cupertino_icons ^1.0.8` | — | Plantilla; no se usa en el código |
| `flutter_lints ^5.0.0` (dev) | Análisis | Correcta |

Integraciones externas: **ninguna** (sin red, sin backend, sin analítica, sin Firebase/Supabase).
No se encontraron secretos ni credenciales en el repositorio.

## 7. Riesgos técnicos

| Riesgo | Impacto | Mitigación propuesta |
|---|---|---|
| Datos embebidos: cada cambio de fixture exige publicar la app | Alto | Fuente de datos remota y editable (ver decisiones) |
| Relaciones por nombre de texto | Alto | IDs estables para clubes, categorías y partidos |
| Datos presentados como oficiales sin fuente verificada | Alto (reputacional) | Validar con ANFA/club; mostrar "fuente y fecha de actualización" |
| Visión de producto no alineada (club vs. asociación vs. actas) | Alto | Decisión de Roberto antes de construir |
| Sin pruebas | Medio | Pruebas unitarias de modelos/servicios y widget tests básicos |
| Datos de menores (categorías infantiles) si se agregan planteles | Medio | No publicar datos personales de jugadores en el MVP |
| SDK no fijado / Flutter fuera del PATH | Bajo | Documentar versión; opcional FVM |
| Repo Git anidado | Bajo | Trabajar solo en `DigitalSoccer/`; evaluar eliminar el repo exterior vacío |

## 8. Recomendaciones priorizadas

1. **Decidir el alcance del producto** (club vs. asociación vs. actas). Recomendación: MVP *público y de
   solo lectura*, centrado en Arturo Prat pero reutilizando el fixture de toda la asociación que ya existe.
   El sistema de actas digitales del PDF es una apuesta mayor (backend, roles, modo sin conexión) que
   conviene validar primero con ANFA.
2. **Sanear la base**: test válido, IDs de equipo, corregir nombres, borrar código muerto, tema verde,
   estados de error/vacío.
3. **Rediseñar el modelo de datos** para soportar varias fechas con fecha calendario, resultados y estados.
4. **Definir la fuente de datos** que permita actualizar sin recompilar (ver opciones abajo).
5. Después: pantalla de Inicio del club, resultados, tabla por serie, noticias.

### Opciones de fuente de datos (para decidir)

| Opción | Costo | Mantenimiento | Seguridad | Complejidad |
|---|---|---|---|---|
| a) JSON en el repo (actual) | $0 | Requiere desarrollador + nueva versión de la app | Alta | Mínima |
| b) JSON publicado en GitHub Pages / raw, con caché local y respaldo embebido | $0 | Editar un archivo y subir (un integrante con acceso) | Alta (solo lectura pública) | Baja |
| c) Google Sheets publicado como CSV | $0 | Muy fácil para dirigentes | Media (cualquiera con acceso a la hoja edita) | Baja |
| d) Supabase / Firebase con panel admin | Plan gratis, luego pago | Panel web + login | Alta si se configuran bien permisos | Media-alta |

Recomendación para el MVP: **(b)**, con el diseño en capas (repositorio de datos) que permita migrar a
(d) cuando se decida el sistema de actas, sin reescribir las pantallas.

## 9. Próximos pasos

Tareas iniciales propuestas (detalle completo irá en `docs/PLAN_DESARROLLO.md` una vez aprobadas):

| ID | Tarea | Prioridad | Depende de | Responsable sugerido | Criterio de aceptación |
|---|---|---|---|---|---|
| T0 | Decisiones de producto y datos (ver lista) | Bloqueante | — | Roberto + Diego | Decisiones registradas en `DECISIONES_TECNICAS.md` |
| T1 | Entorno: Flutter en PATH, Modo Desarrollador, versión fijada, decidir lockfile | Alta | — | Diego | `flutter doctor` OK; `flutter run` en Android |
| T2 | Reemplazar test plantilla por smoke test real | Alta | — | Claude Code | `flutter test` verde |
| T3 | IDs de club + unificar nombres/categorías; corregir bug tabla de Arturo Prat | Alta | T2 | Claude Code | Detalle de Arturo Prat muestra posición; test que lo verifica |
| T4 | Eliminar código muerto (`mock_data`, `OverrideService` de ejemplo, JSON vacíos) | Media | T2 | Claude Code | Analyze y tests verdes; app igual |
| T5 | Tema verde real (M3 `colorSchemeFromSeed`) + estados de carga/error/vacío reutilizables | Media | T2 | Claude Code | Widget tests de error y vacío |
| T6 | Capa repositorio (interfaz + implementación JSON local) | Media | T0 | Claude Code | Pantallas no usan `rootBundle` directamente; tests con datos falsos |
| T7 | Validar origen y vigencia de los datos con ANFA/club | Alta | — | Roberto / Elías | Fuente y fecha documentadas |
| T8 | README real (cómo instalar, ejecutar, probar) | Media | T1 | Elías + Claude Code | Un integrante nuevo ejecuta la app siguiendo el README |

## Decisiones que requieren aprobación

1. **Alcance del producto**: ¿app del Club Arturo Prat, app pública de toda ANFA Chiguayante, o plataforma
   de actas digitales (PDF)? — *Roberto*
2. **Fuente de datos del MVP** (opciones a–d) y **quién actualizará** la información. — *Roberto + Diego*
3. **Noticias**: ¿entran en el MVP? (el PDF las deja para v3). — *Roberto*
4. **Recursos gráficos oficiales** (escudo, colores) y autorización de uso. — *Roberto con el club*
5. **Versión de Flutter del equipo** y si se commitean los cambios de `pubspec.lock`/`analysis_options.yaml`. — *Diego*
6. **Repo Git exterior vacío** en `C:\DigitalSoccerSoftware`: ¿eliminarlo? — *Diego*

## Anexo: comandos ejecutados y resultados reales

| Comando (con Flutter 3.47.7) | Resultado |
|---|---|
| `flutter pub get` | OK. Modificó `pubspec.lock` y `analysis_options.yaml`. Aviso de symlinks/Modo Desarrollador |
| `flutter analyze` | `No issues found!` |
| `flutter test` | **1 test fallido** (plantilla counter) |
| `flutter build web` | OK (`build/web`) |
| App web en navegador (375×812) | Fixture, Tabla, Clubes y detalle de club cargan; sin errores en consola; bug de posición de Arturo Prat confirmado |
| Compilación Android / iOS | **No ejecutada** |
