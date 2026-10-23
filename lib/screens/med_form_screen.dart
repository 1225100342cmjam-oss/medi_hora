import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';

/// FORMULARIO DEL DOMINIO · nuevo recordatorio de medicamento
class MedFormScreen extends StatefulWidget {
  const MedFormScreen({super.key});
  @override
  State<MedFormScreen> createState() => _MedFormScreenState();
}

class _MedFormScreenState extends State<MedFormScreen> {
  final _form = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _dosis = TextEditingController();
  TimeOfDay? _hora;
  String? _paciente;

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickHora() async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t != null) setState(() => _hora = t);
  }

  void _guardar() {
    final s = context.read<AppState>();
    final esPaciente = s.current!.rol == Rol.paciente;
    if (!_form.currentState!.validate()) return;
    if (_hora == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Selecciona la hora de la toma')));
      return;
    }
    s.addMed(_nombre.text, _dosis.text, _fmt(_hora!),
        esPaciente ? s.current!.email : _paciente!);
    Navigator.pop(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Recordatorio guardado ✔')));
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final esPaciente = s.current!.rol == Rol.paciente;

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo recordatorio')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _form,
          child: Column(children: [
            TextFormField(
              controller: _nombre,
              decoration: const InputDecoration(
                  labelText: 'Medicamento', prefixIcon: Icon(Icons.medication)),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _dosis,
              decoration: const InputDecoration(
                  labelText: 'Dosis (ej. 500 mg, 1 tableta)', prefixIcon: Icon(Icons.scale)),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
            ),
            const SizedBox(height: 14),
            if (!esPaciente) ...[
              DropdownButtonFormField<String>(
                value: _paciente,
                decoration: const InputDecoration(
                    labelText: 'Paciente', prefixIcon: Icon(Icons.elderly)),
                items: [
                  for (final p in s.pacientes)
                    DropdownMenuItem(value: p.email, child: Text(p.nombre)),
                ],
                onChanged: (v) => setState(() => _paciente = v),
                validator: (v) => v == null ? 'Selecciona un paciente' : null,
              ),
              if (s.pacientes.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text('Aún no hay pacientes registrados.',
                      style: TextStyle(color: Colors.orange)),
                ),
              const SizedBox(height: 14),
            ],
            InkWell(
              onTap: _pickHora,
              child: InputDecorator(
                decoration: const InputDecoration(
                    labelText: 'Hora de la toma', prefixIcon: Icon(Icons.access_time)),
                child: Text(_hora == null ? 'Toca para elegir' : _fmt(_hora!)),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
                icon: const Icon(Icons.save), label: const Text('Guardar'), onPressed: _guardar),
          ]),
        ),
      ),
    );
  }
}
