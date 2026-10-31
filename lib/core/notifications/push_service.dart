import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../repositories/i_alert_repository.dart';

/// En segundo plano o con la app cerrada, Android muestra por sí mismo la notificación del payload
/// (`notification` + canal `oryzaflow_alertas` con sonido); aquí no hace falta nada más.
@pragma('vm:entry-point')
Future<void> oryzaflowBackgroundHandler(RemoteMessage message) async {}

/// Notificaciones push (HU-012, CONTEXTO §10.3): inicializa Firebase, crea el canal con sonido, muestra en
/// primer plano las alertas que llegan por FCM y registra/elimina el token del dispositivo en el backend
/// (`POST/DELETE /notifications/device-tokens`). El backend envía SECADO_TERMINADO, TEMPERATURA_FUERA_RANGO y
/// SENSOR_DESCONECTADO y, solo a los supervisores, ESCALAMIENTO_SUPERVISOR (CA-015-02: alerta no atendida en el
/// tiempo de atención); FCM conserva el mensaje hasta que el teléfono recupera la red (CA-012-02).
class PushService {
  static const String canalId = 'oryzaflow_alertas';
  static const String canalNombre = 'Alertas de secado';

  final IAlertRepository _alertas;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  bool _listo = false;
  String? _token;
  String? _tokenRegistrado;

  /// Switch de notificaciones de la app (NotificationsProvider). Apagado: no se muestra nada en primer plano
  /// y el token se retira del backend.
  bool habilitadas = true;

  /// Navegación al tocar una notificación (la fija `main` con el router → pantalla de alertas).
  void Function()? onAbrirAlertas;

  PushService(this._alertas);

  bool get listo => _listo;
  String? get token => _token;

  Future<void> init() async {
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(oryzaflowBackgroundHandler);

      const canal = AndroidNotificationChannel(
        canalId,
        canalNombre,
        description: 'Lote listo para recoger, temperatura fuera de rango y nodo desconectado',
        importance: Importance.max,
        playSound: true,
      );
      await _local.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
        onDidReceiveNotificationResponse: (_) => onAbrirAlertas?.call(),
      );
      await _local
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(canal);

      FirebaseMessaging.onMessage.listen(_mostrarEnPrimerPlano);
      FirebaseMessaging.onMessageOpenedApp.listen((_) => onAbrirAlertas?.call());
      final inicial = await FirebaseMessaging.instance.getInitialMessage();
      if (inicial != null) Future.microtask(() => onAbrirAlertas?.call());
      FirebaseMessaging.instance.onTokenRefresh.listen((t) {
        _token = t;
        if (_tokenRegistrado != null) registrar();
      });
      _listo = true;
    } catch (e) {
      // Sin google-services.json o sin Play Services la app sigue funcionando sin push.
      debugPrint('PushService: sin FCM ($e)');
    }
  }

  /// CP-012-01: en primer plano FCM no muestra nada por sí solo; se muestra con el canal con sonido.
  Future<void> _mostrarEnPrimerPlano(RemoteMessage m) async {
    if (!habilitadas) return;
    final n = m.notification;
    final titulo = n?.title ?? 'OryzaFlow';
    final cuerpo = n?.body ?? m.data['mensaje']?.toString() ?? '';
    await _local.show(
      id: m.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: titulo,
      body: cuerpo,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          canalId,
          canalNombre,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
      ),
    );
  }

  /// Registra el token del dispositivo para el usuario autenticado (idempotente).
  Future<void> registrar() async {
    if (!_listo || !habilitadas) return;
    try {
      _token ??= await FirebaseMessaging.instance.getToken();
      final t = _token;
      if (t == null) return;
      await _alertas.registrarTokenDispositivo(
        t,
        plataforma: Platform.isAndroid ? 'android' : Platform.operatingSystem,
      );
      _tokenRegistrado = t;
      debugPrint('PushService: token registrado');
    } catch (e) {
      debugPrint('PushService registrar: $e');
    }
  }

  /// Retira el token (cierre de sesión o notificaciones apagadas). Requiere sesión vigente.
  Future<void> desregistrar() async {
    final t = _tokenRegistrado ?? _token;
    if (t == null) return;
    try {
      await _alertas.eliminarTokenDispositivo(t);
    } catch (e) {
      debugPrint('PushService desregistrar: $e');
    }
    _tokenRegistrado = null;
  }
}
