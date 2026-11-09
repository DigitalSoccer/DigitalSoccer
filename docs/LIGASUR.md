# Liga SUR — app de la ANFA Caupolicán

Reemplaza el diseño rojo anterior (rama `feature/mockup-etapa1`). Referencia:
mockup aprobado de 15 pantallas, requerimiento de la asociación y
observaciones de Diego (carpeta de traspaso `datos nuevos/`, fuera de git).

Marca: amarillo `#FFC700`, negro `#111111`, Montserrat (incluida, OFL).

## Perfiles

- **Visitante**: sin cuenta, elige su club y ve lo público.
- **Suscriptor**: jugador con RUT y clave; perfil con estadísticas,
  asistencia y beneficios ($1.000).
- **Turno**: el club que descansa en la fecha; carga las papeletas.
- **Administrador**: la asociación; panel con lo que requiere acción.

## Etapas

1. **Base y tema** (hecha): tema claro/oscuro, Montserrat, datos de muestra
   y repositorio, componentes compartidos, etiqueta "Datos de ejemplo".
2. **Navegación y perfiles** (hecha): ingreso simulado, visitante que elige
   club, barra de 5 pestañas y "Más" según el perfil.
3. Pantallas públicas.
4. Turno y papeleta.
5. Administrador.

## Datos

- **Un solo archivo** de muestra: `assets/data/sample_data.json`, generado
  por `tool/generate_sample_data.dart` (semilla fija). Las pantallas lo leen
  solo a través de `LeagueRepository` (`lib/data/league_repository.dart`):
  para los datos oficiales se cambia la implementación, no la interfaz.
- **Reales**: los 17 clubes (nombre, iniciales y color del mockup) y los
  puntos de Honor, Primera, Segunda y Senior. Todo lo demás es **dummy**
  (la sección `origen` del JSON lo detalla).
- La tabla y las estadísticas se **calculan** desde los resultados
  (`LeagueData.standings`, `playerStats`); nunca se escriben a mano.
- La etiqueta "Datos de ejemplo" se apaga con `kUsingSampleData`
  (`lib/core/config.dart`).

### Decisiones sobre los datos dummy (2026-11-09)

- **10 series** con sus nombres de la planilla: Honor, Primera, Segunda,
  Senior, S. Senior, H. Ortiz, Femenina, Juveniles, 1° Infantil y
  2° Infantil. La columna que el mockup llamaba "Super Senior" son los
  puntos de **Senior**.
- **Calendario**: ida y vuelta de 17 clubes (34 fechas). Cada fecha tiene 8
  cruces y un club en turno, que descansa en todas las series. Fechas 1–20
  validadas; la 21 está en carga (1 papeleta por validar, un cruce
  suspendido); de la 22 en adelante, programadas. Las fechas 31–34 aún no
  tienen turno asignado (para el panel de la liga).
- **Honor**: campeonato propio de 10 equipos; los 7 clubes con 0 puntos no
  tienen equipo en Honor (TODO: confirmar con la asociación). El turno
  también descansa en Honor.
- **Puntos reales**: los resultados de las fechas 1–20 se buscaron para que
  sumen exactamente los puntos reales. Primera, Segunda y Honor cuadran sin
  suspendidos. En **Senior** es imposible si se juegan todos los partidos
  (El Tigre tiene 0 y Shaub F.C. 3, y se enfrentan dos veces), así que esos
  **2 partidos quedan suspendidos**.
- Senior: El Tigre (0 puntos) juega y pierde todos sus partidos.

## Navegación y perfiles (etapa 2)

- **Ingreso simulado** con RUT y clave contra las cuentas de prueba del
  archivo de muestra (sección `usuarios`: suscriptor, jugador sin
  suscripción, turno y administrador). No hay autenticación real.
- **Visitante**: "Entrar como visitante" abre, dentro de la misma tarjeta,
  el paso "Elige tu club" (cambio pedido; sin pantalla nueva). Se puede
  entrar sin club y cambiarlo después desde Más → "Mi club".
- "Regístrate" y "¿Olvidaste tu contraseña?" muestran un aviso (el mockup no
  tiene esas pantallas). TODO.
- La sesión (perfil, club y "ver como") se guarda en el teléfono.
- **Más varía según el perfil**:
  - Visitante: Mi club, Noticias, Reglamento; botón "Iniciar sesión".
  - Jugador sin suscripción: Mi perfil, "Hazte suscriptor por $1.000",
    Noticias, Reglamento.
  - Suscriptor: Mi perfil, Suscripción (plan), Noticias, Reglamento.
  - Turno: Panel del turno, Mi perfil (si es jugador), Noticias, Reglamento.
  - Administrador: Panel de administración, Panel del turno, Noticias,
    Reglamento.
- **"Ver la app como"** (Suscriptor / Turno / Administrador) es el modo
  demostración del mockup; aparece solo con cuenta.
- Las pestañas Inicio, Partidos, Tabla y Equipos y las pantallas de Más
  muestran un marcador temporal hasta su etapa.

## Preguntas abiertas con la asociación (TODO en el código)

Significado de los 0 en Honor, criterio de desempate (hoy: comparten
posición y se ordenan por nombre), fixture real, puntos de las otras
series, acceso del turno, medio de pago y escudos oficiales.

## Decisiones pendientes del equipo (TODO, con opción por defecto)

Redes sociales en el detalle del equipo (opcionales por club, se muestran
si existen), diferencia del perfil de jugador con y sin suscripción, y
suscripción con pago simulado (sin proveedor real).
