import 'dart:math';
import '../../core/enums/alert_severity.dart';
import '../../core/enums/batch_status.dart';
import '../../core/enums/drying_stage.dart';
import '../../core/enums/node_status.dart';
import '../../core/enums/user_role.dart';
import '../../models/alert_model.dart';
import '../../models/batch_model.dart';
import '../../models/dashboard_summary_model.dart';
import '../../models/drying_profile_model.dart';
import '../../models/esp32_config_model.dart';
import '../../models/kpi_model.dart';
import '../../models/node_model.dart';
import '../../models/sensor_reading_model.dart';
import '../../models/silo_model.dart';
import '../../models/threshold_model.dart';
import '../../models/user_model.dart';
import '../../models/variety_model.dart';

class MockData {
  MockData._();

  static final List<UserModel> usuarios = [
    UserModel(
      id: 'u1',
      nombre: 'Carlos Mendoza',
      email: 'operador@oryzaflow.com',
      passwordHash: 'demo123',
      rol: UserRole.operador,
      activo: true,
      telefono: '+51 987 654 321',
      creadoEn: DateTime(2024, 1, 15),
    ),
    UserModel(
      id: 'u2',
      nombre: 'Luisanny',
      email: 'supervisor@oryzaflow.com',
      passwordHash: 'demo123',
      rol: UserRole.supervisor,
      activo: true,
      telefono: '+51 912 345 678',
      creadoEn: DateTime(2023, 11, 3),
    ),
    UserModel(
      id: 'u3',
      nombre: 'Andrés Torres',
      email: 'admin@oryzaflow.com',
      passwordHash: 'demo123',
      rol: UserRole.admin,
      activo: true,
      telefono: '+51 956 789 012',
      creadoEn: DateTime(2023, 6, 20),
    ),
  ];

  static final List<VarietyModel> variedades = [
    const VarietyModel(
      id: 'v1',
      nombre: 'IR-43',
      descripcion: 'Variedad de arroz de grano largo, alto rendimiento',
      humedadIngresoMinima: 18.0,
      humedadIngresoMaxima: 28.0,
      humedadObjetivo: 14.0,
      temperaturaMaxima: 55.0,
      tiempoEstimadoHoras: 8,
    ),
    const VarietyModel(
      id: 'v2',
      nombre: 'Tinajones',
      descripcion: 'Variedad costeña, grano corto y aromático',
      humedadIngresoMinima: 20.0,
      humedadIngresoMaxima: 30.0,
      humedadObjetivo: 13.5,
      temperaturaMaxima: 50.0,
      tiempoEstimadoHoras: 10,
    ),
    const VarietyModel(
      id: 'v3',
      nombre: 'Capirona',
      descripcion: 'Alta productividad, resistente a plagas',
      humedadIngresoMinima: 16.0,
      humedadIngresoMaxima: 26.0,
      humedadObjetivo: 14.0,
      temperaturaMaxima: 58.0,
      tiempoEstimadoHoras: 7,
    ),
  ];

  static final List<SiloModel> silos = [
    const SiloModel(
      id: 's1',
      nombre: 'Silo 1',
      ubicacion: 'Almacén Norte - Nave A',
      capacidadToneladas: 50.0,
      estado: SiloStatus.ocupado,
      loteActivoId: 'lot1',
      ocupacionActualToneladas: 38.5,
    ),
    const SiloModel(
      id: 's2',
      nombre: 'Silo 2',
      ubicacion: 'Almacén Norte - Nave B',
      capacidadToneladas: 50.0,
      estado: SiloStatus.ocupado,
      loteActivoId: 'lot2',
      ocupacionActualToneladas: 25.0,
    ),
    const SiloModel(
      id: 's3',
      nombre: 'Silo 3',
      ubicacion: 'Almacén Sur - Nave A',
      capacidadToneladas: 80.0,
      estado: SiloStatus.disponible,
      ocupacionActualToneladas: 0,
    ),
    const SiloModel(
      id: 's4',
      nombre: 'Silo 4',
      ubicacion: 'Almacén Sur - Nave B',
      capacidadToneladas: 80.0,
      estado: SiloStatus.mantenimiento,
    ),
  ];

  static final List<DryingProfileModel> perfiles = [
    DryingProfileModel(
      id: 'p1',
      nombre: 'Secado Estándar IR-43',
      descripcion: 'Perfil optimizado para variedad IR-43, secado gradual',
      temperaturaObjetivo: 48.0,
      humedadObjetivo: 30.0,
      flujoAireObjetivo: 75.0,
      humedadGranoObjetivo: 14.0,
      duracionEstimadaMinutos: 480,
      creadoEn: DateTime(2024, 2, 10),
      creadoPorId: 'u3',
    ),
    DryingProfileModel(
      id: 'p2',
      nombre: 'Secado Rápido Capirona',
      descripcion: 'Alta temperatura, para lotes urgentes con bajo riesgo',
      temperaturaObjetivo: 55.0,
      humedadObjetivo: 25.0,
      flujoAireObjetivo: 90.0,
      humedadGranoObjetivo: 14.0,
      duracionEstimadaMinutos: 360,
      creadoEn: DateTime(2024, 3, 5),
      creadoPorId: 'u2',
    ),
    DryingProfileModel(
      id: 'p3',
      nombre: 'Secado Suave Tinajones',
      descripcion: 'Temperatura moderada para preservar aroma',
      temperaturaObjetivo: 42.0,
      humedadObjetivo: 35.0,
      flujoAireObjetivo: 65.0,
      humedadGranoObjetivo: 13.5,
      duracionEstimadaMinutos: 600,
      creadoEn: DateTime(2024, 4, 18),
      creadoPorId: 'u3',
    ),
  ];

  static final _now = DateTime.now();

  static final List<NodeModel> nodos = [
    NodeModel(
      id: 'nodo-a',
      nombre: 'Nodo A',
      ubicacion: 'Silo 1 — Sensor Central',
      estado: NodeStatus.activo,
      temperatura: 48.2,
      humedad: 32.1,
      flujoAire: 78.0,
      humedadGrano: 14.5,
      ultimaActualizacion: _now.subtract(const Duration(seconds: 30)),
      ipAddress: '192.168.1.101',
      intervaloEnvioSegundos: 10,
      loteActivoId: 'lot1',
    ),
    NodeModel(
      id: 'nodo-b',
      nombre: 'Nodo B',
      ubicacion: 'Silo 2 — Sensor Central',
      estado: NodeStatus.activo,
      temperatura: 52.7,
      humedad: 28.4,
      flujoAire: 82.0,
      humedadGrano: 13.1,
      ultimaActualizacion: _now.subtract(const Duration(seconds: 15)),
      ipAddress: '192.168.1.102',
      intervaloEnvioSegundos: 10,
      loteActivoId: 'lot2',
    ),
    NodeModel(
      id: 'nodo-c',
      nombre: 'Nodo C',
      ubicacion: 'Silo 3 — Sin asignar',
      estado: NodeStatus.alerta,
      temperatura: 61.3,
      humedad: 19.8,
      flujoAire: 95.0,
      humedadGrano: 12.0,
      ultimaActualizacion: _now.subtract(const Duration(minutes: 2)),
      ipAddress: '192.168.1.103',
      intervaloEnvioSegundos: 5,
    ),
    NodeModel(
      id: 'nodo-d',
      nombre: 'Nodo D',
      ubicacion: 'Silo 4 — Mantenimiento',
      estado: NodeStatus.inactivo,
      temperatura: 28.0,
      humedad: 65.0,
      flujoAire: 0.0,
      humedadGrano: 22.3,
      ultimaActualizacion: _now.subtract(const Duration(hours: 3)),
      ipAddress: '192.168.1.104',
      intervaloEnvioSegundos: 30,
    ),
  ];

  static final List<BatchModel> lotes = [
    BatchModel(
      id: 'lot1',
      codigo: 'LOT-2025-001',
      siloId: 's1',
      siloNombre: 'Silo 1',
      variedadId: 'v1',
      variedadNombre: 'IR-43',
      perfilSecadoId: 'p1',
      perfilSecadoNombre: 'Secado Estándar IR-43',
      nodoId: 'nodo-a',
      nodoNombre: 'Nodo A',
      estado: BatchStatus.enProceso,
      etapaActual: DryingStage.secado,
      pesoKg: 38500,
      humedadInicial: 24.5,
      fechaIngreso: _now.subtract(const Duration(hours: 10)),
      fechaInicio: _now.subtract(const Duration(hours: 9)),
      operadorId: 'u1',
      operadorNombre: 'Carlos Mendoza',
    ),
    BatchModel(
      id: 'lot2',
      codigo: 'LOT-2025-002',
      siloId: 's2',
      siloNombre: 'Silo 2',
      variedadId: 'v3',
      variedadNombre: 'Capirona',
      perfilSecadoId: 'p2',
      perfilSecadoNombre: 'Secado Rápido Capirona',
      nodoId: 'nodo-b',
      nodoNombre: 'Nodo B',
      estado: BatchStatus.enProceso,
      etapaActual: DryingStage.enfriamiento,
      pesoKg: 25000,
      humedadInicial: 26.0,
      fechaIngreso: _now.subtract(const Duration(hours: 8)),
      fechaInicio: _now.subtract(const Duration(hours: 7, minutes: 30)),
      operadorId: 'u1',
      operadorNombre: 'Carlos Mendoza',
    ),
    BatchModel(
      id: 'lot3',
      codigo: 'LOT-2025-003',
      siloId: 's3',
      siloNombre: 'Silo 3',
      variedadId: 'v2',
      variedadNombre: 'Tinajones',
      perfilSecadoId: 'p3',
      perfilSecadoNombre: 'Secado Suave Tinajones',
      nodoId: 'nodo-a',
      nodoNombre: 'Nodo A',
      estado: BatchStatus.completado,
      etapaActual: DryingStage.completado,
      pesoKg: 42000,
      humedadInicial: 22.1,
      humedadFinal: 13.6,
      fechaIngreso: _now.subtract(const Duration(days: 2, hours: 3)),
      fechaInicio: _now.subtract(const Duration(days: 2, hours: 2)),
      fechaFin: _now.subtract(const Duration(days: 1, hours: 16)),
      operadorId: 'u1',
      operadorNombre: 'Carlos Mendoza',
    ),
    BatchModel(
      id: 'lot4',
      codigo: 'LOT-2025-004',
      siloId: 's1',
      siloNombre: 'Silo 1',
      variedadId: 'v1',
      variedadNombre: 'IR-43',
      perfilSecadoId: 'p1',
      perfilSecadoNombre: 'Secado Estándar IR-43',
      nodoId: 'nodo-b',
      nodoNombre: 'Nodo B',
      estado: BatchStatus.completado,
      etapaActual: DryingStage.completado,
      pesoKg: 35000,
      humedadInicial: 25.8,
      humedadFinal: 14.1,
      fechaIngreso: _now.subtract(const Duration(days: 4)),
      fechaInicio: _now.subtract(const Duration(days: 3, hours: 22)),
      fechaFin: _now.subtract(const Duration(days: 3, hours: 14)),
      operadorId: 'u2',
      operadorNombre: 'Sofía Vargas',
    ),
    BatchModel(
      id: 'lot5',
      codigo: 'LOT-2025-005',
      siloId: 's2',
      siloNombre: 'Silo 2',
      variedadId: 'v3',
      variedadNombre: 'Capirona',
      perfilSecadoId: 'p2',
      perfilSecadoNombre: 'Secado Rápido Capirona',
      nodoId: 'nodo-c',
      nodoNombre: 'Nodo C',
      estado: BatchStatus.cancelado,
      etapaActual: DryingStage.detenido,
      pesoKg: 18000,
      humedadInicial: 27.0,
      fechaIngreso: _now.subtract(const Duration(days: 6)),
      fechaInicio: _now.subtract(const Duration(days: 6)),
      fechaFin: _now.subtract(const Duration(days: 5, hours: 20)),
      operadorId: 'u1',
      operadorNombre: 'Carlos Mendoza',
    ),
  ];

  static final List<AlertModel> alertas = [
    AlertModel(
      id: 'a1',
      nodoId: 'nodo-c',
      nodoNombre: 'Nodo C',
      mensaje: 'Temperatura crítica: 61.3°C supera el límite de 60°C',
      severidad: AlertSeverity.critica,
      timestamp: _now.subtract(const Duration(minutes: 5)),
      leida: false,
    ),
    AlertModel(
      id: 'a2',
      nodoId: 'nodo-c',
      nodoNombre: 'Nodo C',
      mensaje: 'Flujo de aire al 95% — verificar ventilación',
      severidad: AlertSeverity.advertencia,
      timestamp: _now.subtract(const Duration(minutes: 8)),
      leida: false,
    ),
    AlertModel(
      id: 'a3',
      nodoId: 'nodo-a',
      nodoNombre: 'Nodo A',
      mensaje: 'Humedad de grano en 14.5%, cerca del objetivo (14%)',
      severidad: AlertSeverity.informacion,
      timestamp: _now.subtract(const Duration(hours: 1)),
      leida: true,
    ),
    AlertModel(
      id: 'a4',
      nodoId: 'nodo-b',
      nodoNombre: 'Nodo B',
      mensaje: 'Lote LOT-2025-002 en fase de enfriamiento',
      severidad: AlertSeverity.informacion,
      timestamp: _now.subtract(const Duration(hours: 2)),
      leida: true,
    ),
    AlertModel(
      id: 'a5',
      nodoId: 'nodo-d',
      nodoNombre: 'Nodo D',
      mensaje: 'Nodo D sin conexión hace más de 3 horas',
      severidad: AlertSeverity.advertencia,
      timestamp: _now.subtract(const Duration(hours: 3, minutes: 5)),
      leida: false,
    ),
    AlertModel(
      id: 'a6',
      nodoId: 'nodo-c',
      nodoNombre: 'Nodo C',
      mensaje: 'Temperatura superó umbral crítico — revisión urgente',
      severidad: AlertSeverity.critica,
      timestamp: _now.subtract(const Duration(hours: 5)),
      leida: true,
    ),
  ];

  static List<SensorReadingModel> generarLecturas(
    String nodoId, {
    required DateTime desde,
    required DateTime hasta,
  }) {
    final result = <SensorReadingModel>[];
    final seed = nodoId.codeUnits.reduce((a, b) => a + b).toDouble();
    const intervalo = Duration(minutes: 5);
    var current = desde;
    var i = 0;
    while (current.isBefore(hasta)) {
      final t = i.toDouble();
      final temp =
          (50.0 + 5.0 * sin(t * 0.3 + seed * 0.01) + 2.0 * sin(t * 1.7)).clamp(35.0, 65.0);
      final humedad =
          (40.0 - t * 0.3 + 5.0 * sin(t * 0.5 + seed * 0.02)).clamp(12.0, 80.0);
      final flujo =
          (80.0 + 8.0 * sin(t * 0.2 + seed * 0.015)).clamp(0.0, 100.0);
      final hg =
          (22.0 - t * 0.15 + sin(t * 0.8) * 0.5).clamp(10.0, 25.0);
      result.add(SensorReadingModel(
        timestamp: current,
        temperatura: temp,
        humedad: humedad,
        flujoAire: flujo,
        humedadGrano: hg,
      ));
      current = current.add(intervalo);
      i++;
    }
    return result;
  }

  static DashboardSummaryModel get resumenDashboard {
    final activos = nodos.where((n) => n.estado == NodeStatus.activo).length;
    final enProceso = lotes.where((l) => l.estaActivo).length;
    final noLeidas = alertas.where((a) => !a.leida).length;
    final kgHoy = lotes
        .where((l) => l.estaActivo)
        .fold<double>(0, (sum, l) => sum + l.pesoKg);
    final tempProm = nodos
            .where((n) => n.estado == NodeStatus.activo)
            .fold<double>(0, (sum, n) => sum + n.temperatura) /
        (activos == 0 ? 1 : activos);
    final hgProm = nodos
            .where((n) => n.estado == NodeStatus.activo)
            .fold<double>(0, (sum, n) => sum + n.humedadGrano) /
        (activos == 0 ? 1 : activos);
    final silosDisp = silos.where((s) => s.estado == SiloStatus.disponible).length;

    return DashboardSummaryModel(
      nodosActivos: activos,
      totalNodos: nodos.length,
      lotesEnProceso: enProceso,
      alertasNoLeidas: noLeidas,
      totalKgProcesadosHoy: kgHoy,
      humedadGranoPromedio: hgProm,
      temperaturaPromedio: tempProm,
      silosDisponibles: silosDisp,
    );
  }

  static KpiModel get kpisMes {
    final completados = lotes.where((l) => l.estado == BatchStatus.completado).toList();
    final cancelados = lotes.where((l) => l.estado == BatchStatus.cancelado).length;
    final totalKg = completados.fold<double>(0, (s, l) => s + l.pesoKg);
    final tasaExito = lotes.isEmpty
        ? 0.0
        : completados.length / lotes.length * 100;
    final humedadFinalProm = completados
        .where((l) => l.humedadFinal != null)
        .fold<double>(0, (s, l) => s + l.humedadFinal!) /
        (completados.isEmpty ? 1 : completados.length);

    return KpiModel(
      eficienciaEnergetica: 87.3,
      totalKgProcesados: totalKg,
      tiempoPromedioHoras: 8.4,
      tasaExitoPercent: tasaExito,
      totalLotesCompletados: completados.length,
      totalLotesCancelados: cancelados,
      humedadPromedioFinal: humedadFinalProm,
      reduccionHumedadPromedio: 10.2,
      periodoDesde: DateTime.now().subtract(const Duration(days: 30)),
      periodoHasta: DateTime.now(),
    );
  }

  static final Map<String, ThresholdModel> umbrales = {
    'nodo-a': const ThresholdModel(
      nodoId: 'nodo-a',
      temperaturaMin: 35.0,
      temperaturaMax: 58.0,
      humedadMin: 15.0,
      humedadMax: 75.0,
      flujoAireMin: 20.0,
      flujoAireMax: 95.0,
      humedadGranoMin: 11.0,
      humedadGranoMax: 25.0,
    ),
    'nodo-b': const ThresholdModel(
      nodoId: 'nodo-b',
      temperaturaMin: 35.0,
      temperaturaMax: 58.0,
      humedadMin: 15.0,
      humedadMax: 75.0,
      flujoAireMin: 20.0,
      flujoAireMax: 95.0,
      humedadGranoMin: 11.0,
      humedadGranoMax: 25.0,
    ),
    'nodo-c': const ThresholdModel(
      nodoId: 'nodo-c',
      temperaturaMin: 35.0,
      temperaturaMax: 60.0,
      humedadMin: 15.0,
      humedadMax: 75.0,
      flujoAireMin: 20.0,
      flujoAireMax: 95.0,
      humedadGranoMin: 11.0,
      humedadGranoMax: 25.0,
    ),
    'nodo-d': const ThresholdModel(
      nodoId: 'nodo-d',
      temperaturaMin: 35.0,
      temperaturaMax: 58.0,
      humedadMin: 15.0,
      humedadMax: 75.0,
      flujoAireMin: 20.0,
      flujoAireMax: 95.0,
      humedadGranoMin: 11.0,
      humedadGranoMax: 25.0,
    ),
  };

  static final Map<String, Esp32ConfigModel> configuraciones = {
    'nodo-a': const Esp32ConfigModel(
      nodoId: 'nodo-a',
      ipAddress: '192.168.1.101',
      puerto: 1883,
      intervaloEnvioSegundos: 10,
      offsetTemperatura: 0.0,
      offsetHumedad: 0.0,
      offsetFlujoAire: 0.0,
      offsetHumedadGrano: 0.0,
      wifiActivo: true,
      ssid: 'OryzaFlow_AP',
    ),
    'nodo-b': const Esp32ConfigModel(
      nodoId: 'nodo-b',
      ipAddress: '192.168.1.102',
      puerto: 1883,
      intervaloEnvioSegundos: 10,
      offsetTemperatura: 0.3,
      offsetHumedad: -0.5,
      offsetFlujoAire: 0.0,
      offsetHumedadGrano: 0.1,
      wifiActivo: true,
      ssid: 'OryzaFlow_AP',
    ),
    'nodo-c': const Esp32ConfigModel(
      nodoId: 'nodo-c',
      ipAddress: '192.168.1.103',
      puerto: 1883,
      intervaloEnvioSegundos: 5,
      offsetTemperatura: 0.0,
      offsetHumedad: 0.0,
      offsetFlujoAire: 0.0,
      offsetHumedadGrano: 0.0,
      wifiActivo: true,
      ssid: 'OryzaFlow_AP',
    ),
    'nodo-d': const Esp32ConfigModel(
      nodoId: 'nodo-d',
      ipAddress: '192.168.1.104',
      puerto: 1883,
      intervaloEnvioSegundos: 30,
      offsetTemperatura: 0.0,
      offsetHumedad: 0.0,
      offsetFlujoAire: 0.0,
      offsetHumedadGrano: 0.0,
      wifiActivo: false,
      ssid: 'OryzaFlow_AP',
    ),
  };
}
