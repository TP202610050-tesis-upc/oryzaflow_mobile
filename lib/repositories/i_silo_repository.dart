import '../models/silo_model.dart';

abstract class ISiloRepository {
  Future<List<SiloModel>> obtenerSilos();
  Future<SiloModel> obtenerSiloPorId(String id);
  Future<SiloModel> crearSilo(SiloModel silo);
  Future<SiloModel> actualizarSilo(SiloModel silo);
  Future<void> eliminarSilo(String id);
  Future<Map<DateTime, List<SiloModel>>> obtenerDisponibilidad({
    required DateTime desde,
    required DateTime hasta,
  });
}
