
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

  // Presentaciones comunes para facilitar el registro. No son recomendaciones
  // de tratamiento: la presentación y cantidad deben coincidir con la receta.
  static const Map<String, List<String>> _presentacionesComunes = {
    'paracetamol': ['Tableta de 500 mg', 'Tableta de 650 mg', 'Suspensión de 160 mg/5 ml'],
    'acetaminofen': ['Tableta de 500 mg', 'Tableta de 650 mg', 'Suspensión de 160 mg/5 ml'],
    'ibuprofeno': ['Tableta de 200 mg', 'Tableta de 400 mg', 'Suspensión de 100 mg/5 ml'],
    'loratadina': ['Tableta de 10 mg', 'Jarabe de 1 mg/ml'],
    'cetirizina': ['Tableta de 10 mg', 'Solución de 1 mg/ml'],
    'omeprazol': ['Cápsula de 20 mg', 'Cápsula de 40 mg'],
    'amoxicilina': ['Cápsula de 500 mg', 'Suspensión de 250 mg/5 ml', 'Suspensión de 400 mg/5 ml'],
    'metformina': ['Tableta de 500 mg', 'Tableta de 850 mg', 'Tableta de 1000 mg'],
    'losartan': ['Tableta de 50 mg', 'Tableta de 100 mg'],
    'losartán': ['Tableta de 50 mg', 'Tableta de 100 mg'],
    'naproxeno': ['Tableta de 250 mg', 'Tableta de 500 mg'],
    'azitromicina': ['Tableta de 500 mg', 'Suspensión de 200 mg/5 ml'],
  };

  List<String> get _sugerenciasDosis {
    final nombre = _nombre.text.trim().toLowerCase();
    for (final entrada in _presentacionesComunes.entries) {
      if (nombre == entrada.key) return entrada.value;
    }
    return const ['Según receta médica', 'Otra presentación indicada en la receta'];
  }


  late final TextEditingController _nombre =
      TextEditingController(text: widget.med?.nombre ?? '');

  late final TextEditingController _dosis =
      TextEditingController(text: widget.med?.dosis ?? '');

  late final TextEditingController _hora =
      TextEditingController(text: widget.med?.hora ?? '');

  // La cantidad se conserva dentro del campo de información existente para
  // mantener compatibilidad con el modelo actual de Medicamento.
  static final RegExp _patronTabletas =
      RegExp(r'^Tabletas por caja: (\d+)\s*$', multiLine: true);

  static String _leerTabletasCaja(String? info) {
    final coincidencia = _patronTabletas.firstMatch(info ?? '');
    return coincidencia?.group(1) ?? '';
  }

  static String _limpiarInfo(String? info) {
    return (info ?? '')
        .replaceAll(_patronTabletas, '')
        .trim();
  }

  late final TextEditingController _tabletasCaja =
      TextEditingController(text: _leerTabletasCaja(widget.med?.info));

  late final TextEditingController _info =
      TextEditingController(text: _limpiarInfo(widget.med?.info));

  String _infoConCantidadCaja() {
    final notas = _info.text.trim();
    final cantidad = _tabletasCaja.text.trim();
    final lineaCantidad = 'Tabletas por caja: $cantidad';
    return notas.isEmpty ? lineaCantidad : '$notas\n$lineaCantidad';
  }

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
          _infoConCantidadCaja(),
        );
      } else {
        app.addMed(
          _nombre.text.trim(),
          _dosis.text.trim(),
          _hora.text,
          _infoConCantidadCaja(),
          emailPaciente,
        );
      }

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _esEdicion
                ? 'Medicamento actualizado correctamente.'
                : 'Medicamento guardado correctamente.',
          ),
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
    _tabletasCaja.dispose();
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
                      onChanged: (_) => setState(() {}),
                      decoration: _decoracion(
                        'Ej. Paracetamol',
                        Icons.medication_outlined,
                      ),
                    ),

                    const SizedBox(height: 20),

                    _etiqueta('Presentaciones comunes'),
                    const SizedBox(height: 6),
                    Text(
                      'Selecciona una presentación solo si coincide con la receta médica.',
                      style: TextStyle(
                        color: kTextoSecundario,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final sugerencia in _sugerenciasDosis)
                          ActionChip(
                            label: Text(sugerencia),
                            backgroundColor: _dosis.text == sugerencia
                                ? kPrimarioClaro
                                : kFondo,
                            side: BorderSide(
                              color: _dosis.text == sugerencia
                                  ? kPrimario
                                  : kPrimarioClaro,
                            ),
                            onPressed: () {
                              setState(() {
                                _dosis.text = sugerencia;
                              });
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _etiqueta('Dosis / presentación indicada en la receta'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _dosis,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      validator: _requerido,
                      decoration: _decoracion(
                        'Escribe exactamente lo indicado por el profesional',
                        Icons.local_hospital_outlined,
                      ),
                    ),

                    const SizedBox(height: 20),

                    _etiqueta('Cantidad de tabletas por caja'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _tabletasCaja,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: (valor) {
                        final cantidad = int.tryParse((valor ?? '').trim());
                        if (cantidad == null || cantidad <= 0) {
                          return 'Escribe cuántas tabletas contiene la caja';
                        }
                        return null;
                      },
                      decoration: _decoracion(
                        'Ej. 20 tabletas',
                        Icons.inventory_2_outlined,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Registra la cantidad que indica el empaque. Si es una presentación distinta, anótala en información adicional.',
                      style: TextStyle(
                        color: kTextoSecundario,
                        fontSize: 12,
                        height: 1.35,
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

              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFFD7A3)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, color: Color(0xFF9A5B00)),
                    SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'MediHora solo organiza los datos. No calcula ni recomienda dosis. '
                        'Confirma medicamento, concentración y cantidad con la receta o un profesional de salud.',
                        style: TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF704500)),
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
