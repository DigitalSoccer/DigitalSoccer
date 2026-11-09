import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/session.dart';
import '../../core/theme.dart';
import '../../data/league_scope.dart';
import '../../shared/club_picker.dart';
import '../../shared/club_shield.dart';
import '../../shared/liga_logo.dart';
import '../../shared/striped_header.dart';

/// Ingreso (mockup "1 · Ingreso"): RUT y clave, o entrar como visitante.
/// Cambio pedido: el visitante puede elegir su club (paso dentro de la misma
/// tarjeta, sin pantalla nueva).
class IngresoPage extends StatefulWidget {
  const IngresoPage({super.key});

  @override
  State<IngresoPage> createState() => _IngresoPageState();
}

class _IngresoPageState extends State<IngresoPage> {
  final _rut = TextEditingController();
  final _password = TextEditingController();
  bool _choosingClub = false;
  String? _clubId;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _rut.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final data = LeagueScope.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    final ok = await SessionScope.of(
      context,
    ).login(data, _rut.text.trim(), _password.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (!ok) _error = 'RUT o clave incorrectos.';
    });
  }

  void _info(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    final size = MediaQuery.sizeOf(context);
    final heroHeight = _Hero.heightFor(context);

    // Sin alturas intrínsecas (la grilla de clubes usa LayoutBuilder): la
    // tarjeta ocupa al menos el resto de la pantalla.
    return Scaffold(
      backgroundColor: c.header,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Hero(),
            Container(
              constraints: BoxConstraints(
                minHeight: (size.height - heroHeight).clamp(0, double.infinity),
              ),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                22,
                26,
                22,
                MediaQuery.paddingOf(context).bottom + 20,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _choosingClub
                        ? _clubStep(context)
                        : _loginStep(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static final _compact = TextButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 2),
    tapTargetSize: MaterialTapTargetSize.padded,
  );

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: AppText.strong(context, size: 12)),
  );

  Widget _loginStep(BuildContext context) {
    final c = context.colors;
    final fieldStyle = AppText.strong(
      context,
      size: 15,
    ).copyWith(fontWeight: FontWeight.w600);

    return Column(
      key: const ValueKey('login'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Ingresa a tu cuenta',
          style: AppText.title(context).copyWith(fontSize: 22),
        ),
        const SizedBox(height: 4),
        Text(
          'Usa tu RUT y la clave que te entregó la liga.',
          style: AppText.muted(
            context,
            size: 13,
          ).copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 18),
        _label('RUT'),
        TextField(
          controller: _rut,
          style: fieldStyle,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.username],
          decoration: InputDecoration(
            hintText: '12.345.678-9',
            errorText: _error == null ? null : '',
            errorStyle: const TextStyle(height: 0, fontSize: 0),
          ),
        ),
        const SizedBox(height: 14),
        _label('Clave'),
        TextField(
          controller: _password,
          style: fieldStyle,
          obscureText: true,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
          onSubmitted: (_) => _login(),
          decoration: InputDecoration(hintText: 'Tu clave', errorText: _error),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            // TODO(asociación): recuperación de clave.
            onPressed: () =>
                _info('Pide una nueva clave a la directiva de la liga.'),
            child: const Text(
              '¿Olvidaste tu contraseña?',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
          ),
        ),
        SizedBox(
          height: 56,
          child: FilledButton(
            onPressed: _busy ? null : _login,
            child: const Text('Iniciar sesión'),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            TextButton(
              style: _compact,
              // TODO(decisión): el mockup no tiene pantalla de registro.
              onPressed: () => _info('El registro estará disponible pronto.'),
              child: Text.rich(
                TextSpan(
                  text: '¿Sin cuenta? ',
                  style: AppText.muted(context, size: 13),
                  children: [
                    TextSpan(
                      text: 'Regístrate',
                      style: TextStyle(
                        color: c.text,
                        fontWeight: FontWeight.w800,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            TextButton(
              style: _compact,
              onPressed: () => setState(() => _choosingClub = true),
              child: const Text('Entrar como visitante →'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _clubStep(BuildContext context) {
    final data = LeagueScope.of(context);
    final clubs = [...data.clubs]..sort((a, b) => a.name.compareTo(b.name));

    return Column(
      key: const ValueKey('club'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Volver al ingreso',
              onPressed: () => setState(() => _choosingClub = false),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'Elige tu club',
                style: AppText.title(context).copyWith(fontSize: 22),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Lo verás destacado en Inicio. Puedes cambiarlo cuando quieras '
          'desde Más.',
          style: AppText.muted(
            context,
            size: 13,
          ).copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        ClubPicker(
          clubs: clubs,
          selectedId: _clubId,
          onSelected: (id) => setState(() => _clubId = id),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 56,
          child: FilledButton(
            onPressed: _clubId == null
                ? null
                : () => SessionScope.of(context).enterAsVisitor(_clubId),
            child: const Text('Entrar como visitante'),
          ),
        ),
        const SizedBox(height: 6),
        TextButton(
          onPressed: () => SessionScope.of(context).enterAsVisitor(null),
          child: const Text('Ahora no, entrar sin club'),
        ),
      ],
    );
  }
}

/// Parte superior: anillo con los 17 escudos alrededor de la insignia ANFA,
/// y el logo "Liga SUR". Se dibuja a 390×372 y se escala en pantallas
/// angostas.
class _Hero extends StatelessWidget {
  const _Hero();

  static const double width = 390, height = 372;

  /// Alto real: se dibuja a 390×372 y se reduce en pantallas angostas.
  static double scaleFor(BuildContext context) =>
      (MediaQuery.sizeOf(context).width / width).clamp(0.0, 1.0);

  static double heightFor(BuildContext context) =>
      MediaQuery.paddingOf(context).top + height * scaleFor(context);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final data = LeagueScope.of(context);
    final top = MediaQuery.paddingOf(context).top;

    const cx = width / 2, cy = 150.0, radius = 112.0, size = 32.0;
    final clubs = data.clubs;

    return StripedHeader(
      padding: EdgeInsets.only(top: top),
      child: SizedBox(
        height: height * scaleFor(context),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              children: [
                for (var i = 0; i < clubs.length; i++)
                  Positioned(
                    left:
                        cx +
                        radius * cos(i * 2 * pi / clubs.length - pi / 2) -
                        size / 2,
                    top:
                        cy +
                        radius * sin(i * 2 * pi / clubs.length - pi / 2) -
                        size / 2,
                    child: ClubShield(
                      club: clubs[i],
                      size: size,
                      ringColor: c.header,
                    ),
                  ),
                Positioned(
                  left: cx - 60,
                  top: cy - 60,
                  child: Semantics(
                    label: 'Asociación de Fútbol Caupolicán',
                    excludeSemantics: true,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: c.anfaBlue,
                        shape: BoxShape.circle,
                        border: Border.all(color: c.brand, width: 3),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'ANFA',
                            style: TextStyle(
                              fontFamily: AppFonts.family,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.9,
                              color: c.onHeader,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'CAUPOLICÁN',
                            style: TextStyle(
                              fontFamily: AppFonts.family,
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                              color: c.anfaGold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 282,
                  child: Column(
                    children: [
                      const LigaLogo(size: 32),
                      const SizedBox(height: 6),
                      Text(
                        'Asociación de Fútbol Caupolicán · Chiguayante',
                        style: AppText.muted(context, color: c.onHeaderMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
