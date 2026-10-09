import 'dart:math';

/// UUID v4 (RFC 4122) generado con `Random.secure()`. Se usa como `clientEventId` de los eventos
/// del lote (HU-010, CA-010-02): el backend lo trata como clave de idempotencia al sincronizar.
/// Sin dependencia externa: el paquete `uuid` solo está en el lock como transitiva.
String uuidV4([Random? rng]) {
  final r = rng ?? Random.secure();
  final b = List<int>.generate(16, (_) => r.nextInt(256));
  b[6] = (b[6] & 0x0f) | 0x40; // versión 4
  b[8] = (b[8] & 0x3f) | 0x80; // variante RFC 4122
  final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
  return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-'
      '${h.substring(16, 20)}-${h.substring(20)}';
}
