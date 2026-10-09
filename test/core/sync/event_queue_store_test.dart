import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:oryzaflow_mobile/core/storage/local_store.dart';
import 'package:oryzaflow_mobile/core/sync/event_queue_store.dart';
import 'package:oryzaflow_mobile/models/pending_event_model.dart';

import '../../fakes/fake_batch_repository.dart';
import '../../fakes/in_memory_local_store.dart';

void main() {
  late InMemoryLocalStore store;
  late EventQueueStore cola;
  final lote = FakeBatchRepository().lotePorDefecto('9');

  setUp(() {
    store = InMemoryLocalStore();
    cola = EventQueueStore(store);
  });

  test('sin datos devuelve lista vacía', () async {
    expect(await cola.cargar(), isEmpty);
  });

  test('JSON corrupto devuelve lista vacía', () async {
    store.datos[LocalStoreKeys.colaEventos] = '{"version":1,"eventos":[{';
    expect(await cola.cargar(), isEmpty);
  });

  test('versión desconocida devuelve lista vacía', () async {
    store.datos[LocalStoreKeys.colaEventos] = '{"version":99,"eventos":[]}';
    expect(await cola.cargar(), isEmpty);
  });

  test('guarda con version 1 y conserva el orden', () async {
    final eventos = [
      for (var i = 0; i < 3; i++)
        PendingEvent.nuevo(
            tipo: TipoEvento.values[i],
            lote: lote,
            ts: DateTime.utc(2026, 10, 9, 10 + i)),
    ];
    await cola.guardar(eventos);
    final json = jsonDecode(store.datos[LocalStoreKeys.colaEventos]!) as Map<String, dynamic>;
    expect(json['version'], 1);
    final leidos = await cola.cargar();
    expect(leidos.map((e) => e.id).toList(), eventos.map((e) => e.id).toList());
  });
}
