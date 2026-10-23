import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import 'confirmacion_screen.dart';
import 'new_medicina_screen.dart';
import 'ui.dart';

/// Fila de medicina: editar · nombre/hora · chip de estado.
class MedTile extends StatelessWidget {
  final Medicamento med;
  final bool mostrarPaciente;
  const MedTile({super.key, required this.med, this.mostrarPaciente = false});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final tomado = s.tomadoHoy(med);

    return Dismissible(
      key: ValueKey(med.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red.shade300,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async =>
          await showDialog<bool>(
            context: context,
            builder: (c) => AlertDialog(
              title: const Text('¿Eliminar medicina?'),
              content: Text(med.nombre),
              actions: [
                TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
                TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Eliminar')),
              ],
            ),
          ) ??
          false,
      onDismissed: (_) => context.read<AppState>().deleteMed(med),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          InkWell(
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => NewMedicinaScreen(med: med))),
            child: const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(Icons.edit_outlined, size: 22, color: kTinta),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${med.nombre} · ${med.dosis}',
                  style: const TextStyle(fontSize: 15), overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(fmtHora(med.hora),
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
              if (mostrarPaciente)
                Text(s.nombreDe(med.pacienteEmail),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
            ]),
          ),
          StatusChip(
            label: tomado ? 'Tomado' : 'Pendiente',
            color: tomado ? kVerde : kNaranja,
            onTap: () {
              final st = context.read<AppState>();
              if (tomado) {
                st.desmarcar(med);
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Toma desmarcada')));
              } else {
                final racha = st.marcarTomado(med);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => ConfirmacionScreen(racha: racha)));
              }
            },
          ),
        ]),
      ),
    );
  }
}

/// Lista con estado vacío, reutilizable en los dashboards.
class MedList extends StatelessWidget {
  final List<Medicamento> meds;
  final bool mostrarPaciente;
  const MedList({super.key, required this.meds, this.mostrarPaciente = false});

  @override
  Widget build(BuildContext context) {
    if (meds.isEmpty) {
      return const EmptyText('No hay elementos.\nToca "+" para agregar una medicina.');
    }
    return ListView.builder(
      itemCount: meds.length,
      itemBuilder: (_, i) => MedTile(med: meds[i], mostrarPaciente: mostrarPaciente),
    );
  }
}
