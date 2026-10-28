
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Paleta de colores de MediHora: tonos azules.
const kPrimario = Color(0xFF1565C0); // azul principal
const kPrimarioOscuro = Color(0xFF0D47A1); // azul profundo
const kPrimarioClaro = Color(0xFFDCEBFA); // azul muy claro (fondos de iconos/chips)
const kAzulSuave = Color(0xFFE8F1FC); // azul suave para botones/tarjetas

const kAzul = Color(0xFF123E73); // azul marino para títulos
const kFondo = Color(0xFFF2F7FD);
const kBlanco = Color(0xFFFFFFFF);

const kOscuro = Color(0xFF1B2A3D);
const kTinta = Color(0xFF1B2A3D);
const kTextoSecundario = Color(0xFF4A5B70);

// Colores semánticos (advertencia / error): se conservan a propósito.
const kNaranja = Color(0xFF8A4B08);
const kRojo = Color(0xFFB42332);
const kRojoOscuro = Color(0xFF8F1D29);

TextStyle slab(
  double size, {
  Color color = kOscuro,
}) =>
    GoogleFonts.inter(
      fontSize: size,
      color: color,
      fontWeight: FontWeight.w700,
    );

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: kPrimario,
      brightness: Brightness.light,
    ).copyWith(
      primary: kPrimario,
      onPrimary: kBlanco,
      secondary: kAzul,
      onSecondary: kBlanco,
      surface: kBlanco,
      onSurface: kTinta,
      error: kRojo,
      onError: kBlanco,
    ),
  );

  final textTheme = GoogleFonts.interTextTheme(
    base.textTheme,
  ).apply(
    bodyColor: kTinta,
    displayColor: kTinta,
  );

  return base.copyWith(
    scaffoldBackgroundColor: kFondo,

    textTheme: textTheme.copyWith(
      bodyLarge: textTheme.bodyLarge?.copyWith(
        fontSize: 18,
        height: 1.5,
      ),
      bodyMedium: textTheme.bodyMedium?.copyWith(
        fontSize: 16,
        height: 1.5,
      ),
      titleLarge: textTheme.titleLarge?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: textTheme.titleMedium?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: kFondo,
      foregroundColor: kAzul,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: kAzul,
        fontSize: 23,
        fontWeight: FontWeight.w700,
      ),
    ),

    cardTheme: CardThemeData(
      color: kBlanco,
      elevation: 1,
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: Color(0xFFD3E2F3),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      isDense: false,
      fillColor: kBlanco,
      labelStyle: const TextStyle(
        color: kTextoSecundario,
        fontSize: 17,
      ),
      hintStyle: const TextStyle(
        color: kTextoSecundario,
        fontSize: 16,
      ),
      errorStyle: const TextStyle(
        color: kRojoOscuro,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFB5CAE2),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFB5CAE2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: kPrimario,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: kRojo,
          width: 1.5,
        ),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimario,
        foregroundColor: kBlanco,
        minimumSize: const Size(48, 52),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        textStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kPrimarioOscuro,
        minimumSize: const Size(48, 52),
        side: const BorderSide(
          color: kPrimario,
          width: 1.5,
        ),
        textStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: kBlanco,
      indicatorColor: kPrimarioClaro,
      elevation: 2,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: Color(0xFFD3E2F3),
      thickness: 1,
      space: 24,
    ),
  );
}

// Conserva las funciones de formato existentes.

String fmtHora(String hhmm) {
  final p = hhmm.split(':');
  var h = int.parse(p[0]);
  final suf = h >= 12 ? 'P.M.' : 'A.M.';
  h = h % 12;
  if (h == 0) h = 12;
  return '${h.toString().padLeft(2, '0')}:${p[1]} $suf';
}

String fmtHoraDt(DateTime d) =>
    fmtHora(
      '${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}',
    );

String fmtFecha(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/'
    '${d.month.toString().padLeft(2, '0')}/'
    '${d.year}';
