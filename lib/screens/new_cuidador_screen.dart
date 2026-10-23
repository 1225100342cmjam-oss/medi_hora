import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';
import 'ui.dart';

/// Pantalla "NewCuidador" (agregar / editar).
class NewCuidadorScreen extends StatefulWidget {
  final Cuidador? cuidador;
  const NewCuidadorScreen({super.key, this.cuidador});
  @override
  State<NewCuidadorScreen> createState() => _NewCuidadorScreenState();
}

class _NewCuidadorScreenState extends State<NewCuidadorScreen> {
  final _form = GlobalKey<FormState>();
  late final _nombre = TextEditingController(text: widget.cuidador?.nombre);
  late final _parentesco = TextEditingController(text: widget.cuidador?.parentesco);
  late final _contacto = TextEditingController(text: widget.cuidador?.contacto);

  String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null;

  void _guardar() {
    if (!_form.currentState!.validate()) return;
    final s = context.read<AppState>();
    if (widget.cuidador == null) {
      s.addCuidador(_nombre.text, _parentesco.text, _contacto.text);
    } else {
      s.updateCuidador(widget.cuidador!, _nombre.text, _parentesco.text, _contacto.text);
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Cuidador guardado ✔')));
  }

  @override
  Widget build(BuildContext context) {
    return RedPage(
      title: widget.cuidador == null ? 'Agregar cuidador' : 'Editar cuidador',
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: PinkCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              LabeledField(
                  label: 'Nombre',
                  hint: 'Inserta el nombre de la persona',
                  controller: _nombre,
                  validator: _req),
              LabeledField(
                  label: 'Parentesco',
                  hint: 'Ej: Mamá, papá y/o hijo',
                  controller: _parentesco,
                  validator: _req),
              LabeledField(
                  label: 'Contacto',
                  hint: 'Información de contacto',
                  controller: _contacto,
                  keyboardType: TextInputType.phone,
                  validator: _req),
              DarkButton('Guardar', onPressed: _guardar),
            ]),
          ),
        ),
      ),
    );
  }
}
