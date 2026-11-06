import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';

/// Bitácora de actividad: solo consulta. La aplicación no ofrece ninguna
/// forma de editar o borrar entradas.
class BitacoraScreen extends StatefulWidget {
  const BitacoraScreen({super.key});

  @override
  State<BitacoraScreen> createState() => _BitacoraScreenState();
}

class _BitacoraScreenState extends State<BitacoraScreen> {
  String _categoria = 'Todas';
  int _dias = 30; // 0 = todo el historial

  String _fmt(DateTime f) =>
      '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year} '
      '${f.hour.toString().padLeft(2, '0')}:${f.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final corte = _dias == 0
        ? null
        : DateTime.now().subtract(Duration(days: _dias));

    final lista = app.miBitacora.where((e) {
      if (corte != null && e.fecha.isBefore(corte)) return false;
      if (_categoria != 'Todas' && e.accion.categoria != _categoria) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: kFondo,
      appBar: AppBar(
        title: const Text('Bitácora de actividad'),
        backgroundColor: kPrimario,
        foregroundColor: kBlanco,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _categoria,
                      isExpanded: true,
                      decoration: const InputDecoration(
                          labelText: 'Tipo de acción', isDense: true),
                      items: [
                        for (final c in ['Todas', ...kCategoriasBitacora])
                          DropdownMenuItem(value: c, child: Text(c)),
                      ],
                      onChanged: (v) => setState(() => _categoria = v ?? 'Todas'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _dias,
                      isExpanded: true,
                      decoration: const InputDecoration(
                          labelText: 'Periodo', isDense: true),
                      items: const [
                        DropdownMenuItem(value: 7, child: Text('7 días')),
                        DropdownMenuItem(value: 30, child: Text('30 días')),
                        DropdownMenuItem(value: 90, child: Text('90 días')),
                        DropdownMenuItem(value: 0, child: Text('Todo')),
                      ],
                      onChanged: (v) => setState(() => _dias = v ?? 30),
                    ),
                  ),
                ],
              ),
            ),
            if (!app.bitacoraIntegra)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE8E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kRojo),
                ),
                child: const Text(
                  'La verificación de integridad de la bitácora falló: algún '
                  'registro pudo haber sido alterado.',
                  style: TextStyle(color: kRojoOscuro),
                ),
              ),
            Expanded(
              child: lista.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay actividad para este filtro.',
                        style: TextStyle(color: kTextoSecundario),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: lista.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final e = lista[i];
                        final porOtro = e.actor != null &&
                            e.actor != app.current?.email;
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: kBlanco,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: kPrimarioClaro),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      e.accion.label,
                                      style: const TextStyle(
                                        color: kOscuro,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _fmt(e.fecha),
                                    style: const TextStyle(
                                        color: kTextoSecundario, fontSize: 12),
                                  ),
                                ],
                              ),
                              if (e.detalle != null) ...[
                                const SizedBox(height: 4),
                                Text(e.detalle!,
                                    style: const TextStyle(
                                        color: kTextoSecundario)),
                              ],
                              if (porOtro) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Realizada por ${app.nombreDe(e.actor!)}',
                                  style: const TextStyle(
                                      color: kNaranja, fontSize: 12),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
