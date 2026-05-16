enum NodeStatus { activo, inactivo, alerta, desconectado }

extension NodeStatusExtension on NodeStatus {
  String get displayName => switch (this) {
        NodeStatus.activo => 'Activo',
        NodeStatus.inactivo => 'Inactivo',
        NodeStatus.alerta => 'Alerta',
        NodeStatus.desconectado => 'Desconectado',
      };
}
