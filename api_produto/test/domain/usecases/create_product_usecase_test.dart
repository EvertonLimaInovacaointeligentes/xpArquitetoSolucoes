import 'package:test/test.dart';
import '../../../lib/domain/entities/product_entity.dart';
import '../../../lib/domain/repositories/product_repository.dart';
import '../../../lib/domain/usecases/create_product_usecase.dart';

class MockProductRepository implements ProductRepository {
  @override
  Future<ProductEntity> create(ProductEntity product) async {
    return ProductEntity(
      id: '1',
      name: product.name,
      price: product.price,
      quantity: product.quantity,
    );
  }

  @override
  Future<bool> delete(String id) async => true;

  @override
  Future<List<ProductEntity>> getAll() async => [];

  @override
  Future<ProductEntity?> getById(String id) async => null;

  @override
  Future<ProductEntity?> update(String id, ProductEntity product) async => null;
}

void main() {
  group('CreateProductUseCase', () {
    late CreateProductUseCase useCase;
    late ProductRepository repository;

    setUp(() {
      repository = MockProductRepository();
      useCase = CreateProductUseCase(repository);
    });

    test('deve criar produto com dados válidos', () async {
      final product = await useCase.execute(
        name: 'Notebook',
        price: 2500.00,
        quantity: 10,
      );

      expect(product.name, equals('Notebook'));
      expect(product.price, equals(2500.00));
      expect(product.quantity, equals(10));
    });

    test('deve lançar exceção com nome vazio', () async {
      expect(
        () => useCase.execute(name: '', price: 100.00, quantity: 5),
        throwsException,
      );
    });

    test('deve lançar exceção com preço zero ou negativo', () async {
      expect(
        () => useCase.execute(name: 'Produto', price: 0, quantity: 5),
        throwsException,
      );

      expect(
        () => useCase.execute(name: 'Produto', price: -10, quantity: 5),
        throwsException,
      );
    });

    test('deve lançar exceção com quantidade negativa', () async {
      expect(
        () => useCase.execute(name: 'Produto', price: 100.00, quantity: -1),
        throwsException,
      );
    });

    test('deve remover espaços do nome', () async {
      final product = await useCase.execute(
        name: '  Produto com espaços  ',
        price: 100.00,
        quantity: 5,
      );

      expect(product.name, equals('Produto com espaços'));
    });
  });
}
