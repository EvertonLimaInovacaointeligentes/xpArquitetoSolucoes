import 'package:test/test.dart';
import '../../../lib/data/datasources/product_memory_datasource.dart';
import '../../../lib/data/repositories/product_repository_impl.dart';
import '../../../lib/domain/usecases/create_product_usecase.dart';
import '../../../lib/domain/usecases/delete_product_usecase.dart';
import '../../../lib/domain/usecases/get_all_products_usecase.dart';
import '../../../lib/domain/usecases/get_product_by_id_usecase.dart';
import '../../../lib/domain/usecases/update_product_usecase.dart';
import '../../../lib/presentation/controllers/product_controller.dart';

void main() {
  group('ProductController', () {
    late ProductController controller;

    setUp(() {
      final dataSource = ProductMemoryDataSource();
      final repository = ProductRepositoryImpl(dataSource);

      controller = ProductController(
        getAllProductsUseCase: GetAllProductsUseCase(repository),
        getProductByIdUseCase: GetProductByIdUseCase(repository),
        createProductUseCase: CreateProductUseCase(repository),
        updateProductUseCase: UpdateProductUseCase(repository),
        deleteProductUseCase: DeleteProductUseCase(repository),
      );
    });

    test('deve criar produto', () async {
      final product = await controller.createProduct(
        name: 'Notebook',
        price: 2500.00,
        quantity: 10,
      );

      expect(product.name, equals('Notebook'));
      expect(product.price, equals(2500.00));
      expect(product.quantity, equals(10));
    });

    test('deve listar todos os produtos', () async {
      await controller.createProduct(
        name: 'Produto 1',
        price: 100.00,
        quantity: 5,
      );

      await controller.createProduct(
        name: 'Produto 2',
        price: 200.00,
        quantity: 10,
      );

      final products = await controller.getAllProducts();

      expect(products.length, equals(2));
    });

    test('deve buscar produto por ID', () async {
      final created = await controller.createProduct(
        name: 'Mouse',
        price: 50.00,
        quantity: 20,
      );

      final found = await controller.getProductById(created.id);

      expect(found, isNotNull);
      expect(found!.name, equals('Mouse'));
    });

    test('deve atualizar produto', () async {
      final created = await controller.createProduct(
        name: 'Original',
        price: 100.00,
        quantity: 5,
      );

      final updated = await controller.updateProduct(
        id: created.id,
        name: 'Atualizado',
        price: 200.00,
        quantity: 10,
      );

      expect(updated, isNotNull);
      expect(updated!.name, equals('Atualizado'));
    });

    test('deve deletar produto', () async {
      final created = await controller.createProduct(
        name: 'Para Deletar',
        price: 50.00,
        quantity: 3,
      );

      final deleted = await controller.deleteProduct(created.id);

      expect(deleted, isTrue);
    });
  });
}
