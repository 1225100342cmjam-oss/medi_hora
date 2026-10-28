
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../theme.dart';
import 'med_tile.dart';
import 'ui.dart';

/// DASHBOARD 2 · Cuidador → Mis pacientes
class DashboardCuidador extends StatelessWidget {
  const DashboardCuidador({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final pacientes = app.pacientes;

    return PinkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeader('Mis pacientes'),
          const SizedBox(height: 12),

          Expanded(
            child: pacientes.isEmpty
                ? const Center(
                    child: EmptyText(
                      'No hay pacientes registrados todavía.',
                    ),
                  )
                : ListView.builder(
                    itemCount: pacientes.length,
                    itemBuilder: (context, index) {
                      final paciente = pacientes[index];
                      final total = app.medsDe(paciente.email).length;
                      final pendientes =
                          app.pendientesHoy(paciente.email);

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          backgroundColor: kPrimarioClaro,
                          child: Icon(
                            Icons.person_outline,
                            color: kPrimario,
                          ),
                        ),
                        title: Text(
                          paciente.nombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: kTinta,
                          ),
                        ),
                        subtitle: Text(
                          '$total medicinas · $pendientes pendientes hoy',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StatusChip(
                              label: pendientes == 0
                                  ? 'Al día'
                                  : 'Pendiente',
                              color: pendientes == 0
                                  ? kPrimario
                                  : kNaranja,
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.chevron_right,
                              color: kTextoSecundario,
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PacienteMedsScreen(
                                email: paciente.email,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),

          const Divider(
            color: Colors.black26,
            height: 1,
          ),
        ],
      ),
    );
  }
}

/// Detalle: medicinas de un paciente desde la vista del cuidador.
class PacienteMedsScreen extends StatelessWidget {
  final String email;

  const PacienteMedsScreen({
    super.key,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final medicamentos = app.medsDe(email);

    return RedPage(
      title: app.nombreDe(email),
      child: PinkCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CardHeader('Medicinas'),
            const SizedBox(height: 12),

            Expanded(
              child: medicamentos.isEmpty
                  ? const Center(
                      child: EmptyText(
                        'Este paciente todavía no tiene medicinas registradas.',
                      ),
                    )
                  : MedList(meds: medicamentos),
            ),
          ],
        ),
      ),
    );
  }
}
