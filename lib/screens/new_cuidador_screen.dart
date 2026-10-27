
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';
import 'ui.dart';

/// Pantalla para agregar o editar un cuidador.
class NewCuidadorScreen extends StatefulWidget {
  final Cuidador? cuidador;

  const NewCuidadorScreen({
    super.key,
    this.cuidador,
  });

  @override
  State<NewCuidadorScreen> createState() => _NewCuidadorScreenState();
}

class _NewCuidadorScreenState extends State<NewCuidadorScreen> {
  final _form = GlobalKey<FormState>();

  late final TextEditingController _nombre =
      TextEditingController(text: widget.cuidador?.nombre);

  late final TextEditingController _parentesco =
      TextEditingController(text: widget.cuidador?.parentesco);

  late final TextEditingController _contacto =
      TextEditingController(text: widget.cuidador?.contacto);

  String? _req(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Campo obligatorio';
    }
    return null;
  }

  void _guardar() {
    if (!_form.currentState!.validate()) return;

    final app = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);

    final nombre = _nombre.text.trim();
    final parentesco = _parentesco.text.trim();
    final contacto = _contacto.text.trim();

    if (widget.cuidador == null) {
      app.addCuidador(nombre, parentesco, contacto);
    } else {
      app.updateCuidador(
        widget.cuidador!,
        nombre,
        parentesco,
        contacto,
      );
    }

    Navigator.pop(context);

    messenger.showSnackBar(
      const SnackBar(
        content: Text('Cuidador guardado correctamente'),
      ),
    );
  }

  @override
  void dispose() {
    _nombre.dispose();
    _parentesco.dispose();
    _contacto.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RedPage(
      title: widget.cuidador == null
          ? 'Agregar cuidador'
          : 'Editar cuidador',
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: PinkCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LabeledField(
                  label: 'Nombre',
                  hint: 'Escribe el nombre de la persona',
                  controller: _nombre,
                  validator: _req,
                ),
                LabeledField(
                  label: 'Parentesco',
                  hint: 'Ej. mamá, papá, hijo u otro',
                  controller: _parentesco,
                  validator: _req,
                ),
                LabeledField(
                  label: 'Contacto',
                  hint: 'Número telefónico o información de contacto',
                  controller: _contacto,
                  keyboardType: TextInputType.phone,
                  validator: _req,
                ),
                const SizedBox(height: 16),
                DarkButton(
                  'Guardar',
                  onPressed: _guardar,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
