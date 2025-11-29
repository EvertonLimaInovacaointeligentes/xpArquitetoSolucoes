import 'package:test/test.dart';
import '../../../lib/data/datasources/product_memory_datasource.dart';
import '../../../lib/data/repositories/product_repository_impl.dart';
import '../../../lib/domain/entities/product_entity.dart';

void main() {
  group('ProductRepositoryImpl', () {
    late ProductRepositoryImpl repository;

    setUp(() {
      final dataSource = ProductMemoryDataSource();
      repository = ProductRepositoryImpl(dataSource);
    });

    test('deve criar produto', () async {
      final entity = ProductEntity(
        id: '',
        name: 'Notebook',
        price: 2500.00,
        quantity: 10,
      );

      final created = await repository.create(entity);

      expect(created.id, isNotEmpty);
      expect(created.name, equals('Notebook'));
      expect(created.price, equals(2500.00));
      expect(created.quantity, equals(10));
    });

    test('deve listar todos os produtos', () async {
      await repository.create(ProductEntity(
        id: '',
        name: 'Produto 1',
        price: 100.00,
        quantity: 5,
      ));

      await repository.create(ProductEntity(
        id: '',
        name: 'Produto 2',
        price: 200.00,
        quantity: 10,
      ));

      final products = await repository.getAll();

      expect(products.length, equals(2));
    });

    test('deve buscar produto por ID', () async {
      final created = await repository.create(ProductEntity(
        id: '',
        name: 'Mouse',
        price: 50.00,
        quantity: 20,
      ));

      final found = await repository.getById(created.id);

      expect(found, isNotNull);
      expect(found!.name, equals('Mouse'));
    });

    test('deve atualizar produto', () async {
      final created = await repository.create(ProductEntity(
        id: '',
        name: 'Original',
        price: 100.00,
        quantity: 5,
      ));

      final updated = await repository.update(
        created.id,
        ProductEntity(
          id: created.id,
          name: 'Atualizado',
          price: 200.00,
          quantity: 10,
        ),
      );

      expect(updated, isNotNull);
      expect(updated!.name, equals('Atualizado'));
      expect(updated.price, equals(200.00));
    });

    test('deve deletar produto', () async {
      final created = await repository.create(ProductEntity(
        id: '',
        name: 'Para Deletar',
        price: 50.00,
        quantity: 3,
      ));

      final deleted = await repository.delete(created.id);

      expect(deleted, isTrue);

      final found = await repository.getById(created.id);
      expect(found, isNull);
    });
  });
}
