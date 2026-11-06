import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import 'med_tile.dart';
import 'ui.dart';

/// DASHBOARD 2 · Cuidador → pacientes vinculados.
///
/// Solo muestra pacientes con un Vínculo de Cuidado activo y, de cada uno,
/// únicamente la información que el paciente autorizó compartir.
class DashboardCuidador extends StatelessWidget {
  const DashboardCuidador({super.key});

  String _linea(ResumenPaciente r) {
    final partes = <String>[];
    if (r.totalMedicamentos != null) {
      partes.add('${r.totalMedicamentos} medicinas');
      partes.add('${r.pendientesHoy} pendientes hoy');
      if ((r.omitidasHoy ?? 0) > 0) partes.add('${r.omitidasHoy} omitidas');
    }
    if ((r.existenciasBajas ?? 0) > 0) {
      partes.add('${r.existenciasBajas} con existencias bajas');
    }
    return partes.isEmpty ? 'Sin información autorizada' : partes.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final pacientes = app.pacientesVinculados;
    final invitaciones = app.invitacionesPendientes;

    return PinkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (invitaciones.isNotEmpty) ...[
            const CardHeader('Invitaciones pendientes'),
            const SizedBox(height: 8),
            for (final inv in invitaciones)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kPrimarioClaro,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${app.nombreDe(inv.pacienteEmail)} quiere vincularte '
                      'como cuidador.',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, color: kTinta),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Permisos: ${inv.permisos.isEmpty ? 'ninguno' : inv.permisos.map((p) => p.label).join(', ')}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        FilledButton(
                          onPressed: () =>
                              app.responderInvitacion(inv, aceptar: true),
                          child: const Text('Aceptar'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () =>
                              app.responderInvitacion(inv, aceptar: false),
                          child: const Text('Rechazar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 6),
          ],
          const CardHeader('Pacientes vinculados'),
          const SizedBox(height: 12),
          Expanded(
            child: pacientes.isEmpty
                ? const Center(
                    child: EmptyText(
                      'Aún no tienes pacientes vinculados.\n'
                      'Un paciente debe invitarte y tú aceptar la invitación.',
                    ),
                  )
                : ListView.builder(
                    itemCount: pacientes.length,
                    itemBuilder: (context, index) {
                      final paciente = pacientes[index];
                      final resumen = app.resumenDe(paciente.email);
                      final pendientes = resumen.pendientesHoy;

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
                        subtitle: Text(_linea(resumen)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (pendientes != null)
                              StatusChip(
                                label: pendientes == 0 ? 'Al día' : 'Pendiente',
                                color: pendientes == 0 ? kPrimario : kNaranja,
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

/// Detalle: medicinas de un paciente desde la vista del cuidador. Solo
/// muestra datos si el vínculo incluye el permiso correspondiente.
class PacienteMedsScreen extends StatelessWidget {
  final String email;

  const PacienteMedsScreen({
    super.key,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final autorizado = app.tienePermiso(email, Permiso.consultarTomas);
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
              child: !autorizado
                  ? const Center(
                      child: EmptyText(
                        'Este paciente no te autorizó a consultar sus '
                        'medicamentos.',
                      ),
                    )
                  : medicamentos.isEmpty
                      ? const Center(
                          child: EmptyText(
                            'Este paciente todavía no tiene medicinas '
                            'registradas.',
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
