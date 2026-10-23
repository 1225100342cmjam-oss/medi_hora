import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _pass2 = TextEditingController();
  Rol _rol = Rol.paciente;
  String? _error;

  void _registrar() {
    if (!_form.currentState!.validate()) return;
    final err = context.read<AppState>().register(_nombre.text, _email.text, _pass.text, _rol);
    if (err != null) {
      setState(() => _error = err);
    } else {
      Navigator.pop(context); // AuthGate ya muestra el dashboard
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _form,
          child: Column(children: [
            TextFormField(
              controller: _nombre,
              decoration: const InputDecoration(
                  labelText: 'Nombre completo', prefixIcon: Icon(Icons.person_outline)),
              validator: (v) =>
                  (v == null || v.trim().length < 3) ? 'Ingresa tu nombre (mín. 3 letras)' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                  labelText: 'Correo', prefixIcon: Icon(Icons.email_outlined)),
              validator: (v) => (v == null ||
                      !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim()))
                  ? 'Correo no válido'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _pass,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: 'Contraseña', prefixIcon: Icon(Icons.lock_outline)),
              validator: (v) => (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _pass2,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: 'Confirmar contraseña', prefixIcon: Icon(Icons.lock_reset)),
              validator: (v) => v != _pass.text ? 'Las contraseñas no coinciden' : null,
            ),
            const SizedBox(height: 18),
            const Align(
                alignment: Alignment.centerLeft,
                child: Text('Selecciona tu rol',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            const SizedBox(height: 8),
            for (final r in Rol.values)
              RadioListTile<Rol>(
                value: r,
                groupValue: _rol,
                onChanged: (v) => setState(() => _rol = v!),
                title: Text(r.label),
                subtitle: Text(switch (r) {
                  Rol.admin => 'Gestiona usuarios y todos los recordatorios',
                  Rol.paciente => 'Recibe y confirma sus medicamentos',
                  Rol.cuidador => 'Supervisa a los pacientes a su cargo',
                }),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _registrar, child: const Text('Registrarme')),
          ]),
        ),
      ),
    );
  }
}
