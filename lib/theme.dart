import 'package:flutter/material.dart';

const kRojo = Color(0xFFC8152E);
const kRojoOscuro = Color(0xFFB61B2B);

ThemeData buildTheme() => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: kRojo, primary: kRojo),
      scaffoldBackgroundColor: const Color(0xFFF7F4F4),
      appBarTheme: const AppBarTheme(
        backgroundColor: kRojo,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: kRojo,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
