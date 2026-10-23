import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const kRojo = Color(0xFFCB172E);
const kRojoOscuro = Color(0xFFBB1C2B);
const kRosa = Color(0xFFF5D4D6);
const kRosaMenu = Color(0xFFE5D2D4);
const kRosaBoton = Color(0xFFFBD5D2);
const kOscuro = Color(0xFF2B2B2B);
const kTinta = Color(0xFF1E1B20);
const kNaranja = Color(0xFFC76B00);
const kVerde = Color(0xFF12B25A);

/// Tipografía de títulos (slab serif, como en el diseño).
TextStyle slab(double size, {Color color = Colors.white}) =>
    GoogleFonts.alfaSlabOne(fontSize: size, color: color);

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: kRojo, primary: kRojo),
  );
  return base.copyWith(
    scaffoldBackgroundColor: kRojo,
    textTheme: GoogleFonts.interTextTheme(base.textTheme)
        .apply(bodyColor: kTinta, displayColor: kTinta),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      isDense: true,
      fillColor: const Color(0xFFFCF3F3),
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      errorStyle: const TextStyle(color: Color(0xFF8B0000)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

String fmtHora(String hhmm) {
  final p = hhmm.split(':');
  var h = int.parse(p[0]);
  final suf = h >= 12 ? 'P.M.' : 'A.M.';
  h = h % 12;
  if (h == 0) h = 12;
  return '${h.toString().padLeft(2, '0')}:${p[1]} $suf';
}

String fmtHoraDt(DateTime d) =>
    fmtHora('${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}');

String fmtFecha(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
