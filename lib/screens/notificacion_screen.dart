
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import 'confirmacion_screen.dart';

/// Pantalla de recordatorio de MediHora.
class NotificacionScreen extends StatelessWidget {
  final Medicamento med;

  const NotificacionScreen({
    super.key,
    required this.med,
  });

  String get horaActual {
    final ahora = DateTime.now();
    final hora = ahora.hour.toString().padLeft(2, '0');
    final minuto = ahora.minute.toString().padLeft(2, '0');
    return '$hora:$minuto';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kFondo,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Encabezado
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      color: kPrimarioClaro,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      color: kPrimario,
                      size: 48,
                    ),
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    'MediHora',
                    style: TextStyle(
                      color: kPrimario,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    '¡Es hora de tu medicamento!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: kOscuro,
                      fontSize: 27,
                      height: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Tómate un momento para cuidar de ti.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: kTextoSecundario,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Tarjeta del medicamento
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: kBlanco,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: kPrimarioClaro),
                      boxShadow: [
                        BoxShadow(
                          color: kPrimario.withValues(alpha: 0.07),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 62,
                          height: 62,
                          decoration: BoxDecoration(
                            color: kFondo,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.medication_rounded,
                            color: kPrimario,
                            size: 36,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          med.nombre,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: kOscuro,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: kPrimarioClaro,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            'Dosis: ${med.dosis}',
                            style: const TextStyle(
                              color: kPrimarioOscuro,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Divider(color: kPrimarioClaro),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              color: kPrimario,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Hora del recordatorio',
                                style: TextStyle(
                                  color: kTextoSecundario,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Text(
                              med.hora,
                              style: const TextStyle(
                                color: kOscuro,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        if (med.info.trim().isNotEmpty) ...[
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: kFondo,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  color: kPrimario,
                                  size: 21,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    med.info,
                                    style: const TextStyle(
                                      color: kTextoSecundario,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

 // Confirmar toma
SizedBox(
  width: double.infinity,
  height: 56,
  child: ElevatedButton.icon(
    onPressed: () {
      final app = context.read<AppState>();

      // Comprobar si ya se registró la toma hoy
      if (app.tomadoHoy(med)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Este medicamento ya fue registrado como tomado hoy.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pop(context);
        return;
      }

      // Registrar la toma
      final racha = app.marcarTomado(med);

      // Ir a la pantalla de confirmación
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ConfirmacionScreen(
            racha: racha,
          ),
        ),
      );
    },
    icon: const Icon(Icons.check_circle_outline_rounded),
    label: const Text('Ya lo tomé'),
    style: ElevatedButton.styleFrom(
      backgroundColor: kPrimario,
      foregroundColor: kBlanco,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),


                  const SizedBox(height: 12),

                  // Posponer recordatorio
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.read<AppState>().posponer(med);
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Recordatorio pospuesto por 10 minutos.',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.snooze_rounded),
                      label: const Text('Recordármelo en 10 minutos'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kPrimario,
                        side: const BorderSide(color: kPrimario),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cerrar recordatorio',
                      style: TextStyle(
                        color: kTextoSecundario,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
