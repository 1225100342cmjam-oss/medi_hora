
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../theme.dart';

class RachaScreen extends StatefulWidget {
  const RachaScreen({super.key});

  @override
  State<RachaScreen> createState() => _RachaScreenState();
}

class _RachaScreenState extends State<RachaScreen> {
  DateTime _mesActual = DateTime.now();
  DateTime _diaSeleccionado = DateTime.now();

  final List<String> _diasSemana = const [
    'L', 'M', 'M', 'J', 'V', 'S', 'D',
  ];

  void _cambiarMes(int cambio) {
    setState(() {
      _mesActual = DateTime(
        _mesActual.year,
        _mesActual.month + cambio,
        1,
      );
    });
  }

  String _nombreMes(int mes) {
    const meses = [
      'Enero', 'Febrero', 'Marzo', 'Abril',
      'Mayo', 'Junio', 'Julio', 'Agosto',
      'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];

    return meses[mes - 1];
  }

  bool _esMismoDia(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final medicamentos = appState.visibleMeds;

    final hoy = DateTime.now();
    final esHoy = _esMismoDia(_diaSeleccionado, hoy);

    // El estado actual de las tomas se consulta para el día de hoy.
    final totalMedicamentos = medicamentos.length;
    final tomadosHoy = medicamentos
        .where((med) => appState.tomadoHoy(med))
        .length;

    final porcentaje = totalMedicamentos == 0
        ? 0.0
        : tomadosHoy / totalMedicamentos;

    final primerDia = DateTime(
      _mesActual.year,
      _mesActual.month,
      1,
    );

    // El calendario comienza en lunes.
    final espaciosIniciales = primerDia.weekday - 1;

    final diasDelMes = DateTime(
      _mesActual.year,
      _mesActual.month + 1,
      0,
    ).day;

    final totalCeldas = ((espaciosIniciales + diasDelMes + 6) ~/ 7) * 7;

    return Scaffold(
      backgroundColor: kFondo,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: kPrimarioClaro,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: const Icon(
                      Icons.local_fire_department_rounded,
                      color: kPrimario,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mi racha',
                          style: TextStyle(
                            color: kTinta,
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'La constancia también es cuidarte.',
                          style: TextStyle(
                            color: kTextoSecundario,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Resumen de cumplimiento
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kPrimario, kPrimarioOscuro],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.favorite_rounded,
                          color: Colors.white,
                          size: 25,
                        ),
                        SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            'Tu progreso de hoy',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$tomadosHoy',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 43,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 8,
                            bottom: 5,
                          ),
                          child: Text(
                            'de $totalMedicamentos medicamentos',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: porcentaje,
                        minHeight: 11,
                        backgroundColor: Colors.white24,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(
                          Color(0xFFBBDEFB),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      totalMedicamentos == 0
                          ? 'Agrega tus medicamentos para comenzar.'
                          : tomadosHoy == totalMedicamentos
                              ? '¡Completaste todos tus registros de hoy!'
                              : 'Sigue tu tratamiento paso a paso.',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Calendario
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: kBlanco,
                  borderRadius: BorderRadius.circular(23),
                  border: Border.all(
                    color: kPrimarioClaro,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_rounded,
                          color: kPrimario,
                          size: 26,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${_nombreMes(_mesActual.month)} ${_mesActual.year}',
                            style: const TextStyle(
                              color: kTinta,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Mes anterior',
                          onPressed: () => _cambiarMes(-1),
                          icon: const Icon(
                            Icons.chevron_left_rounded,
                            color: kPrimario,
                            size: 30,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Mes siguiente',
                          onPressed: () {
                            final siguiente = DateTime(
                              _mesActual.year,
                              _mesActual.month + 1,
                              1,
                            );

                            if (!siguiente.isAfter(
                              DateTime(hoy.year, hoy.month, 1),
                            )) {
                              _cambiarMes(1);
                            }
                          },
                          icon: Icon(
                            Icons.chevron_right_rounded,
                            color: _mesActual.year == hoy.year &&
                                    _mesActual.month == hoy.month
                                ? Colors.grey.shade400
                                : kPrimario,
                            size: 30,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: _diasSemana.map((dia) {
                        return Expanded(
                          child: Center(
                            child: Text(
                              dia,
                              style: const TextStyle(
                                color: kTextoSecundario,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 12),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: totalCeldas,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 4,
                        childAspectRatio: 0.83,
                      ),
                      itemBuilder: (context, index) {
                        final numeroDia = index - espaciosIniciales + 1;

                        if (numeroDia < 1 || numeroDia > diasDelMes) {
                          return const SizedBox.shrink();
                        }

                        final fecha = DateTime(
                          _mesActual.year,
                          _mesActual.month,
                          numeroDia,
                        );

                        final seleccionado =
                            _esMismoDia(fecha, _diaSeleccionado);
                        final esFechaActual =
                            _esMismoDia(fecha, hoy);
                        final esFuturo = fecha.isAfter(
                          DateTime(hoy.year, hoy.month, hoy.day),
                        );

                        return Semantics(
                          button: true,
                          selected: seleccionado,
                          label: '${fecha.day} de '
                              '${_nombreMes(fecha.month)}',
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              setState(() {
                                _diaSeleccionado = fecha;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: seleccionado
                                    ? kPrimario
                                    : esFechaActual
                                        ? kPrimarioClaro
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(14),
                                border: esFechaActual && !seleccionado
                                    ? Border.all(color: kPrimario)
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$numeroDia',
                                    style: TextStyle(
                                      color: seleccionado
                                          ? Colors.white
                                          : esFuturo
                                              ? Colors.grey.shade400
                                              : kTinta,
                                      fontSize: 15,
                                      fontWeight: seleccionado ||
                                              esFechaActual
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (esFechaActual)
                                    Container(
                                      width: 5,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: seleccionado
                                            ? Colors.white
                                            : kPrimario,
                                        shape: BoxShape.circle,
                                      ),
                                    )
                                  else
                                    const SizedBox(height: 5),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    const Divider(color: kPrimarioClaro),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Container(
                          width: 13,
                          height: 13,
                          decoration: const BoxDecoration(
                            color: kPrimario,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Día seleccionado',
                            style: TextStyle(
                              color: kTextoSecundario,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Container(
                          width: 13,
                          height: 13,
                          decoration: BoxDecoration(
                            color: kPrimarioClaro,
                            border: Border.all(color: kPrimario),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Hoy',
                            style: TextStyle(
                              color: kTextoSecundario,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Detalle del día
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kBlanco,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: kPrimarioClaro),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detalle del día',
                      style: TextStyle(
                        color: kAzul,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_diaSeleccionado.day} de '
                      '${_nombreMes(_diaSeleccionado.month)} '
                      '${_diaSeleccionado.year}',
                      style: const TextStyle(
                        color: kTextoSecundario,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (esHoy && medicamentos.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            color: kPrimario,
                            size: 25,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '$tomadosHoy de $totalMedicamentos '
                              'medicamentos registrados como tomados.',
                              style: const TextStyle(
                                color: kTinta,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else if (esHoy) ...[
                      const Icon(
                        Icons.medication_outlined,
                        color: kPrimario,
                        size: 34,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Todavía no tienes medicamentos registrados.',
                        style: TextStyle(
                          color: kTextoSecundario,
                          fontSize: 15,
                        ),
                      ),
                    ] else ...[
                      const Icon(
                        Icons.history_rounded,
                        color: kPrimario,
                        size: 34,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'El historial de este día estará disponible '
                        'cuando la aplicación guarde las tomas por fecha.',
                        style: TextStyle(
                          color: kTextoSecundario,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Mensaje de motivación
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: kPrimarioClaro,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.tips_and_updates_outlined,
                      color: kPrimarioOscuro,
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Un día a la vez',
                            style: TextStyle(
                              color: kPrimarioOscuro,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Mantén tus registros al día. Tu salud '
                            'es importante y cada pequeño paso cuenta.',
                            style: TextStyle(
                              color: kTinta,
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
}
