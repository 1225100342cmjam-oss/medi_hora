import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import 'ui.dart';

/// DASHBOARD 3 · Administrador  →  "Panel" con estadísticas y usuarios
class DashboardAdmin extends StatelessWidget {
  const DashboardAdmin({super.key});

  Widget _stat(String v, String l) => Expanded(
        child: Column(children: [
          Text(v, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          Text(l, style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return PinkCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const CardHeader('Panel de administración'),
        const SizedBox(height: 12),
        Row(children: [
          _stat('${s.users.length}', 'Usuarios'),
          _stat('${s.pacientes.length}', 'Pacientes'),
          _stat('${s.meds.length}', 'Medicinas'),
          _stat('${s.tomasHoy}', 'Tomas hoy'),
        ]),
        const SizedBox(height: 12),
        const CardHeader('Usuarios registrados'),
        Expanded(
          child: s.users.isEmpty
              ? const EmptyText('No hay elementos.')
              : ListView.builder(
                  itemCount: s.users.length,
                  itemBuilder: (_, i) {
                    final u = s.users[i];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.person_outline, color: kTinta),
                      title: Text(u.nombre),
                      subtitle: Text(u.email),
                      trailing: StatusChip(label: u.rol.label, color: kOscuro),
                      onTap: () => showDialog(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: Text(u.nombre),
                          content: Text(
                              'Rol: ${u.rol.label}\nEdad: ${u.edad}\nCorreo: ${u.email}'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(c), child: const Text('Cerrar'))
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        const Divider(color: Colors.black54, height: 1),
      ]),
    );
  }
}
