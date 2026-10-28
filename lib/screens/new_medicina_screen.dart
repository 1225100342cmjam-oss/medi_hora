
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';

class NewMedicinaScreen extends StatefulWidget {
  final Medicamento? med;

  const NewMedicinaScreen({
    super.key,
    this.med,
  });

  @override
  State<NewMedicinaScreen> createState() => _NewMedicinaScreenState();
}

class _NewMedicinaScreenState extends State<NewMedicinaScreen> {
  final _form = GlobalKey<FormState>();

  late final TextEditingController _nombre =
      TextEditingController(text: widget.med?.nombre ?? '');

  late final TextEditingController _dosis =
      TextEditingController(text: widget.med?.dosis ?? '');

  late final TextEditingController _hora =
      TextEditingController(text: widget.med?.hora ?? '');

  late final TextEditingController _info =
      TextEditingController(text: widget.med?.info ?? '');

  late String? _paciente = widget.med?.pacienteEmail;

  bool _guardando = false;

  bool get _esEdicion => widget.med != null;

  String? _requerido(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    return null;
  }

  Future<void> _seleccionarHora() async {
    TimeOfDay inicial = TimeOfDay.now();

    final partes = _hora.text.split(':');

    if (partes.length == 2) {
      final hora = int.tryParse(partes[0]);
      final minuto = int.tryParse(partes[1]);

      if (hora != null &&
          minuto != null &&
          hora >= 0 &&
          hora <= 23 &&
          minuto >= 0 &&
          minuto <= 59) {
        inicial = TimeOfDay(hour: hora, minute: minuto);
      }
    }

    final seleccionada = await showTimePicker(
      context: context,
      initialTime: inicial,
      helpText: 'Selecciona la hora del medicamento',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (seleccionada == null || !mounted) return;

    setState(() {
      _hora.text =
          '${seleccionada.hour.toString().padLeft(2, '0')}:'
          '${seleccionada.minute.toString().padLeft(2, '0')}';
    });
  }

  void _guardar() {
    if (_guardando) return;

    FocusScope.of(context).unfocus();

    if (!_form.currentState!.validate()) return;

    final app = context.read<AppState>();
    final usuario = app.current;

    if (usuario == null) {
      _mensaje('No hay una sesión activa.');
      return;
    }

    final esPaciente = usuario.rol == Rol.paciente;
    final emailPaciente = esPaciente ? usuario.email : _paciente;

    if (emailPaciente == null || emailPaciente.isEmpty) {
      _mensaje('Selecciona el paciente al que pertenece el medicamento.');
      return;
    }

    setState(() => _guardando = true);

    try {
      if (_esEdicion) {
        app.updateMed(
          widget.med!,
          _nombre.text.trim(),
          _dosis.text.trim(),
          _hora.text,
          _info.text.trim(),
        );
      } else {
        app.addMed(
          _nombre.text.trim(),
          _dosis.text.trim(),
          _hora.text,
          _info.text.trim(),
          emailPaciente,
        );
      }

      if (!mounted) return;

      // Se toma el messenger antes de cerrar la pantalla.
      final messenger = ScaffoldMessenger.of(context);
      final texto = _esEdicion
          ? 'Medicamento actualizado correctamente.'
          : 'Medicamento guardado correctamente.';

      Navigator.pop(context);

      messenger.showSnackBar(
        SnackBar(
          content: Text(texto),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _guardando = false);
      _mensaje('No se pudo guardar el medicamento. Inténtalo de nuevo.');
    }
  }

  void _mensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _nombre.dispose();
    _dosis.dispose();
    _hora.dispose();
    _info.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final usuario = app.current;

    if (usuario == null) {
      return const Scaffold(
        body: Center(
          child: Text('Inicia sesión para administrar medicamentos.'),
        ),
      );
    }

    final esPaciente = usuario.rol == Rol.paciente;

    return Scaffold(
      backgroundColor: kFondo,
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar medicamento' : 'Nuevo medicamento'),
        backgroundColor: kPrimario,
        foregroundColor: kBlanco,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kPrimario,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: kBlanco.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        _esEdicion
                            ? Icons.edit_note_rounded
                            : Icons.medication_rounded,
                        color: kBlanco,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _esEdicion
                                ? 'Actualiza los datos'
                                : 'Organiza tu tratamiento',
                            style: const TextStyle(
                              color: kBlanco,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _esEdicion
                                ? 'Modifica la información del medicamento.'
                                : 'Registra los datos para tenerlos a la mano.',
                            style: TextStyle(
                              color: kBlanco.withValues(alpha: 0.88),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                'Información del medicamento',
                style: TextStyle(
                  color: kOscuro,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: kBlanco,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: kPrimarioClaro),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!esPaciente && !_esEdicion) ...[
                      _etiqueta('Paciente'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: app.pacientes.any(
                          (p) => p.email == _paciente,
                        )
                            ? _paciente
                            : null,
                        isExpanded: true,
                        decoration: _decoracion(
                          'Selecciona un paciente',
                          Icons.person_outline_rounded,
                        ),
                        items: [
                          for (final paciente in app.pacientes)
                            DropdownMenuItem(
                              value: paciente.email,
                              child: Text(
                                paciente.nombre,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: (valor) {
                          setState(() => _paciente = valor);
                        },
                        validator: (valor) {
                          if (valor == null || valor.isEmpty) {
                            return 'Selecciona un paciente';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                    ],

                    _etiqueta('Nombre del medicamento'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nombre,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      validator: _requerido,
                      decoration: _decoracion(
                        'Ej. Paracetamol',
                        Icons.medication_outlined,
                      ),
                    ),

                    const SizedBox(height: 20),

                    _etiqueta('Dosis indicada'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _dosis,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      validator: _requerido,
                      decoration: _decoracion(
                        'Ej. 1 tableta de 500 mg',
                        Icons.local_hospital_outlined,
                      ),
                    ),

                    const SizedBox(height: 20),

                    _etiqueta('Horario del recordatorio'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _hora,
                      readOnly: true,
                      validator: _requerido,
                      onTap: _seleccionarHora,
                      decoration: _decoracion(
                        'Selecciona una hora',
                        Icons.access_time_rounded,
                      ).copyWith(
                        suffixIcon: const Icon(
                          Icons.schedule_rounded,
                          color: kPrimario,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    _etiqueta('Información adicional (opcional)'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _info,
                      textCapitalization: TextCapitalization.sentences,
                      minLines: 3,
                      maxLines: 5,
                      decoration: _decoracion(
                        'Indicaciones o notas adicionales',
                        Icons.notes_rounded,
                      ).copyWith(
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _guardando ? null : _guardar,
                  icon: _guardando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: kBlanco,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline_rounded),
                  label: Text(
                    _guardando
                        ? 'Guardando...'
                        : _esEdicion
                            ? 'Guardar cambios'
                            : 'Guardar medicamento',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimario,
                    foregroundColor: kBlanco,
                    disabledBackgroundColor: kPrimarioClaro,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: _guardando
                      ? null
                      : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kPrimario,
                    side: const BorderSide(color: kPrimario),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _etiqueta(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        color: kOscuro,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  InputDecoration _decoracion(String texto, IconData icono) {
    return InputDecoration(
      hintText: texto,
      hintStyle: const TextStyle(
        color: kTextoSecundario,
        fontSize: 13,
      ),
      prefixIcon: Icon(icono, color: kPrimario),
      filled: true,
      fillColor: kFondo,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kPrimarioClaro),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kPrimarioClaro),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: kPrimario,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kRojo),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: kRojo,
          width: 1.5,
        ),
      ),
    );
  }
}
