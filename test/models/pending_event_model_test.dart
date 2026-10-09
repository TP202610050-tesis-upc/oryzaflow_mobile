import 'package:flutter_test/flutter_test.dart';
import 'package:oryzaflow_mobile/models/pending_event_model.dart';

import '../fakes/fake_batch_repository.dart';

void main() {
  final lote = FakeBatchRepository().lotePorDefecto('9');
  final ts = DateTime.utc(2026, 10, 9, 18, 5, 12, 345);

  test('ida y vuelta JSON para los cuatro tipos', () {
    final payloads = {
      TipoEvento.volteo: {'metodo': 'MANUAL'},
      TipoEvento.cubrir: {'motivo': 'LLUVIA'},
      TipoEvento.descubrir: {'m0': 22.5},
      TipoEvento.recoger: {'humedadFinal': 13.8},
    };
    for (final tipo in TipoEvento.values) {
      final e = PendingEvent.nuevo(
          tipo: tipo, lote: lote, ts: ts, payload: payloads[tipo]!, usuarioEmail: 'a@b.pe');
      final copia = PendingEvent.fromJson(e.toJson());
      expect(copia, e, reason: tipo.name);
      expect(copia.payload, payloads[tipo]);
      expect(copia.loteCodigo, 'LOTE-9');
      expect(copia.usuarioEmail, 'a@b.pe');
    }
  });

  test('conserva el ts al milisegundo y en UTC', () {
    final e = PendingEvent.nuevo(tipo: TipoEvento.volteo, lote: lote, ts: ts.toLocal());
    final json = e.toJson();
    expect(json['ts'], '2026-10-09T18:05:12.345Z');
    final copia = PendingEvent.fromJson(json);
    expect(copia.ts.isUtc, isTrue);
    expect(copia.ts, ts);
  });

  test('un estado desconocido se lee como pendiente', () {
    final json = PendingEvent.nuevo(tipo: TipoEvento.volteo, lote: lote, ts: ts).toJson()
      ..['estado'] = 'RARO';
    expect(PendingEvent.fromJson(json).estado, EstadoEvento.pendiente);
  });

  test('copyWith cambia estado e intentos y puede limpiar el error', () {
    final e = PendingEvent.nuevo(tipo: TipoEvento.volteo, lote: lote, ts: ts)
        .copyWith(estado: EstadoEvento.error, intentos: 2, ultimoError: 'x');
    expect(e.estado, EstadoEvento.error);
    expect(e.ultimoError, 'x');
    final limpio = e.copyWith(estado: EstadoEvento.pendiente, limpiarError: true);
    expect(limpio.ultimoError, isNull);
    expect(limpio.intentos, 2);
  });
}
