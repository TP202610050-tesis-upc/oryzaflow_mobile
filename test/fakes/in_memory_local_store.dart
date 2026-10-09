import 'package:oryzaflow_mobile/core/storage/local_store.dart';

/// LocalStore en memoria para pruebas.
class InMemoryLocalStore implements LocalStore {
  final Map<String, String> datos = {};

  @override
  Future<String?> leer(String clave) async => datos[clave];

  @override
  Future<void> escribir(String clave, String json) async => datos[clave] = json;

  @override
  Future<void> borrar(String clave) async => datos.remove(clave);

  @override
  Future<List<String>> clavesConPrefijo(String prefijo) async =>
      datos.keys.where((k) => k.startsWith(prefijo)).toList();
}
