import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../models/pending_event_model.dart';
import '../storage/local_store.dart';

/// Persistencia de la cola de eventos del lote (HU-010, CA-010-02) en el `LocalStore`.
/// Formato: `{"version":1,"eventos":[...]}`; el orden del array es el orden FIFO.
class EventQueueStore {
  static const int version = 1;

  final LocalStore _store;
  EventQueueStore(this._store);

  Future<List<PendingEvent>> cargar() async {
    final raw = await _store.leer(LocalStoreKeys.colaEventos);
    if (raw == null || raw.isEmpty) return [];
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) return [];
      if ((json['version'] as num?)?.toInt() != version) {
        debugPrint('EventQueueStore: versión desconocida de la cola, se ignora');
        return [];
      }
      final lista = json['eventos'];
      if (lista is! List) return [];
      return lista
          .whereType<Map<String, dynamic>>()
          .map(PendingEvent.fromJson)
          .toList();
    } catch (e) {
      debugPrint('EventQueueStore: cola corrupta ($e), se ignora');
      return [];
    }
  }

  Future<void> guardar(List<PendingEvent> eventos) => _store.escribir(
        LocalStoreKeys.colaEventos,
        jsonEncode({
          'version': version,
          'eventos': eventos.map((e) => e.toJson()).toList(),
        }),
      );
}
