import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Almacenamiento cifrado en el dispositivo (Keychain en iOS, Keystore en
/// Android). Sustituye a SharedPreferences, que guarda texto sin cifrar.
class SecureStore {
  static const FlutterSecureStorage _s = FlutterSecureStorage();

  Future<String?> read(String key) => _s.read(key: key);

  Future<void> write(String key, String value) =>
      _s.write(key: key, value: value);

  Future<void> delete(String key) => _s.delete(key: key);
}
