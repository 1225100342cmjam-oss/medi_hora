
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../theme.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();

  String? _error;
  bool _mostrarPass = false;
  bool _cargando = false;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _entrar() {
    FocusScope.of(context).unfocus();

    if (!_form.currentState!.validate()) return;

    setState(() {
      _error = null;
      _cargando = true;
    });

    try {
      final err = context.read<AppState>().login(
            _email.text.trim(),
            _pass.text,
          );

      if (!mounted) return;

      setState(() {
        _cargando = false;
        _error = err;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
        _error = 'Ocurrió un problema. Intenta nuevamente.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colores = theme.colorScheme;

    return Scaffold(
      backgroundColor: kFondo,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 28,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Encabezado de la aplicación.
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: kVerdeClaro,
                            borderRadius: BorderRadius.circular(26),
                          ),
                          child: const Icon(
                            Icons.medical_services_rounded,
                            size: 48,
                            color: kVerde,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'MediHora',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: kVerdeOscuro,
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tu salud, organizada y a tiempo.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: kTextoSecundario,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Tarjeta de inicio de sesión.
                  Card(
                    margin: EdgeInsets.zero,
                    elevation: 2,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                      side: const BorderSide(
                        color: Color(0xFFDCE7E1),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _form,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Bienvenido/a',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: kAzul,
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Inicia sesión para administrar tus medicamentos '
                              'y consultar tus horarios.',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: kTextoSecundario,
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),

                            const SizedBox(height: 28),

                            // Correo electrónico.
                            Text(
                              'Correo electrónico',
                              style: _estiloEtiqueta(),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [
                                AutofillHints.username,
                                AutofillHints.email,
                              ],
                              style: const TextStyle(
                                fontSize: 17,
                                color: kTinta,
                              ),
                              decoration: InputDecoration(
                                hintText: 'ejemplo@correo.com',
                                prefixIcon: const Icon(
                                  Icons.email_outlined,
                                  color: kVerde,
                                  size: 25,
                                ),
                                filled: true,
                                fillColor: kFondo,
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 18,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Ingresa tu correo electrónico';
                                }

                                if (!RegExp(
                                  r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                ).hasMatch(v.trim())) {
                                  return 'Escribe un correo válido';
                                }

                                return null;
                              },
                              onChanged: (_) {
                                if (_error != null) {
                                  setState(() => _error = null);
                                }
                              },
                            ),

                            const SizedBox(height: 22),

                            // Contraseña.
                            Text(
                              'Contraseña',
                              style: _estiloEtiqueta(),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _pass,
                              obscureText: !_mostrarPass,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [
                                AutofillHints.password,
                              ],
                              onFieldSubmitted: (_) => _entrar(),
                              style: const TextStyle(
                                fontSize: 17,
                                color: kTinta,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Ingresa tu contraseña',
                                prefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                  color: kVerde,
                                  size: 25,
                                ),
                                suffixIcon: IconButton(
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
                                    color: kTextoSecundario,
                                    size: 25,
                                  ),
                                ),
                                filled: true,
                                fillColor: kFondo,
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 18,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Ingresa tu contraseña';
                                }

                                if (v.length < 6) {
                                  return 'Debe tener al menos 6 caracteres';
                                }

                                return null;
                              },
                              onChanged: (_) {
                                if (_error != null) {
                                  setState(() => _error = null);
                                }
                              },
                            ),

                            const SizedBox(height: 12),

                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'La recuperación de contraseña '
                                        'aún no está disponible.',
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  '¿Olvidaste tu contraseña?',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            // Mensaje de error del inicio de sesión.
                            if (_error != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFCE8E9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: kRojo,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.error_outline_rounded,
                                      color: kRojo,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _error!,
                                        style: const TextStyle(
                                          color: kRojoOscuro,
                                          fontSize: 16,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 20),

                            // Botón principal.
                            SizedBox(
                              height: 56,
                              child: FilledButton.icon(
                                onPressed: _cargando ? null : _entrar,
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
                                        Icons.login_rounded,
                                        size: 24,
                                      ),
                                label: Text(
                                  _cargando
                                      ? 'Iniciando sesión...'
                                      : 'Iniciar sesión',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),
                            const Divider(),
                            const SizedBox(height: 16),

                            // Acceso al registro.
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment:
                                  WrapCrossAlignment.center,
                              children: [
                                const Text(
                                  '¿Aún no tienes cuenta?',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: kTinta,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const RegisterScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Crear cuenta',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Mensaje inferior.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.health_and_safety_outlined,
                        color: colores.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Una forma sencilla de cuidar tu rutina.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: kTextoSecundario,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextStyle _estiloEtiqueta() {
    return const TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: kTinta,
    );
  }
}
