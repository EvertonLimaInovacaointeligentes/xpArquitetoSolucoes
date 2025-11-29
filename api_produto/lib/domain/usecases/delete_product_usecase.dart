import '../repositories/product_repository.dart';

/// Use Case - Deletar Produto
class DeleteProductUseCase {
  final ProductRepository repository;

  DeleteProductUseCase(this.repository);

  Future<bool> execute(String id) async {
    if (id.trim().isEmpty) {
      throw Exception('ID não pode ser vazio');
    }

    return await repository.delete(id);
  }
}
