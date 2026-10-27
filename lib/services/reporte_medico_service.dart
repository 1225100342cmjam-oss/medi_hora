
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../screens/models.dart';

class ReporteMedicoService {
  static Future<Uint8List> generar({
    required AppUser paciente,
    required List<Medicamento> medicamentos,
    required List<Toma> tomas,
  }) async {
    final pdf = pw.Document();

    const verde = PdfColor.fromInt(0xFF176B5B);
    const verdeClaro = PdfColor.fromInt(0xFFDCEFE8);
    const gris = PdfColor.fromInt(0xFF52615B);

    final ahora = DateTime.now();

    String fecha(DateTime f) {
      return '${f.day.toString().padLeft(2, '0')}/'
          '${f.month.toString().padLeft(2, '0')}/${f.year}';
    }

    String hora(String valor) {
      final partes = valor.split(':');
      if (partes.length != 2) return valor;

      final h = int.tryParse(partes[0]);
      final m = int.tryParse(partes[1]);

      if (h == null || m == null || h < 0 || h > 23 || m < 0 || m > 59) {
        return valor;
      }

      final periodo = h >= 12 ? 'p. m.' : 'a. m.';
      final hora12 = h % 12 == 0 ? 12 : h % 12;

      return '$hora12:${m.toString().padLeft(2, '0')} $periodo';
    }

    final tomasHoy = tomas.where((t) {
      return t.fecha.year == ahora.year &&
          t.fecha.month == ahora.month &&
          t.fecha.day == ahora.day;
    }).length;

    final pendientesHoy = medicamentos.where((m) {
      return !tomas.any((t) {
        return t.medId == m.id &&
            t.fecha.year == ahora.year &&
            t.fecha.month == ahora.month &&
            t.fecha.day == ahora.day;
      });
    }).length;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(
          base: pw.Font.helvetica(),
          bold: pw.Font.helveticaBold(),
        ),
        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 10),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: verde, width: 2),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'MediHora',
                style: pw.TextStyle(
                  color: verde,
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Reporte de seguimiento',
                style: const pw.TextStyle(
                  color: gris,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.center,
          padding: const pw.EdgeInsets.only(top: 10),
          child: pw.Text(
            'Documento generado el ${fecha(ahora)} · '
            'Página ${context.pageNumber} de ${context.pagesCount}',
            style: const pw.TextStyle(color: gris, fontSize: 9),
          ),
        ),
        build: (context) => [
          pw.SizedBox(height: 18),

          pw.Text(
            'Reporte de medicamentos',
            style: pw.TextStyle(
              fontSize: 23,
              fontWeight: pw.FontWeight.bold,
              color: verde,
            ),
          ),

          pw.SizedBox(height: 6),

          pw.Text(
            'Fecha de generación: ${fecha(ahora)}',
            style: const pw.TextStyle(color: gris, fontSize: 10),
          ),

          pw.SizedBox(height: 20),

          _titulo('1. Datos del paciente', verde),

          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(14),
            decoration: const pw.BoxDecoration(
              color: verdeClaro,
              borderRadius: pw.BorderRadius.all(
                pw.Radius.circular(8),
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _dato('Nombre', paciente.nombre),
                pw.SizedBox(height: 6),
                _dato('Edad', '${paciente.edad} años'),
                pw.SizedBox(height: 6),
                _dato('Correo electrónico', paciente.email),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          _titulo('2. Resumen del día', verde),

          pw.Table(
            border: pw.TableBorder.all(
              color: PdfColors.grey300,
              width: 0.7,
            ),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: verdeClaro),
                children: [
                  _celda('Medicamentos registrados', negrita: true),
                  _celda('Tomas de hoy', negrita: true),
                  _celda('Pendientes de hoy', negrita: true),
                ],
              ),
              pw.TableRow(
                children: [
                  _celda('${medicamentos.length}'),
                  _celda('$tomasHoy'),
                  _celda('$pendientesHoy'),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 20),

          _titulo('3. Lista de medicamentos', verde),

          if (medicamentos.isEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 8),
              child: pw.Text(
                'No hay medicamentos registrados para este paciente.',
                style: const pw.TextStyle(color: gris, fontSize: 10),
              ),
            )
          else
            pw.TableHelper.fromTextArray(
              headers: ['Medicamento', 'Dosis', 'Horario', 'Indicaciones'],
              data: medicamentos.map((m) {
                return [
                  m.nombre,
                  m.dosis,
                  hora(m.hora),
                  m.info.trim().isEmpty ? 'Sin indicaciones' : m.info,
                ];
              }).toList(),
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 9,
              ),
              headerDecoration: const pw.BoxDecoration(color: verde),
              cellStyle: const pw.TextStyle(fontSize: 8),
              cellPadding: const pw.EdgeInsets.all(6),
              border: pw.TableBorder.all(
                color: PdfColors.grey300,
                width: 0.5,
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(1.5),
                1: const pw.FlexColumnWidth(1.2),
                2: const pw.FlexColumnWidth(1.1),
                3: const pw.FlexColumnWidth(2),
              },
            ),

          pw.SizedBox(height: 20),

          _titulo('4. Historial de tomas', verde),

          if (tomas.isEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 8),
              child: pw.Text(
                'Todavía no hay tomas registradas.',
                style: const pw.TextStyle(color: gris, fontSize: 10),
              ),
            )
          else
            pw.TableHelper.fromTextArray(
              headers: ['Medicamento', 'Dosis', 'Fecha', 'Hora'],
              data: (tomas.toList()
                    ..sort((a, b) => b.fecha.compareTo(a.fecha)))
                  .map((t) => [
                        t!.nombre,
                        t.dosis,
                        fecha(t.fecha),
                        hora(
                          '${t.fecha.hour.toString().padLeft(2, '0')}:'
                          '${t.fecha.minute.toString().padLeft(2, '0')}',
                        ),
                      ])
                  .toList(),
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 9,
              ),
              headerDecoration: const pw.BoxDecoration(color: verde),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellPadding: const pw.EdgeInsets.all(6),
              border: pw.TableBorder.all(
                color: PdfColors.grey300,
                width: 0.5,
              ),
            ),

          pw.SizedBox(height: 22),

          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(
                pw.Radius.circular(8),
              ),
            ),
            child: pw.Text(
              'Nota: este documento presenta información registrada en MediHora. '
              'No constituye un diagnóstico médico ni sustituye la valoración '
              'de un profesional de la salud. Los medicamentos, dosis e '
              'indicaciones deben seguir las instrucciones del profesional '
              'que atiende al paciente.',
              style: const pw.TextStyle(
                color: gris,
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _titulo(String texto, PdfColor color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Text(
        texto,
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  static pw.Widget _dato(String titulo, String valor) {
    return pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: '$titulo: ',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.TextSpan(text: valor),
        ],
      ),
    );
  }

  static pw.Widget _celda(String texto, {bool negrita = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(7),
      child: pw.Text(
        texto,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight:
              negrita ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}
