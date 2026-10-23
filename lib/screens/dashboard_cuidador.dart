import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../theme.dart';
import 'med_tile.dart';
import 'ui.dart';

/// DASHBOARD 2 · Cuidador  →  "Mis pacientes"
class DashboardCuidador extends StatelessWidget {
  const DashboardCuidador({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final pacientes = s.pacientes;
    return PinkCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const CardHeader('Mis pacientes'),
        Expanded(
          child: pacientes.isEmpty
              ? const EmptyText('No hay pacientes registrados todavía.')
              : ListView.builder(
                  itemCount: pacientes.length,
                  itemBuilder: (_, i) {
                    final p = pacientes[i];
                    final total = s.medsDe(p.email).length;
                    final pend = s.pendientesHoy(p.email);
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.person_outline, color: kTinta),
                      title: Text(p.nombre),
                      subtitle: Text('$total medicinas · $pend pendientes hoy'),
                      trailing: StatusChip(
                        label: pend == 0 ? 'Al día' : 'Pendiente',
                        color: pend == 0 ? kVerde : kNaranja,
                      ),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => PacienteMedsScreen(email: p.email))),
                    );
                  },
                ),
        ),
        const Divider(color: Colors.black54, height: 1),
      ]),
    );
  }
}

/// Detalle: medicinas de un paciente (vista del cuidador).
class PacienteMedsScreen extends StatelessWidget {
  final String email;
  const PacienteMedsScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return RedPage(
      title: s.nombreDe(email),
      child: PinkCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const CardHeader('Medicinas'),
          Expanded(child: MedList(meds: s.medsDe(email))),
        ]),
      ),
    );
  }
}
