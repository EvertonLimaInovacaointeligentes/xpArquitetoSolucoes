import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

/// Use Case - Listar Todos os Produtos
class GetAllProductsUseCase {
  final ProductRepository repository;

  GetAllProductsUseCase(this.repository);

  Future<List<ProductEntity>> execute() async {
    return await repository.getAll();
  }
}
