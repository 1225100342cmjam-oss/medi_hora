
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'racha_screen.dart';
import 'botiquin_screen.dart';
import '../app_state.dart';
import '../models.dart';
import '../theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();

  final _nombre = TextEditingController();
  final _edad = TextEditingController();
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
    _edad.dispose();
    _email.dispose();
    _pass.dispose();
    _pass2.dispose();
    super.dispose();
  }

  void _registrar() {
    FocusScope.of(context).unfocus();

    if (!_form.currentState!.validate()) return;

    setState(() {
      _error = null;
      _cargando = true;
    });

    try {
      final err = context.read<AppState>().register(
            _nombre.text.trim(),
            int.parse(_edad.text.trim()),
            _email.text.trim(),
            _pass.text,
            _rol,
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
                        color: kVerde,
                        size: 34,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'MediHora',
                        style: tema.textTheme.titleLarge?.copyWith(
                          color: kVerdeOscuro,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: kVerdeClaro,
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
                                  color: kVerdeOscuro,
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
                          color: kVerde,
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
                        color: const Color(0xFFDCE7E1),
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

                          _etiqueta('Edad'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _edad,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            decoration: _decoracion(
                              hint: 'Ejemplo: 45',
                              icono: Icons.cake_outlined,
                            ),
                            style: _estiloCampo(),
                            validator: (v) {
                              final edad = int.tryParse(v?.trim() ?? '');

                              if (edad == null || edad < 1 || edad > 120) {
                                return 'Ingresa una edad válida';
                              }

                              return null;
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

                          _etiqueta('Contraseña'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _pass,
                            obscureText: !_mostrarPass,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.newPassword],
                            autocorrect: false,
                            decoration: _decoracion(
                              hint: 'Mínimo 6 caracteres',
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
                              if (v == null || v.length < 6) {
                                return 'Utiliza al menos 6 caracteres';
                              }
                              return null;
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

                          for (final rol in Rol.values)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _tarjetaRol(rol),
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
                                backgroundColor: kVerde,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    kVerde.withValues(alpha: 0.6),
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
        color: kVerde,
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
          color: Color(0xFFB8CBC2),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Color(0xFFB8CBC2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: kVerde,
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
        color: seleccionado ? kVerdeClaro : Colors.white,
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
                    ? kVerde
                    : const Color(0xFFDCE7E1),
                width: seleccionado ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: seleccionado ? kVerde : kFondo,
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
                  color: seleccionado ? kVerde : kTextoSecundario,
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
