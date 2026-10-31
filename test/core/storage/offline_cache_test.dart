import 'package:flutter_test/flutter_test.dart';
import 'package:oryzaflow_mobile/core/storage/local_store.dart';
import 'package:oryzaflow_mobile/core/storage/offline_cache.dart';

import '../../fakes/in_memory_local_store.dart';

void main() {
  late InMemoryLocalStore store;
  late OfflineCache cache;
  final ahora = DateTime.utc(2026, 10, 9, 17, 48, 2, 113);

  setUp(() {
    store = InMemoryLocalStore();
    cache = OfflineCache(store, ahora: () => ahora);
  });

  test('guarda y lee los lotes con la hora de guardado', () async {
    await cache.guardarLotes([
      {'id': 9, 'codigo': 'LOTE-9'},
      {'id': 10, 'codigo': 'LOTE-10'},
    ]);
    final c = await cache.leerLotes();
    expect(c, isNotNull);
    expect(c!.data.length, 2);
    expect(c.guardadoEn.toUtc(), ahora);
  });

  test('leerLote cae a la entrada de la lista cuando no hay caché propia', () async {
    await cache.guardarLotes([
      {'id': 9, 'codigo': 'LOTE-9'}
    ]);
    final c = await cache.leerLote('9');
    expect(c!.data['codigo'], 'LOTE-9');
    expect(await cache.leerLote('99'), isNull);

    await cache.guardarLote('9', {'id': 9, 'codigo': 'LOTE-9', 'estado': 'COMPLETADO'});
    expect((await cache.leerLote('9'))!.data['estado'], 'COMPLETADO');
  });

  test('usuario y volteos', () async {
    await cache.guardarUsuario({'id': 1, 'email': 'a@b.pe'});
    expect((await cache.leerUsuario())!.data['email'], 'a@b.pe');
    await cache.guardarVolteos('9', [
      {'id': 1, 'loteId': 9}
    ]);
    expect((await cache.leerVolteos('9'))!.data.length, 1);
    expect(await cache.leerVolteos('8'), isNull);
  });

  test('limpiarCacheDeSesion borra todo menos la cola de eventos', () async {
    await cache.guardarUsuario({'id': 1});
    await cache.guardarLotes([]);
    await cache.guardarLote('9', {'id': 9});
    await cache.guardarVolteos('9', []);
    store.datos[LocalStoreKeys.colaEventos] = '{"version":1,"eventos":[]}';

    await cache.limpiarCacheDeSesion();

    expect(await cache.leerUsuario(), isNull);
    expect(await cache.leerLotes(), isNull);
    expect(await cache.leerLote('9'), isNull);
    expect(await cache.leerVolteos('9'), isNull);
    expect(store.datos[LocalStoreKeys.colaEventos], '{"version":1,"eventos":[]}');
  });

  test('JSON corrupto se lee como vacío', () async {
    store.datos[LocalStoreKeys.lotes] = '{no es json';
    expect(await cache.leerLotes(), isNull);
  });
}
