import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import 'ui.dart';

/// Pantalla "Historial": selector de fecha + tomas del día + gráfica.
class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});
  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  DateTime _fecha = DateTime.now();

  Future<void> _pickFecha() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _fecha = d);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final tomas = s.tomasDelDia(_fecha);
    final datos = s.conteoUltimosDias(14);
    final verPaciente = s.current!.rol != Rol.paciente;

    return RedPage(
      title: 'Historial',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        InkWell(
          onTap: _pickFecha,
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Fecha',
              suffixIcon: Icon(Icons.calendar_today_outlined),
            ),
            child: Text(fmtFecha(_fecha)),
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: PinkCard(
            child: tomas.isEmpty
                ? const EmptyText('No hay elementos.\nSin tomas registradas este día.')
                : ListView.builder(
                    itemCount: tomas.length,
                    itemBuilder: (_, i) {
                      final t = tomas[i];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        leading: const Icon(Icons.check_circle, color: kVerde),
                        title: Text('${t.nombre} · ${t.dosis}'),
                        subtitle: Text(verPaciente
                            ? '${s.nombreDe(t.pacienteEmail)} · ${fmtHoraDt(t.fecha)}'
                            : fmtHoraDt(t.fecha)),
                      );
                    },
                  ),
          ),
        ),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
          Text('▫ TOMAS',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
          Text('Últimos 14 días', style: TextStyle(color: Colors.white, fontSize: 13)),
        ]),
        const SizedBox(height: 6),
        SizedBox(
          height: 60,
          width: double.infinity,
          child: CustomPaint(painter: _SparkPainter(datos)),
        ),
        const SizedBox(height: 10),
      ]),
    );
  }
}

class _SparkPainter extends CustomPainter {
  final List<int> v;
  _SparkPainter(this.v);

  @override
  void paint(Canvas canvas, Size size) {
    final maxV = max(1, v.reduce(max)).toDouble();
    final h = size.height - 6;
    final pts = [
      for (var i = 0; i < v.length; i++)
        Offset(size.width * i / (v.length - 1), h - (v[i] / maxV) * (h - 8)),
    ];
    final line = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) {
      line.lineTo(p.dx, p.dy);
    }
    final fill = Path.from(line)
      ..lineTo(size.width, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withAlpha(110), Colors.white.withAlpha(0)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    // línea base punteada
    final base = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.2;
    for (double x = 0; x < size.width; x += 6) {
      canvas.drawLine(Offset(x, h + 2), Offset(x + 3, h + 2), base);
    }
  }

  @override
  bool shouldRepaint(covariant _SparkPainter old) => old.v != v;
}
