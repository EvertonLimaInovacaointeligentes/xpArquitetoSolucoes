import '../models/product_model.dart';

/// Interface do DataSource
abstract class ProductDataSource {
  List<ProductModel> getAll();
  ProductModel? getById(String id);
  ProductModel create(ProductModel product);
  ProductModel? update(String id, ProductModel product);
  bool delete(String id);
}
