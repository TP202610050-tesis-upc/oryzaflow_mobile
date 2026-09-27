class RouteNames {
  RouteNames._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String recuperarContrasena = '/recuperar-contrasena';

  // Shell root
  static const String shell = '/';

  // Módulo 2
  static const String dashboard = '/dashboard';
  static const String alertas = '/alertas';

  // Módulo 3
  static const String silos = '/silos';
  static const String editarSilo = '/silos/editar';
  static const String variedades = '/silos/variedades';
  static const String editarVariedad = '/silos/variedades/editar';
  static const String perfilesSecado = '/silos/perfiles';
  static const String editarPerfilSecado = '/silos/perfiles/editar';
  static const String disponibilidad = '/silos/disponibilidad';

  // Módulo 4
  static const String lotes = '/lotes';
  static const String nuevoLote = '/lotes/nuevo';
  static const String detalleLote = '/lotes/:loteId';
  static String detalleLotePath(String id) => '/lotes/$id';
  static const String lecturasLote = '/lotes/:loteId/lecturas';
  static String lecturasLotePath(String id) => '/lotes/$id/lecturas';

  // Módulo 5
  static const String monitoreo = '/monitoreo';
  static const String configEsp32 = '/monitoreo/esp32';
  static const String detalleNodo = '/monitoreo/:nodoId';
  static String detalleNodoPath(String id) => '/monitoreo/$id';

  // Módulo 6
  static const String reportes = '/reportes';
  static const String graficasSecado = '/reportes/graficas';
  static const String kpis = '/reportes/kpis';
  static const String exportarReporte = '/reportes/exportar';

  // Módulo 7
  static const String usuarios = '/usuarios';
  static const String nuevoUsuario = '/usuarios/nuevo';
  static const String detalleUsuario = '/usuarios/:usuarioId';
  static String detalleUsuarioPath(String id) => '/usuarios/$id';

  // Módulo 8
  static const String configuracion = '/configuracion';
  static const String calibrarSensores = '/configuracion/calibrar';
  static const String ayudaFaq = '/configuracion/ayuda';
  static const String preferencias = '/configuracion/preferencias';

  // Perfil propio
  static const String editarPerfil = '/perfil/editar';
}
