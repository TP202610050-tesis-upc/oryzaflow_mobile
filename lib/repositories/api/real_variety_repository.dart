import '../../core/network/api_client.dart';
import '../../models/variety_model.dart';
import '../i_variety_repository.dart';

/// Variedades reales (master data).
class RealVarietyRepository implements IVarietyRepository {
  final ApiClient _api;

  RealVarietyRepository(this._api);

  @override
  Future<List<VarietyModel>> obtenerVariedades() async {
    final res = await _api.dio.get('/varieties');
    return (res.data as List<dynamic>)
        .map((e) => VarietyModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<VarietyModel> obtenerVariedadPorId(String id) async {
    final res = await _api.dio.get('/varieties/$id');
    return VarietyModel.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<VarietyModel> crearVariedad(VarietyModel variedad) async {
    final res = await _api.dio.post('/varieties', data: variedad.toJson());
    return VarietyModel.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<VarietyModel> actualizarVariedad(VarietyModel variedad) async {
    final res = await _api.dio.put('/varieties/${variedad.id}', data: variedad.toJson());
    return VarietyModel.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> eliminarVariedad(String id) async {
    await _api.dio.delete('/varieties/$id');
  }
}
