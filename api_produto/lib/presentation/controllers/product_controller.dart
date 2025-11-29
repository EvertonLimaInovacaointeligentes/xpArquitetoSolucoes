import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/create_product_usecase.dart';
import '../../domain/usecases/delete_product_usecase.dart';
import '../../domain/usecases/get_all_products_usecase.dart';
import '../../domain/usecases/get_product_by_id_usecase.dart';
import '../../domain/usecases/update_product_usecase.dart';

/// Controller - Camada de apresentação
/// Orquestra os use cases
class ProductController {
  final GetAllProductsUseCase getAllProductsUseCase;
  final GetProductByIdUseCase getProductByIdUseCase;
  final CreateProductUseCase createProductUseCase;
  final UpdateProductUseCase updateProductUseCase;
  final DeleteProductUseCase deleteProductUseCase;

  ProductController({
    required this.getAllProductsUseCase,
    required this.getProductByIdUseCase,
    required this.createProductUseCase,
    required this.updateProductUseCase,
    required this.deleteProductUseCase,
  });

  Future<List<ProductEntity>> getAllProducts() async {
    return await getAllProductsUseCase.execute();
  }

  Future<ProductEntity?> getProductById(String id) async {
    return await getProductByIdUseCase.execute(id);
  }

  Future<ProductEntity> createProduct({
    required String name,
    required double price,
    required int quantity,
  }) async {
    return await createProductUseCase.execute(
      name: name,
      price: price,
      quantity: quantity,
    );
  }

  Future<ProductEntity?> updateProduct({
    required String id,
    required String name,
    required double price,
    required int quantity,
  }) async {
    return await updateProductUseCase.execute(
      id: id,
      name: name,
      price: price,
      quantity: quantity,
    );
  }

  Future<bool> deleteProduct(String id) async {
    return await deleteProductUseCase.execute(id);
  }
}
