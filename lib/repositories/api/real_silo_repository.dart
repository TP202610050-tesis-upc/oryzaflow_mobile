import '../../core/network/api_client.dart';
import '../../models/silo_model.dart';
import '../i_silo_repository.dart';

/// Silos reales (master data, kg + 4 estados).
class RealSiloRepository implements ISiloRepository {
  final ApiClient _api;

  RealSiloRepository(this._api);

  @override
  Future<List<SiloModel>> obtenerSilos() async {
    final res = await _api.dio.get('/silos');
    return (res.data as List<dynamic>)
        .map((e) => SiloModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<SiloModel> obtenerSiloPorId(String id) async {
    final res = await _api.dio.get('/silos/$id');
    return SiloModel.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<SiloModel> crearSilo(SiloModel silo) async {
    final res = await _api.dio.post('/silos', data: silo.toCreateJson());
    return SiloModel.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<SiloModel> actualizarSilo(SiloModel silo) async {
    final res = await _api.dio.put('/silos/${silo.id}', data: silo.toUpdateJson());
    return SiloModel.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> eliminarSilo(String id) async {
    await _api.dio.delete('/silos/$id');
  }

  /// No hay endpoint de disponibilidad por día → réplica del mock: cada día del rango
  /// mapea al estado actual de todos los silos.
  @override
  Future<Map<DateTime, List<SiloModel>>> obtenerDisponibilidad({
    required DateTime desde,
    required DateTime hasta,
  }) async {
    final silos = await obtenerSilos();
    final mapa = <DateTime, List<SiloModel>>{};
    var dia = DateTime(desde.year, desde.month, desde.day);
    final fin = DateTime(hasta.year, hasta.month, hasta.day);
    while (!dia.isAfter(fin)) {
      mapa[dia] = silos;
      dia = dia.add(const Duration(days: 1));
    }
    return mapa;
  }
}
