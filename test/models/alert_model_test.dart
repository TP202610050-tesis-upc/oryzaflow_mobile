import 'package:flutter_test/flutter_test.dart';
import 'package:oryzaflow_mobile/core/enums/alert_severity.dart';
import 'package:oryzaflow_mobile/models/alert_model.dart';

Map<String, dynamic> _base() => {
      'id': 7,
      'nodoId': 3,
      'nodoNombre': 'Nodo A',
      'mensaje': 'Humedad meta alcanzada, recoger el grano.',
      'severidad': 'informacion',
      'timestamp': '2026-10-09T14:00:00Z',
      'leida': false,
      'loteId': 'LOTE-9',
      'tipo': 'PROCESO_COMPLETO',
      'batchId': 9,
    };

void main() {
  test('sin campos de escalamiento: escalada=false y nulos', () {
    final a = AlertModel.fromJson(_base());
    expect(a.escalada, isFalse);
    expect(a.escaladaEn, isNull);
    expect(a.escaladaA, isNull);
    expect(a.escaladaDispositivos, isNull);
    expect(a.minutosSinAtender, isNull);
    expect(a.severidad, AlertSeverity.informacion);
  });

  test('escaladaEn null explícito: escalada=false', () {
    final a = AlertModel.fromJson(
        {..._base(), 'escaladaEn': null, 'escaladaA': null});
    expect(a.escalada, isFalse);
  });

  test('con escalamiento lee los cuatro campos', () {
    final a = AlertModel.fromJson({
      ..._base(),
      'escaladaEn': '2026-10-09T14:31:00Z',
      'escaladaA': 'SUPERVISOR',
      'escaladaDispositivos': 2,
      'minutosSinAtender': 31,
    });
    expect(a.escalada, isTrue);
    // parseFechaNullable devuelve hora local; DateTime== exige la misma zona.
    expect(a.escaladaEn!.toUtc(), DateTime.utc(2026, 10, 9, 14, 31));
    expect(a.escaladaA, 'SUPERVISOR');
    expect(a.escaladaDispositivos, 2);
    expect(a.minutosSinAtender, 31);
  });

  test('copyWith(leida) conserva el escalamiento', () {
    final a = AlertModel.fromJson({
      ..._base(),
      'escaladaEn': '2026-10-09T14:31:00Z',
      'escaladaA': 'SUPERVISOR',
    }).copyWith(leida: true);
    expect(a.leida, isTrue);
    expect(a.escalada, isTrue);
    expect(a.escaladaA, 'SUPERVISOR');
  });
}
