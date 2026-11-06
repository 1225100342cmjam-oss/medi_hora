
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

  late final TextEditingController _correo =
      TextEditingController(text: widget.cuidador?.cuidadorEmail ?? '');

  late final Set<Permiso> _permisos = {
    ...(widget.cuidador?.permisos ?? <Permiso>{Permiso.consultarTomas}),
  };

  bool get _esEdicion => widget.cuidador != null;

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

    final String? err;
    if (!_esEdicion) {
      err = app.addCuidador(
        nombre,
        parentesco,
        contacto,
        cuidadorEmail: _correo.text,
        permisos: _permisos,
      );
    } else {
      err = app.updateCuidador(
        widget.cuidador!,
        nombre,
        parentesco,
        contacto,
        permisos: widget.cuidador!.soloContacto ? null : _permisos,
      );
    }

    if (err != null) {
      messenger.showSnackBar(SnackBar(content: Text(err)));
      return;
    }

    Navigator.pop(context);

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          !_esEdicion && _correo.text.trim().isNotEmpty
              ? 'Invitación enviada. El cuidador debe aceptarla.'
              : 'Cuidador guardado correctamente',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombre.dispose();
    _parentesco.dispose();
    _contacto.dispose();
    _correo.dispose();
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
                if (!_esEdicion || !widget.cuidador!.soloContacto) ...[
                  LabeledField(
                    label: 'Correo de su cuenta MediHora (opcional)',
                    hint: 'Si lo indicas, recibirá una invitación',
                    controller: _correo,
                    readOnly: _esEdicion,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      final t = (v ?? '').trim();
                      if (t.isEmpty) return null;
                      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)) {
                        return 'Escribe un correo válido';
                      }
                      return null;
                    },
                  ),
                  const Text(
                    'Permisos (solo lo que marques podrá ver o hacer):',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  for (final permiso in Permiso.values)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(permiso.label),
                      value: _permisos.contains(permiso),
                      onChanged: (v) => setState(() {
                        if (v == true) {
                          _permisos.add(permiso);
                        } else {
                          _permisos.remove(permiso);
                        }
                      }),
                    ),
                ],
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
