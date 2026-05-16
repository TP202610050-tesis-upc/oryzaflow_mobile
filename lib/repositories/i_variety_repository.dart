import '../models/variety_model.dart';

abstract class IVarietyRepository {
  Future<List<VarietyModel>> obtenerVariedades();
  Future<VarietyModel> obtenerVariedadPorId(String id);
  Future<VarietyModel> crearVariedad(VarietyModel variedad);
  Future<VarietyModel> actualizarVariedad(VarietyModel variedad);
  Future<void> eliminarVariedad(String id);
}
