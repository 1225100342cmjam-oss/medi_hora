
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'perfil_screen.dart';

/// Decide qué pantalla mostrar según la sesión guardada.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final usuario = app.current;

    if (usuario == null) {
      return const LoginScreen();
    }

    // Cuentas sin consentimiento vigente (p. ej. creadas con una versión
    // anterior) deben aceptarlo antes de ver datos de salud.
    if (!app.tieneConsentimientoSalud) {
      return const ConsentimientoPendienteScreen();
    }

    return const HomeScreen();
  }
}


