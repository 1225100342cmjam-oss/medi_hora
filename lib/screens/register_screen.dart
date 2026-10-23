import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';
import 'ui.dart';

/// Registro con selección de rol.
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

  void _registrar() {
    if (!_form.currentState!.validate()) return;
    final err = context
        .read<AppState>()
        .register(_nombre.text, int.parse(_edad.text), _email.text, _pass.text, _rol);
    if (err != null) {
      setState(() => _error = err);
    } else {
      Navigator.pop(context); // AuthGate ya muestra el dashboard del rol
    }
  }

  @override
  Widget build(BuildContext context) {
    return RedPage(
      title: 'Crear cuenta',
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: PinkCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              LabeledField(
                label: 'Nombre',
                hint: 'Inserta tu nombre completo',
                controller: _nombre,
                validator: (v) =>
                    (v == null || v.trim().length < 3) ? 'Ingresa tu nombre (mín. 3 letras)' : null,
              ),
              LabeledField(
                label: 'Edad',
                hint: 'Ej: 45',
                controller: _edad,
                keyboardType: TextInputType.number,
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  return (n == null || n < 1 || n > 120) ? 'Edad no válida' : null;
                },
              ),
              LabeledField(
                label: 'Correo',
                hint: 'Ej : mariana@gmail.com',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    (v == null || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim()))
                        ? 'Correo no válido'
                        : null,
              ),
              LabeledField(
                label: 'Contraseña',
                hint: 'Mínimo 6 caracteres',
                controller: _pass,
                obscure: true,
                validator: (v) => (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
              ),
              LabeledField(
                label: 'Confirmar contraseña',
                hint: 'Repite tu contraseña',
                controller: _pass2,
                obscure: true,
                validator: (v) => v != _pass.text ? 'Las contraseñas no coinciden' : null,
              ),
              const Text('Rol', style: TextStyle(fontSize: 15)),
              const SizedBox(height: 6),
              DropdownButtonFormField<Rol>(
                value: _rol,
                dropdownColor: const Color(0xFFFCF3F3),
                items: [
                  for (final r in Rol.values) DropdownMenuItem(value: r, child: Text(r.label)),
                ],
                onChanged: (v) => setState(() => _rol = v!),
              ),
              const SizedBox(height: 6),
              Text(
                switch (_rol) {
                  Rol.admin => 'Gestiona usuarios y todas las medicinas.',
                  Rol.paciente => 'Recibe recordatorios y confirma sus tomas.',
                  Rol.cuidador => 'Supervisa a los pacientes.',
                },
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(_error!, style: const TextStyle(color: Color(0xFF8B0000))),
                ),
              const SizedBox(height: 18),
              DarkButton('Registrarme', onPressed: _registrar),
            ]),
          ),
        ),
      ),
    );
  }
}
