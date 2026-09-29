import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Resultado de intentar cambiar el estado de las notificaciones.
/// Lo consume la UI para decidir qué mensaje mostrar, sin acoplar el provider
/// a widgets/SnackBars.
enum NotifToggleResult {
  concedido,
  denegado,
  requiereAjustes,
  desactivado,
}

/// Gestiona la preferencia de notificaciones (persistida localmente) junto con
/// el permiso real del sistema operativo.
///
/// El valor efectivo del switch ([activadas]) es `preferencia && permisoConcedido`:
/// si el usuario revoca el permiso desde los ajustes del SO, el switch refleja
/// la verdad (apagado) aunque la preferencia guardada fuera `true`.
class NotificationsProvider extends ChangeNotifier {
  static const String _prefKey = 'notificacionesActivas';

  bool _prefActivadas = true;
  bool _permisoConcedido = false;
  bool _cargando = true;

  /// Gancho que fija `main` (HU-012): true → registrar token push; false → retirarlo.
  Future<void> Function(bool activadas)? alCambiar;

  /// Valor efectivo para el switch: solo está activo si el usuario lo quiere
  /// y el SO concedió el permiso.
  bool get activadas => _prefActivadas && _permisoConcedido;
  bool get permisoConcedido => _permisoConcedido;

  /// Preferencia guardada por el usuario (true por defecto), sin considerar el permiso del SO.
  bool get preferenciaActivada => _prefActivadas;
  bool get cargando => _cargando;

  /// Lee la preferencia guardada y el estado actual del permiso del SO.
  Future<void> cargar() async {
    _cargando = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    _prefActivadas = prefs.getBool(_prefKey) ?? true;
    _permisoConcedido = await Permission.notification.isGranted;
    _cargando = false;
    notifyListeners();
  }

  /// Activa o desactiva las notificaciones.
  ///
  /// Al activar, solicita el permiso real al SO. Devuelve un [NotifToggleResult]
  /// para que la UI muestre el feedback adecuado.
  Future<NotifToggleResult> setActivadas(bool valor) async {
    if (!valor) {
      await _persistir(false);
      _permisoConcedido = await Permission.notification.isGranted;
      notifyListeners();
      await alCambiar?.call(false);
      return NotifToggleResult.desactivado;
    }

    final status = await Permission.notification.request();
    _permisoConcedido = status.isGranted;

    if (status.isGranted) {
      await _persistir(true);
      notifyListeners();
      await alCambiar?.call(true);
      return NotifToggleResult.concedido;
    }

    // No concedido: mantenemos la preferencia en false para que el switch
    // quede apagado de forma coherente.
    await _persistir(false);
    notifyListeners();
    return status.isPermanentlyDenied
        ? NotifToggleResult.requiereAjustes
        : NotifToggleResult.denegado;
  }

  /// Abre los ajustes del sistema para que el usuario conceda el permiso
  /// cuando fue denegado permanentemente.
  Future<void> abrirAjustes() => openAppSettings();

  Future<void> _persistir(bool valor) async {
    _prefActivadas = valor;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, valor);
  }
}
