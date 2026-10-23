import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';
import 'med_form_screen.dart';
import 'widgets.dart';

/// DASHBOARD 1 · Administrador
class DashboardAdmin extends StatelessWidget {
  final void Function(int) onGoTo;
  const DashboardAdmin({super.key, required this.onGoTo});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return ListView(padding: const EdgeInsets.all(16), children: [
      DashHeader(
          saludo: 'Hola, ${s.current!.nombre}',
          rol: 'Panel de administración',
          icon: Icons.admin_panel_settings),
      const SizedBox(height: 16),
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.5,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        children: [
          StatCard(icon: Icons.groups, label: 'Usuarios', value: '${s.users.length}'),
          StatCard(
              icon: Icons.elderly,
              label: 'Pacientes',
              value: '${s.users.where((u) => u.rol == Rol.paciente).length}'),
          StatCard(icon: Icons.medication, label: 'Recordatorios', value: '${s.meds.length}'),
          StatCard(
              icon: Icons.check_circle,
              label: 'Tomados',
              value: '${s.meds.where((m) => m.tomado).length}'),
        ],
      ),
      const SizedBox(height: 16),
      FilledButton.icon(
        icon: const Icon(Icons.add_alarm),
        label: const Text('Nuevo recordatorio'),
        onPressed: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => const MedFormScreen())),
      ),
      const SizedBox(height: 10),
      OutlinedButton.icon(
        icon: const Icon(Icons.groups),
        label: const Text('Ver usuarios registrados'),
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
        onPressed: () => onGoTo(2),
      ),
    ]);
  }
}
