import 'package:flutter/material.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/enums/node_status.dart';
import '../../core/utils/sensor_utils.dart';

class StatusIndicator extends StatelessWidget {
  final NodeStatus estado;
  final bool mostrarEtiqueta;

  const StatusIndicator({
    super.key,
    required this.estado,
    this.mostrarEtiqueta = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = SensorUtils.colorNodeStatus(estado);
    final dot = Container(
      width: AppDimensions.statusDotSize,
      height: AppDimensions.statusDotSize,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );

    if (!mostrarEtiqueta) return dot;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        dot,
        const SizedBox(width: 6),
        Text(
          estado.displayName,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color),
        ),
      ],
    );
  }
}
