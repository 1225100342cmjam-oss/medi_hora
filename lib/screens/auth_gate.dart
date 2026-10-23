import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import 'login_screen.dart';
import 'home_screen.dart';

/// Decide qué mostrar según la sesión (persistida).
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().current;
    return user == null ? const LoginScreen() : const HomeScreen();
  }
}
