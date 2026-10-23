import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import 'app_drawer.dart';
import 'dashboard_admin.dart';
import 'dashboard_cuidador.dart';
import 'dashboard_paciente.dart';
import 'new_medicina_screen.dart';
import 'notificacion_screen.dart';
import 'ui.dart';

/// Pantalla "Página principal": el contenido cambia según el rol.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _key = GlobalKey<ScaffoldState>();
  Timer? _timer;
  final Set<String> _avisados = {};

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _revisar());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Dispara la pantalla "Notificación" cuando llega la hora de una medicina.
  void _revisar() {
    if (!mounted) return;
    final s = context.read<AppState>();
    final u = s.current;
    if (u == null || u.rol != Rol.paciente) return;
    if (ModalRoute.of(context)?.isCurrent != true) return;
    final now = DateTime.now();
    final hhmm =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    for (final m in s.visibleMeds) {
      if (s.tomadoHoy(m)) continue;
      final clave = '${m.id}-${now.year}${now.month}${now.day}-$hhmm';
      final until = s.snoozeUntil[m.id];
      final porHora = m.hora == hhmm && !_avisados.contains(clave);
      final porSnooze = until != null && now.isAfter(until);
      if (porHora || porSnooze) {
        _avisados.add(clave);
        s.snoozeUntil.remove(m.id);
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => NotificacionScreen(med: m)));
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rol = context.watch<AppState>().current!.rol;
    final body = switch (rol) {
      Rol.paciente => const DashboardPaciente(),
      Rol.cuidador => const DashboardCuidador(),
      Rol.admin => const DashboardAdmin(),
    };

    return Scaffold(
      key: _key,
      backgroundColor: kRojo,
      endDrawer: const AppDrawer(),
      drawerScrimColor: Colors.transparent,
      floatingActionButton: BigFab(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const NewMedicinaScreen())),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: Column(children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.menu, size: 44, color: kTinta),
                onPressed: () => _key.currentState!.openEndDrawer(),
              ),
            ),
            const SizedBox(height: 6),
            Expanded(child: Padding(padding: const EdgeInsets.only(bottom: 100), child: body)),
          ]),
        ),
      ),
    );
  }
}
