import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final _fmtFechaHora = DateFormat('dd/MM/yyyy HH:mm', 'es');
  static final _fmtFecha = DateFormat('dd MMMM yyyy', 'es');
  static final _fmtFechaCorta = DateFormat('dd/MM/yyyy', 'es');
  static final _fmtHora = DateFormat('HH:mm', 'es');
  static final _fmtRelativo = DateFormat('dd/MM HH:mm', 'es');

  static String fechaHora(DateTime dt) => _fmtFechaHora.format(dt);
  static String fecha(DateTime dt) => _fmtFecha.format(dt);
  static String fechaCorta(DateTime dt) => _fmtFechaCorta.format(dt);
  static String hora(DateTime dt) => _fmtHora.format(dt);
  static String relativo(DateTime dt) => _fmtRelativo.format(dt);

  static String duracion(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h == 0) return '${m}min';
    return '${h}h ${m}min';
  }

  static String tiempoTranscurrido(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'hace ${diff.inSeconds}s';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'hace ${diff.inHours}h';
    return 'hace ${diff.inDays}d';
  }
}
