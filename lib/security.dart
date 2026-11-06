import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show compute;

/// Utilidades de seguridad de contraseñas.
///
/// Las contraseñas nunca se guardan en texto legible: se almacena un hash
/// PBKDF2-HMAC-SHA256 con sal aleatoria por usuario.
class Seguridad {
  Seguridad._();

  static const int iteraciones = 100000;
  static const int minimoCaracteres = 8;

  /// Devuelve un mensaje de error o `null` si la contraseña es aceptable.
  static String? validarPassword(String p) {
    if (p.length < minimoCaracteres) {
      return 'Utiliza al menos $minimoCaracteres caracteres';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(p) || !RegExp(r'\d').hasMatch(p)) {
      return 'Combina letras y números';
    }
    return null;
  }

  /// Sal aleatoria de 16 bytes, en base64.
  static String nuevaSal() {
    final r = Random.secure();
    return base64Encode(List<int>.generate(16, (_) => r.nextInt(256)));
  }

  /// Calcula el hash en un isolate para no bloquear la interfaz.
  static Future<String> hash(String password, String salBase64, int iter) {
    return compute(_pbkdf2, <Object>[password, salBase64, iter]);
  }

  /// Comparación en tiempo constante.
  static bool iguales(String a, String b) {
    if (a.length != b.length) return false;
    var r = 0;
    for (var i = 0; i < a.length; i++) {
      r |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return r == 0;
  }
}

/// PBKDF2-HMAC-SHA256 con una longitud de salida de 32 bytes (un bloque).
String _pbkdf2(List<Object> args) {
  final password = args[0] as String;
  final sal = base64Decode(args[1] as String);
  final iter = args[2] as int;

  final hmac = Hmac(sha256, utf8.encode(password));
  var u = hmac.convert([...sal, 0, 0, 0, 1]).bytes;
  final t = List<int>.from(u);
  for (var i = 1; i < iter; i++) {
    u = hmac.convert(u).bytes;
    for (var j = 0; j < t.length; j++) {
      t[j] ^= u[j];
    }
  }
  return base64Encode(t);
}
