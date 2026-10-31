/// Destino comercial del lote (CA-006-02): fija la humedad meta. Backend: ProductoDestino (GENERICO | SACO_MARCA).
enum ProductoDestino { generico, sacoMarca }

extension ProductoDestinoExtension on ProductoDestino {
  String get displayName => switch (this) {
        ProductoDestino.generico => 'Genérico',
        ProductoDestino.sacoMarca => 'Saco de marca',
      };

  String get descripcion => switch (this) {
        ProductoDestino.generico => 'Meta 11–13 % (campaña 2026)',
        ProductoDestino.sacoMarca => 'Meta ~9 % (fuera de la campaña 2026)',
      };
}

ProductoDestino? productoDestinoFromApi(String? s) => switch (s) {
      'GENERICO' => ProductoDestino.generico,
      'SACO_MARCA' => ProductoDestino.sacoMarca,
      _ => null,
    };

String productoDestinoToApi(ProductoDestino p) => switch (p) {
      ProductoDestino.generico => 'GENERICO',
      ProductoDestino.sacoMarca => 'SACO_MARCA',
    };
