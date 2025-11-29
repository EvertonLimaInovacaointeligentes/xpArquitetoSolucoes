import 'domain/entities/product_entity_test.dart' as product_entity;
import 'domain/usecases/create_product_usecase_test.dart' as create_usecase;
import 'data/repositories/product_repository_impl_test.dart' as repository;
import 'presentation/controllers/product_controller_test.dart' as controller;

void main() {
  product_entity.main();
  create_usecase.main();
  repository.main();
  controller.main();
}
