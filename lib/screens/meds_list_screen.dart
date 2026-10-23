import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import 'med_form_screen.dart';
import 'widgets.dart';

/// LISTA PRINCIPAL · datos dinámicos + estado vacío
class MedsListScreen extends StatelessWidget {
  const MedsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final meds = s.visibles;
    final esPaciente = s.current!.rol == Rol.paciente;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kRojo,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
        onPressed: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => const MedFormScreen())),
      ),
      body: meds.isEmpty
          ? const EmptyState(
              icon: Icons.medication_outlined, text: 'No hay elementos.\nToca "Nuevo" para agregar.')
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
              itemCount: meds.length,
              itemBuilder: (_, i) {
                final m = meds[i];
                return Dismissible(
                  key: ValueKey(m.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.red.shade300, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => context.read<AppState>().deleteMed(m),
                  child: Card(
                    elevation: 0,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: m.tomado ? Colors.green.shade100 : Colors.red.shade50,
                        child: Icon(m.tomado ? Icons.check : Icons.alarm,
                            color: m.tomado ? Colors.green : kRojo),
                      ),
                      title: Text(m.nombre,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: m.tomado ? TextDecoration.lineThrough : null)),
                      subtitle: Text(
                          '${m.dosis} · ${m.hora}${esPaciente ? '' : '\nPaciente: ${s.nombreDe(m.pacienteEmail)}'}'),
                      isThreeLine: !esPaciente,
                      trailing: Checkbox(
                        value: m.tomado,
                        activeColor: kRojo,
                        onChanged: (_) => context.read<AppState>().toggleTomado(m),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
