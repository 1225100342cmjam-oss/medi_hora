import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../theme.dart';
import 'med_form_screen.dart';
import 'widgets.dart';

/// DASHBOARD 3 · Cuidador
class DashboardCuidador extends StatelessWidget {
  final void Function(int) onGoTo;
  const DashboardCuidador({super.key, required this.onGoTo});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final pacientes = s.pacientes;

    return ListView(padding: const EdgeInsets.all(16), children: [
      DashHeader(
          saludo: 'Hola, ${s.current!.nombre}',
          rol: 'Supervisión de pacientes',
          icon: Icons.volunteer_activism),
      const SizedBox(height: 16),
      Text('Estado de pacientes', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      if (pacientes.isEmpty)
        const SizedBox(
            height: 180,
            child: EmptyState(icon: Icons.elderly, text: 'Aún no hay pacientes registrados'))
      else
        for (final p in pacientes)
          Builder(builder: (_) {
            final suyos = s.meds.where((m) => m.pacienteEmail == p.email).toList();
            final pend = suyos.where((m) => !m.tomado).length;
            return Card(
              elevation: 0,
              child: ListTile(
                leading: CircleAvatar(
                    backgroundColor: kRojo, child: Text(p.nombre[0].toUpperCase())),
                title: Text(p.nombre),
                subtitle: Text('${suyos.length} recordatorios · $pend pendientes'),
                trailing: Icon(pend == 0 ? Icons.check_circle : Icons.warning_amber,
                    color: pend == 0 ? Colors.green : Colors.orange),
              ),
            );
          }),
      const SizedBox(height: 12),
      FilledButton.icon(
        icon: const Icon(Icons.add_alarm),
        label: const Text('Programar medicamento'),
        onPressed: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => const MedFormScreen())),
      ),
    ]);
  }
}
