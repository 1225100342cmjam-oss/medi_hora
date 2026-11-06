import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';

/// Formulario único de Configuración General. La configuración es PERSONAL:
/// se guarda por usuario y no se comparte con los cuidadores vinculados.
class AjustesGeneralesScreen extends StatefulWidget {
  const AjustesGeneralesScreen({super.key});

  @override
  State<AjustesGeneralesScreen> createState() => _AjustesGeneralesScreenState();
}

class _AjustesGeneralesScreenState extends State<AjustesGeneralesScreen> {
  late ConfiguracionGeneral _c;
  late final TextEditingController _minutos;
  late final TextEditingController _umbral;
  final _form = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final actual = context.read<AppState>().config;
    _c = ConfiguracionGeneral.fromJson(actual.toJson());
    _minutos = TextEditingController(text: '${_c.minutosPosposicion}');
    _umbral = TextEditingController(text: '${_c.umbralExistenciasBajas}');
  }

  @override
  void dispose() {
    _minutos.dispose();
    _umbral.dispose();
    super.dispose();
  }

  String? _entero(String? v, int min, int max) {
    final n = int.tryParse((v ?? '').trim());
    if (n == null || n < min || n > max) {
      return 'Ingresa un número entre $min y $max';
    }
    return null;
  }

  void _guardar() {
    if (!_form.currentState!.validate()) return;
    if (_c.canales.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un canal.')),
      );
      return;
    }
    _c.minutosPosposicion = int.parse(_minutos.text.trim());
    _c.umbralExistenciasBajas = int.parse(_umbral.text.trim());
    context.read<AppState>().guardarConfig(_c);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuración guardada.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kFondo,
      appBar: AppBar(
        title: const Text('Configuración general'),
        backgroundColor: kPrimario,
        foregroundColor: kBlanco,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kPrimarioClaro,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Esta configuración es personal: solo se aplica a tu cuenta '
                  'y no se comparte con tus cuidadores vinculados.',
                  style: TextStyle(color: kPrimarioOscuro, height: 1.4),
                ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _minutos,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Minutos de posposición',
                  helperText: 'Entre 1 y 120 minutos.',
                ),
                validator: (v) => _entero(v, 1, 120),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _umbral,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Umbral de existencias bajas (unidades)',
                  helperText:
                      'Se marca "bajo" cuando quedan estas unidades o menos.',
                ),
                validator: (v) => _entero(v, 0, 999),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: kZonasHorarias.contains(_c.zonaHoraria)
                    ? _c.zonaHoraria
                    : kZonasHorarias.first,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Zona horaria',
                  helperText:
                      'Los horarios se calculan hoy con la zona del dispositivo.',
                ),
                items: [
                  for (final z in kZonasHorarias)
                    DropdownMenuItem(value: z, child: Text(z)),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _c.zonaHoraria = v);
                },
              ),
              const SizedBox(height: 22),
              const Text(
                'Canales de notificación',
                style: TextStyle(
                    color: kOscuro, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              for (final canal in CanalNotificacion.values)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(canal.label),
                  value: _c.canales.contains(canal),
                  onChanged: (v) => setState(() {
                    if (v == true) {
                      _c.canales.add(canal);
                    } else {
                      _c.canales.remove(canal);
                    }
                  }),
                ),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Alertas de tomas omitidas'),
                value: _c.alertasTomasOmitidas,
                onChanged: (v) => setState(() => _c.alertasTomasOmitidas = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Alertas de existencias bajas'),
                value: _c.alertasExistenciasBajas,
                onChanged: (v) =>
                    setState(() => _c.alertasExistenciasBajas = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Ocultar el medicamento en la pantalla bloqueada'),
                subtitle: const Text(
                  'Las notificaciones usarán un mensaje discreto.',
                ),
                value: _c.ocultarMedicamentoEnBloqueo,
                onChanged: (v) =>
                    setState(() => _c.ocultarMedicamentoEnBloqueo = v),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 54,
                child: FilledButton(
                  onPressed: _guardar,
                  child: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
