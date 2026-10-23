import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import 'notificacion_screen.dart';
import 'ui.dart';

/// Pantalla "Configuración": datos del usuario y cerrar sesión.
class ConfiguracionScreen extends StatelessWidget {
  const ConfiguracionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final u = s.current;
    if (u == null) return const SizedBox.shrink();
    final dato = slab(14);

    return Scaffold(
      backgroundColor: kRojo,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 12, 30, 28),
          child: Column(children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, size: 34, color: kTinta),
                onPressed: () => Navigator.maybePop(context),
              ),
            ),
            Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                color: const Color(0xFFEADDFF),
                borderRadius: BorderRadius.circular(64),
              ),
              child: const Icon(Icons.person_outline, size: 130, color: Color(0xFF4F378A)),
            ),
            const SizedBox(height: 18),
            Text('Usuario', style: slab(22)),
            const SizedBox(height: 26),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Datos del usuario:', style: dato),
                const SizedBox(height: 8),
                Text('Nombre:  ${u.nombre}', style: dato),
                const SizedBox(height: 8),
                Text('Edad:  ${u.edad}', style: dato),
                const SizedBox(height: 8),
                Text('Correo electronico:  ${u.email}', style: dato),
                const SizedBox(height: 8),
                Text('Rol:  ${u.rol.label}', style: dato),
              ]),
            ),
            const Spacer(),
            if (u.rol == Rol.paciente) ...[
              PinkButton('Probar recordatorio', onPressed: () {
                final pend = s.visibleMeds.where((m) => !s.tomadoHoy(m)).toList();
                if (pend.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('No tienes medicinas pendientes hoy')));
                } else {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => NotificacionScreen(med: pend.first)));
                }
              }),
              const SizedBox(height: 16),
            ],
            PinkButton('Cerrar sesión', onPressed: () {
              final st = context.read<AppState>();
              Navigator.of(context).popUntil((r) => r.isFirst);
              st.logout();
            }),
          ]),
        ),
      ),
    );
  }
}
