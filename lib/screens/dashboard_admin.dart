
import 'package:flutter/material.dart';
import 'package:medihora/models.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../theme.dart';
import 'ui.dart';

/// DASHBOARD 3 · Administrador → Panel de administración
class DashboardAdmin extends StatelessWidget {
  const DashboardAdmin({super.key});

  Widget _stat(String valor, String etiqueta, IconData icono) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 4,
        ),
        decoration: BoxDecoration(
          color: kVerdeClaro,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icono,
              color: kVerde,
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              valor,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: kVerdeOscuro,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              etiqueta,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                color: kTinta,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return PinkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeader('Panel de administración'),
          const SizedBox(height: 12),

          Row(
            children: [
              _stat(
                '${app.users.length}',
                'Usuarios',
                Icons.people_outline,
              ),
              _stat(
                '${app.pacientes.length}',
                'Pacientes',
                Icons.personal_injury_outlined,
              ),
              _stat(
                '${app.meds.length}',
                'Medicinas',
                Icons.medication_outlined,
              ),
              _stat(
                '${app.tomasHoy}',
                'Tomas hoy',
                Icons.check_circle_outline,
              ),
            ],
          ),

          const SizedBox(height: 20),
          const CardHeader('Usuarios registrados'),
          const SizedBox(height: 8),

          Expanded(
            child: app.users.isEmpty
                ? const Center(
                    child: EmptyText(
                      'Todavía no hay usuarios registrados.',
                    ),
                  )
                : ListView.separated(
                    itemCount: app.users.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      color: Colors.black12,
                    ),
                    itemBuilder: (context, index) {
                      final usuario = app.users[index];

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          backgroundColor: kVerdeClaro,
                          child: Icon(
                            Icons.person_outline,
                            color: kVerde,
                          ),
                        ),
                        title: Text(
                          usuario.nombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: kTinta,
                          ),
                        ),
                        subtitle: Text(usuario.email),
                        trailing: StatusChip(
                          label: usuario.rol.label,
                          color: kVerde,
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (dialogContext) {
                              return AlertDialog(
                                title: Text(usuario.nombre),
                                content: Text(
                                  'Rol: ${usuario.rol.label}\n'
                                  'Edad: ${usuario.edad}\n'
                                  'Correo: ${usuario.email}',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(dialogContext);
                                    },
                                    child: const Text('Cerrar'),
                                  ),
                                ],
                              );
                            },
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
