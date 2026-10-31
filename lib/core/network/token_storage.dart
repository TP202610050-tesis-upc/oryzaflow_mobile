import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persistencia segura del JWT de sesión (Keystore/Keychain del dispositivo).
class TokenStorage {
  static const _keyToken = 'oryzaflow_auth_token';
  final FlutterSecureStorage _storage;

  TokenStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  Future<String?> leerToken() => _storage.read(key: _keyToken);

  Future<void> guardarToken(String token) =>
      _storage.write(key: _keyToken, value: token);

  Future<void> limpiar() => _storage.delete(key: _keyToken);
}
