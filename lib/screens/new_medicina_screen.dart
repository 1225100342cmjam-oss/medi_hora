import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';
import 'ui.dart';

/// Pantalla "NewMedicina" (agregar / editar).
class NewMedicinaScreen extends StatefulWidget {
  final Medicamento? med;
  const NewMedicinaScreen({super.key, this.med});
  @override
  State<NewMedicinaScreen> createState() => _NewMedicinaScreenState();
}

class _NewMedicinaScreenState extends State<NewMedicinaScreen> {
  final _form = GlobalKey<FormState>();
  late final _nombre = TextEditingController(text: widget.med?.nombre);
  late final _dosis = TextEditingController(text: widget.med?.dosis);
  late final _hora = TextEditingController(text: widget.med?.hora);
  late final _info = TextEditingController(text: widget.med?.info);
  late String? _paciente = widget.med?.pacienteEmail;

  String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null;

  Future<void> _pickHora() async {
    TimeOfDay initial = TimeOfDay.now();
    if (_hora.text.contains(':')) {
      final p = _hora.text.split(':');
      initial = TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
    }
    final t = await showTimePicker(context: context, initialTime: initial);
    if (t != null) {
      _hora.text =
          '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    }
  }

  void _guardar() {
    if (!_form.currentState!.validate()) return;
    final s = context.read<AppState>();
    final esPaciente = s.current!.rol == Rol.paciente;
    if (widget.med == null) {
      s.addMed(_nombre.text, _dosis.text, _hora.text, _info.text,
          esPaciente ? s.current!.email : _paciente!);
    } else {
      s.updateMed(widget.med!, _nombre.text, _dosis.text, _hora.text, _info.text);
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Medicina guardada ✔')));
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final esPaciente = s.current!.rol == Rol.paciente;

    return RedPage(
      title: widget.med == null ? 'Nueva Medicina' : 'Editar Medicina',
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: PinkCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (!esPaciente && widget.med == null) ...[
                const Text('Paciente', style: TextStyle(fontSize: 15)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _paciente,
                  dropdownColor: const Color(0xFFFCF3F3),
                  hint: const Text('Selecciona un paciente'),
                  items: [
                    for (final p in s.pacientes)
                      DropdownMenuItem(value: p.email, child: Text(p.nombre)),
                  ],
                  onChanged: (v) => setState(() => _paciente = v),
                  validator: (v) => v == null ? 'Selecciona un paciente' : null,
                ),
                const SizedBox(height: 16),
              ],
              LabeledField(
                  label: 'Nombre',
                  hint: 'Inserta el nombre del medicamento',
                  controller: _nombre,
                  validator: _req),
              LabeledField(
                  label: 'Dosis', hint: 'Ej: 2 tabletas', controller: _dosis, validator: _req),
              LabeledField(
                label: 'Horario',
                hint: 'Ej: 02:00',
                controller: _hora,
                readOnly: true,
                onTap: _pickHora,
                validator: _req,
              ),
              LabeledField(
                label: 'Información adicional',
                hint: 'Ingrese algún dato extra',
                controller: _info,
                maxLines: 3,
              ),
              DarkButton('Guardar', onPressed: _guardar),
            ]),
          ),
        ),
      ),
    );
  }
}
