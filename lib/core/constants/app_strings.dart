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

  // Silos
  static const String silos = 'Silos';
  static const String nuevoSilo = 'Nuevo Silo';
  static const String editarSilo = 'Editar Silo';
  static const String eliminarSilo = 'Eliminar Silo';
  static const String nombreSilo = 'Nombre del silo';
  static const String ubicacion = 'Ubicación';
  static const String capacidadToneladas = 'Capacidad (toneladas)';
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

  // Monitoring
  static const String monitoreo = 'Monitoreo';
  static const String parametros = 'Parámetros';
  static const String configEsp32 = 'Config. ESP32';
  static const String lecturasEnVivo = 'Lecturas en Vivo';
  static const String ultimasDoceHoras = 'Últimas 2 horas';
  static const String volteoManual = 'Volteo manual';
  static const String registrarVolteo = 'Registrar volteo';
  static const String ipAddress = 'Dirección IP';
  static const String puerto = 'Puerto';
  static const String intervaloEnvio = 'Intervalo de envío (s)';
  static const String calibracion = 'Calibración de sensores';
  static const String umbralMinimo = 'Mín.';
  static const String umbralMaximo = 'Máx.';

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
}
