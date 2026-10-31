class AppStrings {
  AppStrings._();

  // App
  static const String appNombre = 'OryzaFlow';
  static const String appSlogan = 'Monitoreo Inteligente de Secado';

  // Auth
  static const String correoElectronico = 'Correo electrónico';
  static const String contrasena = 'Contraseña';
  static const String iniciarSesion = 'Iniciar Sesión';
  static const String cerrarSesion = 'Cerrar Sesión';
  static const String recuperarContrasena = 'Recuperar Contraseña';
  static const String olvidasteContrasena = '¿Olvidaste tu contraseña?';
  static const String nuevaContrasena = 'Nueva Contraseña';
  static const String confirmarContrasena = 'Confirmar Contraseña';
  static const String contrasenaActual = 'Contraseña Actual';
  static const String enviarCodigo = 'Enviar Código';
  static const String credencialesInvalidas = 'Correo o contraseña incorrectos';
  static const String correoEnviado =
      'Se envió un correo con las instrucciones';
  static const String campoRequerido = 'Este campo es requerido';
  static const String correoInvalido = 'Ingresa un correo válido';
  static const String contrasenasNoCoinciden = 'Las contraseñas no coinciden';
  static const String editarPerfil = 'Editar Perfil';
  static const String guardarCambios = 'Guardar Cambios';
  static const String nombreCompleto = 'Nombre completo';
  static const String telefono = 'Teléfono';
  static const String cambiarContrasena = 'Cambiar contraseña';
  static const String credencialesDePrueba = 'Credenciales de prueba';

  // Navigation
  static const String navInicio = 'Inicio';
  static const String navMonitoreo = 'Monitoreo';
  static const String navLotes = 'Lotes';
  static const String navSilos = 'Silos';
  static const String navAlertas = 'Alertas';
  static const String navReportes = 'Reportes';
  static const String navUsuarios = 'Usuarios';
  static const String navConfiguracion = 'Configuración';
  static const String navPerfil = 'Mi Perfil';

  // Dashboard
  static const String dashboard = 'Panel';
  static const String nodosActivos = 'Nodos Activos';
  static const String lotesEnProceso = 'Lotes en Proceso';
  static const String alertasActivas = 'Alertas Activas';
  static const String produccionHoy = 'Producción Hoy';
  static const String resumenDelDia = 'Resumen del Día';
  static const String ultimas24horas = 'Últimas 24 horas';
  static const String estadoSilos = 'Estado de Silos';
  static const String alertasRecientes = 'Alertas Recientes';
  static const String verTodas = 'Ver todas';

  // Alerts
  static const String alertas = 'Alertas';
  static const String marcarLeida = 'Marcar como leída';
  static const String marcarTodasLeidas = 'Marcar todas como leídas';
  static const String sinAlertas = 'Sin alertas pendientes';
  static const String todasLeidas = 'Todas las alertas han sido revisadas';
  // CA-015-02 (HU-015): reenvío al supervisor de alertas no atendidas
  static const String reenviadaSupervisor = 'Reenviada al supervisor';
  static const String reenviada = 'Reenviada';
  static const String filtroReenviadas = 'Reenviadas';
  static const String minSinAtender = 'min sin atender';
  static const String sinReenviadas = 'Ninguna alerta reenviada al supervisor';

  // Silos
  static const String silos = 'Silos';
  static const String nuevoSilo = 'Nuevo Silo';
  static const String editarSilo = 'Editar Silo';
  static const String eliminarSilo = 'Eliminar Silo';
  static const String nombreSilo = 'Nombre del silo';
  static const String ubicacion = 'Ubicación';
  static const String capacidadToneladas = 'Capacidad (kg)';
  static const String estadoSilo = 'Estado';
  static const String disponibilidad = 'Disponibilidad';
  static const String disponible = 'Disponible';
  static const String ocupado = 'Ocupado';
  static const String mantenimiento = 'Mantenimiento';

  // Varieties
  static const String variedades = 'Variedades';
  static const String nuevaVariedad = 'Nueva Variedad';
  static const String editarVariedad = 'Editar Variedad';
  static const String nombreVariedad = 'Nombre de la variedad';
  static const String descripcion = 'Descripción';
  static const String humedadObjetivo = 'Humedad objetivo (%)';
  static const String temperaturaMaxima = 'Temperatura máxima (°C)';
  static const String tiempoEstimado = 'Tiempo estimado (horas)';

  // Drying profiles (perfiles de secado)
  static const String perfilesSecado = 'Perfiles de secado';
  static const String nuevoPerfilSecado = 'Nuevo Perfil';
  static const String editarPerfilSecado = 'Editar Perfil de Secado';
  static const String nombrePerfil = 'Nombre del perfil';
  static const String humedadGranoObjetivo = 'Humedad del grano objetivo (%)';
  static const String temperaturaObjetivo = 'Temperatura objetivo (°C)';
  static const String duracionEstimada = 'Duración estimada (min)';

  // Batches
  static const String lotes = 'Lotes de Secado';
  static const String nuevoLote = 'Nuevo Lote';
  static const String detalleLote = 'Detalle del Lote';
  static const String codigoLote = 'Código de lote';
  static const String variedadArroz = 'Variedad de arroz';
  static const String siloAsignado = 'Silo asignado';
  static const String nodoAsignado = 'Nodo asignado';
  static const String perfilSecado = 'Perfil de secado';
  static const String pesoKg = 'Peso (kg)';
  static const String humedadInicial = 'Humedad inicial (%)';
  static const String humedadFinal = 'Humedad final (%)';
  static const String iniciarSecado = 'Iniciar Secado';
  static const String detenerSecado = 'Detener Secado';
  static const String loteActivo = 'Lote en proceso';
  static const String loteCompletado = 'Lote completado';
  static const String loteCancelado = 'Lote cancelado';
  static const String lotePendiente = 'Pendiente';
  // Reglas de excepción (Cuaderno 4, 27/09/2026). Textos de los CA: no parafrasear.
  static const String destinoComercial = 'Destino comercial';
  static const String destinoComercialObligatorio =
      'Indique si el lote es para saco de marca o genérico para fijar la humedad meta'; // CA-006-02
  static const String datoDesactualizado =
      'Dato desactualizado — verifique con el medidor'; // CA-001-02
  static const String noLlegaraHoy = 'No llegará a la meta hoy'; // CA-003-02
  static const String porVerificar = 'Por verificar'; // CA-013-02
  static const String estimacionActual = 'Estimación';
  static const String humedadEstimada = 'Humedad estimada del grano';
  static const String sinEstimacion = 'Sin estimación aún: el nodo no ha publicado con el lote activo';
  static const String finEstimado = 'Fin estimado';
  static const String lecturasMedidor = 'Lecturas del medidor';
  static const String registrarLectura = 'Registrar lectura';
  static const String lecturaRegistrada = 'Lectura registrada';
  static const String mantada = 'Mantada';
  static const String sinLecturasManuales = 'Aún no hay lecturas del medidor para este lote';
  static const String curvaSinDatos =
      'Aún no hay datos suficientes para la curva'; // CA-009-02

  // Monitoring
  static const String monitoreo = 'Monitoreo';
  static const String configEsp32 = 'Config. ESP32';
  static const String lecturasEnVivo = 'Lecturas en Vivo';
  static const String ultimasDoceHoras = 'Últimas 2 horas';
  static const String lecturasDelLote = 'Lecturas del lote';
  static const String volteoManual = 'Volteo manual';
  static const String registrarVolteo = 'Registrar volteo';
  static const String ipAddress = 'Dirección IP';
  static const String puerto = 'Puerto';
  static const String intervaloEnvio = 'Intervalo de envío (s)';
  static const String calibracion = 'Calibración de sensores';
  static const String sinDatosClima = 'Sin datos recientes del clima'; // CA-002-02
  static const String ultimaLecturaValida = 'Última lectura válida';

  // Sensors
  static const String temperatura = 'Temperatura';
  static const String humedad = 'Humedad';
  static const String flujoAire = 'Flujo de Aire';
  static const String humedadGrano = 'Humedad del Grano';
  static const String unidadCelsius = '°C';
  static const String unidadPorcentaje = '%';
  static const String unidadKg = 'kg';

  // Reports
  static const String reportes = 'Reportes';
  static const String historialSecados = 'Historial de Secados';
  static const String graficasSecado = 'Gráficas de Secado';
  static const String kpisGerenciales = 'KPIs Gerenciales';
  static const String exportarReporte = 'Exportar Reporte';
  static const String fechaDesde = 'Fecha desde';
  static const String fechaHasta = 'Fecha hasta';
  static const String formatoPdf = 'PDF';
  static const String formatoCsv = 'CSV';
  static const String exportar = 'Exportar';
  static const String sinLotesEnPeriodo = 'No hay lotes en ese periodo'; // CA-011-02
  static const String eficienciaEnergetica = 'Eficiencia Energética';
  static const String totalKgProcesados = 'Total Kg Procesados';
  static const String tiempoPromedio = 'Tiempo Promedio';
  static const String tasaExito = 'Tasa de Éxito';

  // Users
  static const String usuarios = 'Usuarios';
  static const String nuevoUsuario = 'Nuevo Usuario';
  static const String detalleUsuario = 'Detalle de Usuario';
  static const String rol = 'Rol';
  static const String estado = 'Estado';
  static const String activo = 'Activo';
  static const String inactivo = 'Inactivo';
  static const String activarCuenta = 'Activar cuenta';
  static const String desactivarCuenta = 'Desactivar cuenta';
  static const String crearUsuario = 'Crear Usuario';

  // Settings
  static const String configuracion = 'Configuración';
  static const String calibrarSensores = 'Calibrar Sensores';
  static const String ayudaFaq = 'Ayuda / FAQ';
  static const String preferencias = 'Preferencias';
  static const String tema = 'Tema';
  static const String idioma = 'Idioma';
  static const String unidades = 'Unidades';
  static const String notificaciones = 'Notificaciones';
  static const String sonidoAlertas = 'Sonido de alertas';
  static const String sistemaGeneral = 'General del sistema';

  // Common
  static const String guardar = 'Guardar';
  static const String cancelar = 'Cancelar';
  static const String eliminar = 'Eliminar';
  static const String editar = 'Editar';
  static const String crear = 'Crear';
  static const String aceptar = 'Aceptar';
  static const String reintentar = 'Reintentar';
  static const String cargando = 'Cargando...';
  static const String sinDatos = 'Sin datos disponibles';
  static const String errorCargando = 'Error al cargar los datos';
  static const String confirmarEliminar = '¿Eliminar este elemento?';
  static const String accionIrreversible =
      'Esta acción no se puede deshacer.';
  static const String si = 'Sí';
  static const String no = 'No';
  static const String ultimaActualizacion = 'Última actualización';
  static const String hace = 'hace';
  static const String horas = 'h';
  static const String minutos = 'min';
  static const String segundos = 's';
  static const String operacion = 'Operación';
  static const String exitosa = 'exitosa';
  static const String fallida = 'fallida';
  static const String volver = 'Volver';
  static const String siguiente = 'Siguiente';
  static const String finalizar = 'Finalizar';
  static const String buscar = 'Buscar';
  static const String filtrar = 'Filtrar';
  static const String todos = 'Todos';
  static const String semana = 'Semana';
  static const String mes = 'Mes';
  static const String anio = 'Año';

  // ── Registro sin señal y sincronización (HU-010, CA-010-02) ──
  static const String sincronizacion = 'Sincronización';
  static const String sincronizarAhora = 'Sincronizar ahora';
  static const String sinEventosPendientes = 'No hay eventos pendientes';
  static const String cubrirLote = 'Cubrir';
  static const String descubrirLote = 'Descubrir';
  static const String detener = 'Detener';
  static const String cubrirExplicacion = 'Cierra el tramo de secado actual. Indique el motivo:';
  static const String descubrirExplicacion =
      'Abre un nuevo tramo de secado. Ingrese la humedad inicial del tramo (M0) medida con el PM-410:';
  static const String m0Tramo = 'M0 (% b.h.)';
  static const String humedadFinalOpcional = 'Humedad final (%) — opcional';
  static const String rango5a40 = 'Entre 5 y 40 % b.h.';
  static const String sinConexion = 'Sin conexión';
  static const String datosGuardadosALas = 'datos guardados a las';
  static const String offlineAcciones =
      'Puede registrar volteos, cubrir, descubrir y detener; se enviarán al recuperar la señal.';
  static const String offlineSeEnviaran =
      'Sin conexión — los eventos se enviarán automáticamente al recuperar la señal';
  static const String pendienteSincronizar = 'pendiente de sincronizar';
  static const String descartar = 'Descartar';
  static const String descartarEvento = 'Descartar evento';
  static const String descartarEventoMensaje =
      '¿Descartar este evento? El registro se perderá y no se enviará al servidor.';
  static const String requiereConexion = 'Requiere conexión';
  static const String volteos = 'Volteos';
  static const String sinVolteos = 'Sin volteos registrados';
  static const String intentos = 'Intentos';
  static const String errores = 'Errores';
  static const String pendientes = 'Pendientes';
  static const String sincronizadosRecientes = 'Sincronizados (últimas 24 h)';
}
