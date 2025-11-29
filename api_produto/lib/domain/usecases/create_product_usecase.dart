import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

/// Use Case - Criar Produto
/// Contém a lógica de negócio para criação de produtos
class CreateProductUseCase {
  final ProductRepository repository;

  CreateProductUseCase(this.repository);

  Future<ProductEntity> execute({
    required String name,
    required double price,
    required int quantity,
  }) async {
    // Validações de negócio
    if (name.trim().isEmpty) {
      throw Exception('Nome do produto não pode ser vazio');
    }

    if (price <= 0) {
      throw Exception('Preço deve ser maior que zero');
    }

    if (quantity < 0) {
      throw Exception('Quantidade não pode ser negativa');
    }

    // Criar entidade
    final product = ProductEntity(
      id: '', // ID será gerado pelo repositório
      name: name.trim(),
      price: price,
      quantity: quantity,
    );

    // Persistir
    return await repository.create(product);
  }
}
