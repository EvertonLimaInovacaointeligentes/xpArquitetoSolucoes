import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

/// Use Case - Buscar Produto por ID
class GetProductByIdUseCase {
  final ProductRepository repository;

  GetProductByIdUseCase(this.repository);

  Future<ProductEntity?> execute(String id) async {
    if (id.trim().isEmpty) {
      throw Exception('ID não pode ser vazio');
    }

    return await repository.getById(id);
  }
}
