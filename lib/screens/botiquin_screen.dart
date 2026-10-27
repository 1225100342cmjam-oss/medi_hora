
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';

class BotiquinScreen extends StatefulWidget {
  const BotiquinScreen({super.key});

  @override
  State<BotiquinScreen> createState() => _BotiquinScreenState();
}

class _BotiquinScreenState extends State<BotiquinScreen> {
  final Map<String, int> existencias = {};
  String filtro = 'Todos';

  int cantidadDe(Medicamento medicamento) {
    return existencias[medicamento.id] ?? 0;
  }

  void cambiarCantidad(Medicamento medicamento, int cantidad) {
    setState(() {
      existencias[medicamento.id] = cantidad < 0 ? 0 : cantidad;
    });
  }

  void mostrarEditor(Medicamento medicamento) {
    final controlador = TextEditingController(
      text: cantidadDe(medicamento).toString(),
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Existencias de ${medicamento.nombre}'),
        content: TextField(
          controller: controlador,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Cantidad disponible',
            hintText: 'Ej. 20',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: kVerde,
            ),
            onPressed: () {
              final cantidad = int.tryParse(controlador.text);

              if (cantidad == null || cantidad < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ingresa una cantidad válida.'),
                  ),
                );
                return;
              }

              cambiarCantidad(medicamento, cantidad);
              Navigator.pop(dialogContext);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final medicamentos = app.visibleMeds;

    final disponibles = medicamentos
        .where((m) => cantidadDe(m) > 5)
        .length;

    final bajos = medicamentos
        .where((m) => cantidadDe(m) > 0 && cantidadDe(m) <= 5)
        .length;

    final agotados = medicamentos
        .where((m) => cantidadDe(m) == 0)
        .length;

    final filtrados = medicamentos.where((m) {
      switch (filtro) {
        case 'Existencias bajas':
          return cantidadDe(m) > 0 && cantidadDe(m) <= 5;
        case 'Agotados':
          return cantidadDe(m) == 0;
        case 'Disponibles':
          return cantidadDe(m) > 5;
        default:
          return true;
      }
    }).toList();

    return Scaffold(
      backgroundColor: kFondo,
      appBar: AppBar(
        title: const Text('Mi botiquín'),
        backgroundColor: kVerde,
        foregroundColor: kBlanco,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kVerde,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.medication_liquid_rounded,
                    color: kBlanco,
                    size: 36,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Controla tus medicamentos',
                    style: TextStyle(
                      color: kBlanco,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Consulta las existencias y mantén tu botiquín organizado.',
                    style: TextStyle(
                      color: kBlanco,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: _resumen(
                    icono: Icons.check_circle_outline,
                    titulo: 'Disponibles',
                    cantidad: disponibles,
                    color: kVerde,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _resumen(
                    icono: Icons.warning_amber_rounded,
                    titulo: 'Pocas',
                    cantidad: bajos,
                    color: kNaranja,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _resumen(
                    icono: Icons.remove_circle_outline,
                    titulo: 'Agotados',
                    cantidad: agotados,
                    color: kRojo,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              'Mis medicamentos',
              style: TextStyle(
                color: kOscuro,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filtro('Todos'),
                  _filtro('Disponibles'),
                  _filtro('Existencias bajas'),
                  _filtro('Agotados'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (filtrados.isEmpty)
              Container(
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  color: kBlanco,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 48,
                      color: kTextoSecundario,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No hay medicamentos en esta categoría',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: kOscuro,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...filtrados.map((medicamento) {
                return _tarjetaMedicamento(medicamento);
              }),
          ],
        ),
      ),
    );
  }

  Widget _resumen({
    required IconData icono,
    required String titulo,
    required int cantidad,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: kBlanco,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icono, color: color, size: 25),
          const SizedBox(height: 8),
          Text(
            '$cantidad',
            style: const TextStyle(
              color: kOscuro,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: kTextoSecundario,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filtro(String texto) {
    final seleccionado = filtro == texto;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(texto),
        selected: seleccionado,
        selectedColor: kVerdeClaro,
        labelStyle: TextStyle(
          color: seleccionado ? kVerdeOscuro : kTextoSecundario,
          fontWeight: seleccionado
              ? FontWeight.bold
              : FontWeight.normal,
        ),
        onSelected: (_) {
          setState(() {
            filtro = texto;
          });
        },
      ),
    );
  }

  Widget _tarjetaMedicamento(Medicamento medicamento) {
    final cantidad = cantidadDe(medicamento);

    final Color colorEstado;
    final String estado;

    if (cantidad == 0) {
      colorEstado = kRojo;
      estado = 'Agotado';
    } else if (cantidad <= 5) {
      colorEstado = kNaranja;
      estado = 'Existencias bajas';
    } else {
      colorEstado = kVerde;
      estado = 'Disponible';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBlanco,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kVerdeClaro),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kVerdeClaro,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.medication_rounded,
                  color: kVerde,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicamento.nombre,
                      style: const TextStyle(
                        color: kOscuro,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Dosis: ${medicamento.dosis}',
                      style: const TextStyle(
                        color: kTextoSecundario,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 9,
                          color: colorEstado,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            estado,
                            style: TextStyle(
                              color: colorEstado,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Editar existencias',
                onPressed: () => mostrarEditor(medicamento),
                icon: const Icon(
                  Icons.edit_outlined,
                  color: kVerde,
                ),
              ),
            ],
          ),

          const Divider(height: 26),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Unidades disponibles',
                  style: TextStyle(
                    color: kTextoSecundario,
                    fontSize: 13,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Restar una unidad',
                onPressed: cantidad > 0
                    ? () => cambiarCantidad(
                          medicamento,
                          cantidad - 1,
                        )
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text(
                '$cantidad',
                style: const TextStyle(
                  color: kOscuro,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                tooltip: 'Agregar una unidad',
                onPressed: () => cambiarCantidad(
                  medicamento,
                  cantidad + 1,
                ),
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: kVerde,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
