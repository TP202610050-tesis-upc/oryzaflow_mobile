import 'dart:async';

import 'package:oryzaflow_mobile/core/sync/connectivity_probe.dart';

/// Sonda de red controlable desde las pruebas.
class FakeConnectivityProbe implements ConnectivityProbe {
  bool red;
  final _ctrl = StreamController<bool>.broadcast();

  FakeConnectivityProbe({this.red = true});

  @override
  Future<bool> hayRed() async => red;

  @override
  Stream<bool> get cambios => _ctrl.stream;

  /// Simula el cambio de conectividad del SO.
  void emitir(bool hayRed) {
    red = hayRed;
    _ctrl.add(hayRed);
  }

  Future<void> cerrar() => _ctrl.close();
}
