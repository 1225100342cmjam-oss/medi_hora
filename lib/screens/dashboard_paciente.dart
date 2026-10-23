import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../theme.dart';
import 'med_form_screen.dart';
import 'widgets.dart';

/// DASHBOARD 2 · Paciente
class DashboardPaciente extends StatelessWidget {
  final void Function(int) onGoTo;
  const DashboardPaciente({super.key, required this.onGoTo});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final meds = s.visibles;
    final pendientes = meds.where((m) => !m.tomado).toList();
    final proxima = pendientes.isEmpty ? null : pendientes.first;
    final progreso = meds.isEmpty ? 0.0 : (meds.length - pendientes.length) / meds.length;

    return ListView(padding: const EdgeInsets.all(16), children: [
      DashHeader(
          saludo: 'Hola, ${s.current!.nombre}',
          rol: 'Tu agenda de medicamentos',
          icon: Icons.favorite),
      const SizedBox(height: 16),
      Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: proxima == null
              ? const Text('🎉 No tienes tomas pendientes', style: TextStyle(fontSize: 16))
              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('PRÓXIMA TOMA',
                      style: TextStyle(color: kRojo, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(proxima.nombre,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text('${proxima.dosis} · ${proxima.hora}'),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('Marcar como tomado'),
                    onPressed: () => context.read<AppState>().toggleTomado(proxima),
                  ),
                ]),
        ),
      ),
      const SizedBox(height: 12),
      Text('Progreso del día', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 6),
      LinearProgressIndicator(
          value: progreso, minHeight: 10, borderRadius: BorderRadius.circular(8), color: kRojo),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(
            child: StatCard(
                icon: Icons.pending_actions, label: 'Pendientes', value: '${pendientes.length}')),
        const SizedBox(width: 10),
        Expanded(
            child: StatCard(
                icon: Icons.check_circle,
                label: 'Tomados',
                value: '${meds.length - pendientes.length}')),
      ]),
      const SizedBox(height: 16),
      OutlinedButton.icon(
        icon: const Icon(Icons.add_alarm),
        label: const Text('Agregar recordatorio'),
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
        onPressed: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => const MedFormScreen())),
      ),
    ]);
  }
}
