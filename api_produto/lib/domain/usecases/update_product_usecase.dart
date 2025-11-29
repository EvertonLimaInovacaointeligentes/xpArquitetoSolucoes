import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

/// Use Case - Atualizar Produto
class UpdateProductUseCase {
  final ProductRepository repository;

  UpdateProductUseCase(this.repository);

  Future<ProductEntity?> execute({
    required String id,
    required String name,
    required double price,
    required int quantity,
  }) async {
    // Validações
    if (id.trim().isEmpty) {
      throw Exception('ID não pode ser vazio');
    }

    if (name.trim().isEmpty) {
      throw Exception('Nome do produto não pode ser vazio');
    }

    if (price <= 0) {
      throw Exception('Preço deve ser maior que zero');
    }

    if (quantity < 0) {
      throw Exception('Quantidade não pode ser negativa');
    }

    final product = ProductEntity(
      id: id,
      name: name.trim(),
      price: price,
      quantity: quantity,
    );

    return await repository.update(id, product);
  }
}
