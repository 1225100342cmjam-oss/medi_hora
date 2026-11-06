
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../models.dart';
import '../security.dart';
import '../theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();

  final _nombre = TextEditingController();
  final _telefono = TextEditingController();
  DateTime? _fechaNacimiento;
  bool _consSalud = false;
  bool _consCompartir = false;
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _pass2 = TextEditingController();

  Rol _rol = Rol.paciente;

  String? _error;
  bool _mostrarPass = false;
  bool _mostrarPass2 = false;
  bool _cargando = false;

  @override
  void dispose() {
    _nombre.dispose();
    _telefono.dispose();
    _email.dispose();
    _pass.dispose();
    _pass2.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    FocusScope.of(context).unfocus();

    if (!_form.currentState!.validate()) return;

    setState(() {
      _error = null;
      _cargando = true;
    });

    try {
      final err = await context.read<AppState>().register(
            nombre: _nombre.text.trim(),
            fechaNacimiento: _fechaNacimiento!,
            email: _email.text.trim(),
            telefono: _telefono.text.trim(),
            pass: _pass.text,
            rol: _rol,
            consentimientoSalud: _consSalud,
            consentimientoCompartir: _consCompartir,
          );

      if (!mounted) return;

      if (err != null) {
        setState(() {
          _error = err;
          _cargando = false;
        });
      } else {
        // AuthGate administra el acceso según la sesión.
        Navigator.pop(context);
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = 'No fue posible crear la cuenta. Intenta nuevamente.';
        _cargando = false;
      });
    }
  }

  Future<void> _elegirFecha(FormFieldState<DateTime> campo) async {
    final hoy = DateTime.now();
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime(hoy.year - 40, 1, 1),
      firstDate: DateTime(hoy.year - 120, 1, 1),
      lastDate: hoy,
      helpText: 'Fecha de nacimiento',
    );
    if (elegida == null) return;
    setState(() => _fechaNacimiento = elegida);
    campo.didChange(elegida);
  }

  String _fmtFecha(DateTime f) =>
      '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year}';

  String _descripcionRol(Rol rol) {
    return switch (rol) {
      Rol.paciente =>
        'Organiza tus medicamentos, consulta tus horarios y registra tus tomas.',
      Rol.cuidador =>
        'Apoya el seguimiento de los medicamentos y las existencias autorizadas.',
      Rol.admin =>
        'Administra los registros y supervisa la información de la aplicación.',
    };
  }

  IconData _iconoRol(Rol rol) {
    return switch (rol) {
      Rol.paciente => Icons.person_rounded,
      Rol.cuidador => Icons.volunteer_activism_rounded,
      Rol.admin => Icons.admin_panel_settings_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      backgroundColor: kFondo,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Encabezado y botón para regresar.
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Regresar',
                        onPressed: () => Navigator.maybePop(context),
                        style: IconButton.styleFrom(
                          minimumSize: const Size(50, 50),
                          backgroundColor: Colors.white,
                          foregroundColor: kAzul,
                        ),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          size: 28,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.health_and_safety_rounded,
                        color: kPrimario,
                        size: 34,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'MediHora',
                        style: tema.textTheme.titleLarge?.copyWith(
                          color: kPrimarioOscuro,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: kPrimarioClaro,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Crea tu cuenta',
                                style: tema.textTheme.headlineSmall?.copyWith(
                                  color: kPrimarioOscuro,
                                  fontSize: 27,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Organiza tus medicamentos y lleva un mejor '
                                'seguimiento de tu rutina de salud.',
                                style: TextStyle(
                                  color: kTinta,
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.medication_rounded,
                          color: kPrimario,
                          size: 46,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Formulario.
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: const Color(0xFFD3E2F3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _form,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Tus datos',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              color: kAzul,
                            ),
                          ),
                          const SizedBox(height: 20),

                          _etiqueta('Nombre completo'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nombre,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.name],
                            decoration: _decoracion(
                              hint: 'Escribe tu nombre completo',
                              icono: Icons.person_outline_rounded,
                            ),
                            style: _estiloCampo(),
                            validator: (v) {
                              if (v == null || v.trim().length < 3) {
                                return 'Escribe tu nombre completo';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          _etiqueta('Fecha de nacimiento'),
                          const SizedBox(height: 8),
                          FormField<DateTime>(
                            validator: (_) {
                              final f = _fechaNacimiento;
                              if (f == null) {
                                return 'Selecciona tu fecha de nacimiento';
                              }
                              return null;
                            },
                            builder: (campo) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    borderRadius: BorderRadius.circular(13),
                                    onTap: () => _elegirFecha(campo),
                                    child: InputDecorator(
                                      decoration: _decoracion(
                                        hint: 'Selecciona una fecha',
                                        icono: Icons.cake_outlined,
                                      ),
                                      child: Text(
                                        _fechaNacimiento == null
                                            ? 'Selecciona una fecha'
                                            : _fmtFecha(_fechaNacimiento!),
                                        style: _estiloCampo().copyWith(
                                          color: _fechaNacimiento == null
                                              ? kTextoSecundario
                                              : kTinta,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (campo.hasError)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 6, left: 12),
                                      child: Text(
                                        campo.errorText!,
                                        style: const TextStyle(
                                            color: kRojo, fontSize: 13),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 20),

                          _etiqueta('Correo electrónico'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            autocorrect: false,
                            decoration: _decoracion(
                              hint: 'ejemplo@correo.com',
                              icono: Icons.email_outlined,
                            ),
                            style: _estiloCampo(),
                            validator: (v) {
                              final correo = v?.trim() ?? '';

                              if (correo.isEmpty) {
                                return 'Ingresa tu correo electrónico';
                              }

                              if (!RegExp(
                                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                              ).hasMatch(correo)) {
                                return 'Escribe un correo válido';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          _etiqueta('Teléfono (opcional)'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _telefono,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.telephoneNumber],
                            decoration: _decoracion(
                              hint: 'Ejemplo: 461 123 4567',
                              icono: Icons.phone_outlined,
                            ),
                            style: _estiloCampo(),
                            validator: (v) {
                              final t = v?.trim() ?? '';
                              if (t.isEmpty) return null;
                              if (!RegExp(r'^[0-9+()\-\s]{7,20}$').hasMatch(t)) {
                                return 'Escribe un teléfono válido';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          _etiqueta('Contraseña'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _pass,
                            obscureText: !_mostrarPass,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.newPassword],
                            autocorrect: false,
                            decoration: _decoracion(
                              hint: 'Mínimo 8 caracteres, con letras y números',
                              icono: Icons.lock_outline_rounded,
                              sufijo: IconButton(
                                tooltip: _mostrarPass
                                    ? 'Ocultar contraseña'
                                    : 'Mostrar contraseña',
                                onPressed: () {
                                  setState(() {
                                    _mostrarPass = !_mostrarPass;
                                  });
                                },
                                icon: Icon(
                                  _mostrarPass
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                              ),
                            ),
                            style: _estiloCampo(),
                            validator: (v) {
                              return Seguridad.validarPassword(v ?? '');
                            },
                          ),

                          const SizedBox(height: 20),

                          _etiqueta('Confirmar contraseña'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _pass2,
                            obscureText: !_mostrarPass2,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.newPassword],
                            autocorrect: false,
                            onFieldSubmitted: (_) => _registrar(),
                            decoration: _decoracion(
                              hint: 'Vuelve a escribir tu contraseña',
                              icono: Icons.lock_reset_rounded,
                              sufijo: IconButton(
                                tooltip: _mostrarPass2
                                    ? 'Ocultar contraseña'
                                    : 'Mostrar contraseña',
                                onPressed: () {
                                  setState(() {
                                    _mostrarPass2 = !_mostrarPass2;
                                  });
                                },
                                icon: Icon(
                                  _mostrarPass2
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                              ),
                            ),
                            style: _estiloCampo(),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Confirma tu contraseña';
                              }

                              if (v != _pass.text) {
                                return 'Las contraseñas no coinciden';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 26),

                          // Selección del tipo de usuario.
                          const Text(
                            '¿Cómo utilizarás MediHora?',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: kAzul,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Selecciona el perfil que corresponda a tus funciones.',
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: kTextoSecundario,
                            ),
                          ),
                          const SizedBox(height: 14),

                          for (final rol in const [Rol.paciente, Rol.cuidador])
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _tarjetaRol(rol),
                            ),

                          const SizedBox(height: 18),
                          const Text(
                            'Privacidad y consentimiento',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: kAzul,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'MediHora organiza tus medicamentos; no sustituye las '
                            'indicaciones de un profesional de la salud ni sugiere '
                            'dosis.',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: kTextoSecundario,
                            ),
                          ),
                          const SizedBox(height: 8),
                          FormField<bool>(
                            validator: (_) => _consSalud
                                ? null
                                : 'Es necesario para crear tu cuenta',
                            builder: (campo) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CheckboxListTile(
                                  contentPadding: EdgeInsets.zero,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  value: _consSalud,
                                  onChanged: (v) {
                                    setState(() => _consSalud = v ?? false);
                                    campo.didChange(_consSalud);
                                  },
                                  title: const Text(
                                    'Acepto que MediHora trate mis datos de salud '
                                    '(medicamentos, tomas y existencias) para '
                                    'darme recordatorios y seguimiento.',
                                    style: TextStyle(fontSize: 15, height: 1.4),
                                  ),
                                ),
                                if (campo.hasError)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12),
                                    child: Text(
                                      campo.errorText!,
                                      style: const TextStyle(
                                          color: kRojo, fontSize: 13),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (_rol == Rol.paciente)
                            CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              value: _consCompartir,
                              onChanged: (v) =>
                                  setState(() => _consCompartir = v ?? false),
                              title: const Text(
                                'Autorizo compartir información con los '
                                'cuidadores que yo invite (opcional). Puedo '
                                'retirarlo cuando quiera.',
                                style: TextStyle(fontSize: 15, height: 1.4),
                              ),
                            ),

                          if (_error != null) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(13),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFCE8E9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: kRojo),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    color: kRojo,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _error!,
                                      style: const TextStyle(
                                        color: kRojoOscuro,
                                        fontSize: 15,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),

                          SizedBox(
                            height: 56,
                            child: FilledButton.icon(
                              onPressed: _cargando ? null : _registrar,
                              style: FilledButton.styleFrom(
                                backgroundColor: kPrimario,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    kPrimario.withValues(alpha: 0.6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: _cargando
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person_add_alt_1_rounded,
                                      size: 23,
                                    ),
                              label: Text(
                                _cargando
                                    ? 'Creando cuenta...'
                                    : 'Crear mi cuenta',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          const Text(
                            'Utiliza una contraseña que no compartas con otras personas.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: kTextoSecundario,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'MediHora · Tu salud, organizada y a tiempo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: kTextoSecundario,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _etiqueta(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: kTinta,
      ),
    );
  }

  TextStyle _estiloCampo() {
    return const TextStyle(
      fontSize: 17,
      color: kTinta,
    );
  }

  InputDecoration _decoracion({
    required String hint,
    required IconData icono,
    Widget? sufijo,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(
        icono,
        color: kPrimario,
        size: 25,
      ),
      suffixIcon: sufijo,
      filled: true,
      fillColor: kFondo,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Color(0xFFB5CAE2),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Color(0xFFB5CAE2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: kPrimario,
          width: 2,
        ),
      ),
    );
  }

  Widget _tarjetaRol(Rol rol) {
    final seleccionado = _rol == rol;

    return Semantics(
      selected: seleccionado,
      button: true,
      label: '${rol.label}. ${_descripcionRol(rol)}',
      child: Material(
        color: seleccionado ? kPrimarioClaro : Colors.white,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            setState(() {
              _rol = rol;
              _error = null;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: seleccionado
                    ? kPrimario
                    : const Color(0xFFD3E2F3),
                width: seleccionado ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: seleccionado ? kPrimario : kFondo,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    _iconoRol(rol),
                    color: seleccionado ? Colors.white : kAzul,
                    size: 27,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rol.label,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: kTinta,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _descripcionRol(rol),
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: kTextoSecundario,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  seleccionado
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: seleccionado ? kPrimario : kTextoSecundario,
                  size: 25,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
