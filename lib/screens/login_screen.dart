import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../theme.dart';
import 'register_screen.dart';
import 'ui.dart';

/// Pantalla "Login".
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

  void _entrar() {
    if (!_form.currentState!.validate()) return;
    final err = context.read<AppState>().login(_email.text, _pass.text);
    if (err != null) setState(() => _error = err);
  }

  @override
  Widget build(BuildContext context) {
    const link = TextStyle(decoration: TextDecoration.underline, fontSize: 15);
    return Scaffold(
      backgroundColor: kRojo,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(30, 40, 30, 24),
          child: Form(
            key: _form,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('MediHora', style: slab(20)),
                  const SizedBox(height: 10),
                  Text('Inicio de sesión', style: slab(20)),
                ]),
              ),
              const SizedBox(height: 44),
              PinkCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  LabeledField(
                    label: 'Correo:',
                    hint: 'Ej : mariana@gmail.com',
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
                      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
                        return 'Correo no válido';
                      }
                      return null;
                    },
                  ),
                  LabeledField(
                    label: 'Contraseña:',
                    hint: 'Ingresa tu contraseña secreta',
                    controller: _pass,
                    obscure: true,
                    validator: (v) =>
                        (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(_error!, style: const TextStyle(color: Color(0xFF8B0000))),
                    ),
                  DarkButton('Iniciar sesión', onPressed: _entrar),
                  const SizedBox(height: 18),
                  GestureDetector(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Función no disponible por ahora'))),
                    child: const Text('Forgot password?', style: link),
                  ),
                  const SizedBox(height: 40),
                  Row(children: [
                    const Text('No tienes cuenta? ', style: TextStyle(fontSize: 15)),
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                      child: const Text(' Registrarse', style: link),
                    ),
                  ]),
                  const SizedBox(height: 8),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
