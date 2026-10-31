import 'package:shared_preferences/shared_preferences.dart';

/// Almacén local clave → JSON (texto). Sostiene la caché sin conexión y la cola de eventos
/// (HU-010, CA-010-02). La implementación real usa `SharedPreferences`; en pruebas se reemplaza
/// por un mapa en memoria.
abstract class LocalStore {
  Future<String?> leer(String clave);
  Future<void> escribir(String clave, String json);
  Future<void> borrar(String clave);
  Future<List<String>> clavesConPrefijo(String prefijo);
}

/// Claves usadas por la app. El sufijo `.v1` permite migrar el formato sin pisar datos viejos.
class LocalStoreKeys {
  LocalStoreKeys._();

  static const String colaEventos = 'oryzaflow.sync.cola.v1';
  static const String usuario = 'oryzaflow.cache.usuario.v1';
  static const String lotes = 'oryzaflow.cache.lotes.v1';
  static const String prefijoLote = 'oryzaflow.cache.lote.v1.';
  static const String prefijoVolteos = 'oryzaflow.cache.volteos.v1.';

  static String lote(String id) => '$prefijoLote$id';
  static String volteos(String id) => '$prefijoVolteos$id';
}

class SharedPrefsLocalStore implements LocalStore {
  @override
  Future<String?> leer(String clave) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(clave);
  }

  @override
  Future<void> escribir(String clave, String json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(clave, json);
  }

  @override
  Future<void> borrar(String clave) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(clave);
  }

  @override
  Future<List<String>> clavesConPrefijo(String prefijo) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getKeys().where((k) => k.startsWith(prefijo)).toList();
  }
}
