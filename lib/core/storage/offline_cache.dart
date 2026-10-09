import 'dart:convert';

import 'local_store.dart';

/// Entrada de caché: el JSON crudo que devolvió la API y cuándo se guardó.
class CacheEntry<T> {
  final T data;
  final DateTime guardadoEn;
  const CacheEntry({required this.data, required this.guardadoEn});
}

/// Caché de las últimas respuestas de la API para abrir la app sin señal (HU-010, CA-010-02).
/// Guarda el JSON tal cual (se vuelve a pasar por `fromJson` al leer), así los modelos no
/// necesitan `toJson`. Nunca toca la cola de eventos.
class OfflineCache {
  final LocalStore _store;
  final DateTime Function() _ahora;

  OfflineCache(this._store, {DateTime Function()? ahora})
      : _ahora = ahora ?? DateTime.now;

  // ── Usuario (/auth/me) ──
  Future<void> guardarUsuario(Map<String, dynamic> json) =>
      _guardar(LocalStoreKeys.usuario, json);
  Future<CacheEntry<Map<String, dynamic>>?> leerUsuario() =>
      _leerMapa(LocalStoreKeys.usuario);

  // ── Lotes (/batches) ──
  Future<void> guardarLotes(List<dynamic> json) =>
      _guardar(LocalStoreKeys.lotes, json);
  Future<CacheEntry<List<dynamic>>?> leerLotes() =>
      _leerLista(LocalStoreKeys.lotes);

  // ── Lote (/batches/{id}); si no hay entrada propia, cae a la de la lista ──
  Future<void> guardarLote(String id, Map<String, dynamic> json) =>
      _guardar(LocalStoreKeys.lote(id), json);

  Future<CacheEntry<Map<String, dynamic>>?> leerLote(String id) async {
    final propio = await _leerMapa(LocalStoreKeys.lote(id));
    if (propio != null) return propio;
    final lista = await leerLotes();
    if (lista == null) return null;
    for (final e in lista.data) {
      if (e is Map<String, dynamic> && e['id']?.toString() == id) {
        return CacheEntry(data: e, guardadoEn: lista.guardadoEn);
      }
    }
    return null;
  }

  // ── Volteos (/batches/{id}/flips) ──
  Future<void> guardarVolteos(String loteId, List<dynamic> json) =>
      _guardar(LocalStoreKeys.volteos(loteId), json);
  Future<CacheEntry<List<dynamic>>?> leerVolteos(String loteId) =>
      _leerLista(LocalStoreKeys.volteos(loteId));

  /// Al cerrar sesión o vencer el token: borra usuario, lotes, lote.* y volteos.* (NO la cola).
  Future<void> limpiarCacheDeSesion() async {
    await _store.borrar(LocalStoreKeys.usuario);
    await _store.borrar(LocalStoreKeys.lotes);
    for (final k in await _store.clavesConPrefijo(LocalStoreKeys.prefijoLote)) {
      await _store.borrar(k);
    }
    for (final k in await _store.clavesConPrefijo(LocalStoreKeys.prefijoVolteos)) {
      await _store.borrar(k);
    }
  }

  // ── internos ──
  Future<void> _guardar(String clave, Object data) => _store.escribir(
        clave,
        jsonEncode({'guardadoEn': _ahora().toUtc().toIso8601String(), 'data': data}),
      );

  Future<CacheEntry<Map<String, dynamic>>?> _leerMapa(String clave) async {
    final raw = await _leerRaw(clave);
    final data = raw?['data'];
    if (raw == null || data is! Map<String, dynamic>) return null;
    return CacheEntry(data: data, guardadoEn: _fecha(raw['guardadoEn']));
  }

  Future<CacheEntry<List<dynamic>>?> _leerLista(String clave) async {
    final raw = await _leerRaw(clave);
    final data = raw?['data'];
    if (raw == null || data is! List<dynamic>) return null;
    return CacheEntry(data: data, guardadoEn: _fecha(raw['guardadoEn']));
  }

  Future<Map<String, dynamic>?> _leerRaw(String clave) async {
    final s = await _store.leer(clave);
    if (s == null || s.isEmpty) return null;
    try {
      final v = jsonDecode(s);
      return v is Map<String, dynamic> ? v : null;
    } on FormatException {
      return null;
    }
  }

  DateTime _fecha(dynamic v) =>
      v is String ? (DateTime.tryParse(v)?.toLocal() ?? _ahora()) : _ahora();
}
