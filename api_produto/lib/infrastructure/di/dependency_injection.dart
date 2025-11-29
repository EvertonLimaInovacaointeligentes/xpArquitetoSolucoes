import '../../data/datasources/product_datasource.dart';
import '../../data/datasources/product_memory_datasource.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/create_product_usecase.dart';
import '../../domain/usecases/delete_product_usecase.dart';
import '../../domain/usecases/get_all_products_usecase.dart';
import '../../domain/usecases/get_product_by_id_usecase.dart';
import '../../domain/usecases/update_product_usecase.dart';
import '../../presentation/controllers/product_controller.dart';
import '../../presentation/handlers/product_handler.dart';

/// Dependency Injection - Injeção de Dependências
/// Configura e fornece todas as dependências da aplicação
class DependencyInjection {
  static ProductHandler createProductHandler() {
    // DataSource
    final ProductDataSource dataSource = ProductMemoryDataSource();

    // Repository
    final ProductRepository repository = ProductRepositoryImpl(dataSource);

    // Use Cases
    final getAllProductsUseCase = GetAllProductsUseCase(repository);
    final getProductByIdUseCase = GetProductByIdUseCase(repository);
    final createProductUseCase = CreateProductUseCase(repository);
    final updateProductUseCase = UpdateProductUseCase(repository);
    final deleteProductUseCase = DeleteProductUseCase(repository);

    // Controller
    final controller = ProductController(
      getAllProductsUseCase: getAllProductsUseCase,
      getProductByIdUseCase: getProductByIdUseCase,
      createProductUseCase: createProductUseCase,
      updateProductUseCase: updateProductUseCase,
      deleteProductUseCase: deleteProductUseCase,
    );

    // Handler
    return ProductHandler(controller);
  }
}
