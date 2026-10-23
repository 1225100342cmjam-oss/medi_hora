import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import 'confirmacion_screen.dart';
import 'ui.dart';

/// Pantalla "Notificación": es hora de tomar el medicamento.
class NotificacionScreen extends StatelessWidget {
  final Medicamento med;
  const NotificacionScreen({super.key, required this.med});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kRojo,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.notifications_none, size: 190, color: kTinta),
              const SizedBox(height: 18),
              Text('MediHora', style: slab(20)),
              const SizedBox(height: 18),
              Text('Es hora de tomar tu medicamento',
                  textAlign: TextAlign.center, style: slab(16)),
              const SizedBox(height: 8),
              Text('${med.nombre} · ${med.dosis}',
                  style: const TextStyle(color: Colors.white, fontSize: 15)),
              const SizedBox(height: 40),
              PinkButton('Ya lo tomé', onPressed: () {
                final racha = context.read<AppState>().marcarTomado(med);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => ConfirmacionScreen(racha: racha)));
              }),
              const SizedBox(height: 14),
              PinkButton('Posponer 10 minutos', onPressed: () {
                context.read<AppState>().posponer(med);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Te lo recordaremos en 10 minutos')));
              }),
            ]),
          ),
        ),
      ),
    );
  }
}
