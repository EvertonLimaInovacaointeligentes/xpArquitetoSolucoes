import '../models/product_model.dart';
import 'product_datasource.dart';

/// Implementação em memória do DataSource
class ProductMemoryDataSource implements ProductDataSource {
  final List<ProductModel> _products = [];
  int _nextId = 1;

  @override
  List<ProductModel> getAll() => List.unmodifiable(_products);

  @override
  ProductModel? getById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  ProductModel create(ProductModel product) {
    final newProduct = ProductModel(
      id: _nextId.toString(),
      name: product.name,
      price: product.price,
      quantity: product.quantity,
    );
    _nextId++;
    _products.add(newProduct);
    return newProduct;
  }

  @override
  ProductModel? update(String id, ProductModel product) {
    final index = _products.indexWhere((p) => p.id == id);
    if (index == -1) return null;

    final updatedProduct = ProductModel(
      id: id,
      name: product.name,
      price: product.price,
      quantity: product.quantity,
    );

    _products[index] = updatedProduct;
    return updatedProduct;
  }

  @override
  bool delete(String id) {
    final index = _products.indexWhere((p) => p.id == id);
    if (index == -1) return false;

    _products.removeAt(index);
    return true;
  }
}
