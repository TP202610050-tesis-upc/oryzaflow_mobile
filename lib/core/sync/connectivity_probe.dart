import 'package:connectivity_plus/connectivity_plus.dart';

/// Estado de red del teléfono (HU-010, CA-010-02). Abstraído para poder simularlo en pruebas.
abstract class ConnectivityProbe {
  Future<bool> hayRed();
  Stream<bool> get cambios;
}

class PlusConnectivityProbe implements ConnectivityProbe {
  final Connectivity _connectivity = Connectivity();

  @override
  Future<bool> hayRed() async => _esRed(await _connectivity.checkConnectivity());

  @override
  Stream<bool> get cambios => _connectivity.onConnectivityChanged.map(_esRed).distinct();

  static bool _esRed(List<ConnectivityResult> r) =>
      r.isNotEmpty && !r.every((x) => x == ConnectivityResult.none);
}
