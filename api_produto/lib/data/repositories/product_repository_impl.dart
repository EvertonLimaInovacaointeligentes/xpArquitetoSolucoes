import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_datasource.dart';
import '../models/product_model.dart';

/// Implementação do repositório
/// Faz a ponte entre o domínio e a camada de dados
class ProductRepositoryImpl implements ProductRepository {
  final ProductDataSource dataSource;

  ProductRepositoryImpl(this.dataSource);

  @override
  Future<List<ProductEntity>> getAll() async {
    final models = dataSource.getAll();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<ProductEntity?> getById(String id) async {
    final model = dataSource.getById(id);
    return model?.toEntity();
  }

  @override
  Future<ProductEntity> create(ProductEntity product) async {
    final model = ProductModel.fromEntity(product);
    final created = dataSource.create(model);
    return created.toEntity();
  }

  @override
  Future<ProductEntity?> update(String id, ProductEntity product) async {
    final model = ProductModel.fromEntity(product);
    final updated = dataSource.update(id, model);
    return updated?.toEntity();
  }

  @override
  Future<bool> delete(String id) async {
    return dataSource.delete(id);
  }
}
