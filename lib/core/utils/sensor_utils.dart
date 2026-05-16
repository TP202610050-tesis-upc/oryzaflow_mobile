import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../enums/alert_severity.dart';
import '../enums/batch_status.dart';
import '../enums/node_status.dart';
import '../../models/silo_model.dart';

class SensorUtils {
  SensorUtils._();

  static Color colorTemperatura(double temp) {
    if (temp > 60) return AppColors.critico;
    if (temp > 55) return AppColors.advertencia;
    return AppColors.nodoActivo;
  }

  static Color colorHumedad(double h) {
    if (h > 75 || h < 12) return AppColors.critico;
    if (h > 65) return AppColors.advertencia;
    return AppColors.informacion;
  }

  static Color colorHumedadGrano(double hg) {
    if (hg > 20 || hg < 11) return AppColors.critico;
    if (hg > 17) return AppColors.advertencia;
    return AppColors.nodoActivo;
  }

  static Color colorNodeStatus(NodeStatus estado) => switch (estado) {
        NodeStatus.activo => AppColors.nodoActivo,
        NodeStatus.inactivo => AppColors.nodoInactivo,
        NodeStatus.alerta => AppColors.nodoAlerta,
        NodeStatus.desconectado => AppColors.nodoDesconectado,
      };

  static Color colorSiloStatus(SiloStatus estado) => switch (estado) {
        SiloStatus.disponible => AppColors.siloDisponible,
        SiloStatus.ocupado => AppColors.siloOcupado,
        SiloStatus.mantenimiento => AppColors.siloMantenimiento,
      };

  static Color colorBatchStatus(BatchStatus estado) => switch (estado) {
        BatchStatus.enProceso => AppColors.informacion,
        BatchStatus.completado => AppColors.exito,
        BatchStatus.cancelado => AppColors.critico,
        BatchStatus.pendiente => AppColors.textoSecundario,
      };

  static Color colorAlertSeverity(AlertSeverity s) => switch (s) {
        AlertSeverity.critica => AppColors.critico,
        AlertSeverity.advertencia => AppColors.advertencia,
        AlertSeverity.informacion => AppColors.informacion,
      };

  static Color bgAlertSeverity(AlertSeverity s) => switch (s) {
        AlertSeverity.critica => AppColors.criticoFondo,
        AlertSeverity.advertencia => AppColors.advertenciaFondo,
        AlertSeverity.informacion => AppColors.informacionFondo,
      };

  static IconData iconAlertSeverity(AlertSeverity s) => switch (s) {
        AlertSeverity.critica => Icons.error_rounded,
        AlertSeverity.advertencia => Icons.warning_rounded,
        AlertSeverity.informacion => Icons.info_rounded,
      };
}
