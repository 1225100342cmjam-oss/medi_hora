
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  DateTime fechaSeleccionada = DateTime.now();

  bool mismoDia(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  String fechaCompleta(DateTime fecha) {
    const dias = [
      'lunes', 'martes', 'miércoles', 'jueves',
      'viernes', 'sábado', 'domingo'
    ];

    const meses = [
      'enero', 'febrero', 'marzo', 'abril',
      'mayo', 'junio', 'julio', 'agosto',
      'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];

    return '${dias[fecha.weekday - 1]} ${fecha.day} '
        'de ${meses[fecha.month - 1]} de ${fecha.year}';
  }

  String horaFormato(DateTime fecha) {
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');
    return '$hora:$minuto';
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    final tomas = app
        .tomasDelDia(fechaSeleccionada)
        .reversed
        .toList();

    return Scaffold(
      backgroundColor: kFondo,
      appBar: AppBar(
        title: const Text('Historial de tomas'),
        backgroundColor: kPrimario,
        foregroundColor: kBlanco,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: kPrimario,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.history_rounded,
                    color: kBlanco,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tus tomas registradas',
                    style: TextStyle(
                      color: kBlanco,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${tomas.length} ${tomas.length == 1 ? 'toma registrada' : 'tomas registradas'}',
                    style: const TextStyle(
                      color: kBlanco,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Selecciona una fecha',
              style: TextStyle(
                color: kOscuro,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: kBlanco,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.calendar_month_rounded,
                  color: kPrimario,
                  size: 30,
                ),
                title: Text(
                  fechaCompleta(fechaSeleccionada),
                  style: const TextStyle(
                    color: kOscuro,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text('Toca para cambiar el día'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final elegida = await showDatePicker(
                    context: context,
                    initialDate: fechaSeleccionada,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    locale: const Locale('es', 'MX'),
                  );

                  if (elegida != null && mounted) {
                    setState(() {
                      fechaSeleccionada = elegida;
                    });
                  }
                },
              ),
            ),

            const SizedBox(height: 22),

            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Registro del día',
                    style: TextStyle(
                      color: kOscuro,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      fechaSeleccionada = DateTime.now();
                    });
                  },
                  icon: const Icon(Icons.today_rounded),
                  label: const Text('Hoy'),
                ),
              ],
            ),

            const SizedBox(height: 8),

            if (tomas.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: kBlanco,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.medication_outlined,
                      size: 48,
                      color: kTextoSecundario,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Sin tomas registradas',
                      style: TextStyle(
                        color: kOscuro,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'No hay medicamentos confirmados en esta fecha.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: kTextoSecundario),
                    ),
                  ],
                ),
              )
            else
              ...tomas.map((toma) => _tarjetaToma(toma)),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaToma(Toma toma) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBlanco,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPrimarioClaro),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kPrimarioClaro,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.medication_rounded,
              color: kPrimario,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  toma.nombre,
                  style: const TextStyle(
                    color: kOscuro,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Dosis: ${toma.dosis}',
                  style: const TextStyle(color: kTextoSecundario),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      color: kPrimario,
                      size: 17,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      horaFormato(toma.fecha),
                      style: const TextStyle(
                        color: kPrimario,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle_rounded,
            color: kPrimario,
            size: 24,
          ),
        ],
      ),
    );
  }
}
