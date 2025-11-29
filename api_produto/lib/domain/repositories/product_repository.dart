import '../entities/product_entity.dart';

/// Interface do repositório - Define o contrato para acesso aos dados
/// Camada de domínio não conhece implementação
abstract class ProductRepository {
  Future<List<ProductEntity>> getAll();
  Future<ProductEntity?> getById(String id);
  Future<ProductEntity> create(ProductEntity product);
  Future<ProductEntity?> update(String id, ProductEntity product);
  Future<bool> delete(String id);
}
