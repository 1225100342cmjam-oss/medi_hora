import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import 'widgets.dart';

/// LISTA SECUNDARIA / DETALLE
///  - Admin: usuarios  - Cuidador: pacientes  - Paciente: historial de tomas
class SecondaryListScreen extends StatelessWidget {
  const SecondaryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final rol = s.current!.rol;

    if (rol == Rol.paciente) {
      final h = s.historial;
      if (h.isEmpty) {
        return const EmptyState(icon: Icons.history, text: 'No hay elementos.\nAún no has registrado tomas.');
      }
      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: h.length,
        itemBuilder: (_, i) {
          final m = h[i];
          final t = m.tomadoEn!;
          return Card(
            elevation: 0,
            child: ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: Text('${m.nombre} · ${m.dosis}'),
              subtitle: Text(
                  '${t.day}/${t.month}/${t.year}  ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}'),
            ),
          );
        },
      );
    }

    final lista = rol == Rol.admin ? s.users : s.pacientes;
    if (lista.isEmpty) {
      return const EmptyState(icon: Icons.groups_outlined, text: 'No hay elementos.');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: lista.length,
      itemBuilder: (_, i) {
        final u = lista[i];
        return Card(
          elevation: 0,
          child: ListTile(
            leading: CircleAvatar(backgroundColor: kRojo, child: Text(u.nombre[0].toUpperCase())),
            title: Text(u.nombre),
            subtitle: Text('${u.rol.label} · ${u.email}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _detalle(context, u, s),
          ),
        );
      },
    );
  }

  void _detalle(BuildContext context, AppUser u, AppState s) {
    final suyos = s.meds.where((m) => m.pacienteEmail == u.email).toList();
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(u.nombre, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text('${u.rol.label} · ${u.email}'),
          const Divider(height: 28),
          if (u.rol != Rol.paciente)
            const Text('Este usuario no tiene recordatorios asignados.')
          else if (suyos.isEmpty)
            const Text('Sin recordatorios.')
          else
            for (final m in suyos)
              ListTile(
                dense: true,
                leading: Icon(m.tomado ? Icons.check_circle : Icons.alarm,
                    color: m.tomado ? Colors.green : kRojo),
                title: Text(m.nombre),
                subtitle: Text('${m.dosis} · ${m.hora}'),
              ),
        ]),
      ),
    );
  }
}
