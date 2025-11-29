import 'package:test/test.dart';
import '../../../lib/domain/entities/product_entity.dart';

void main() {
  group('ProductEntity', () {
    test('deve criar uma entidade válida', () {
      final product = ProductEntity(
        id: '1',
        name: 'Notebook',
        price: 2500.00,
        quantity: 10,
      );

      expect(product.id, equals('1'));
      expect(product.name, equals('Notebook'));
      expect(product.price, equals(2500.00));
      expect(product.quantity, equals(10));
    });

    test('deve validar produto válido', () {
      final product = ProductEntity(
        id: '1',
        name: 'Mouse',
        price: 50.00,
        quantity: 20,
      );

      expect(product.isValid(), isTrue);
    });

    test('deve invalidar produto com nome vazio', () {
      final product = ProductEntity(
        id: '1',
        name: '',
        price: 50.00,
        quantity: 20,
      );

      expect(product.isValid(), isFalse);
    });

    test('deve invalidar produto com preço zero ou negativo', () {
      final product = ProductEntity(
        id: '1',
        name: 'Produto',
        price: 0,
        quantity: 10,
      );

      expect(product.isValid(), isFalse);
    });

    test('deve calcular valor total em estoque', () {
      final product = ProductEntity(
        id: '1',
        name: 'Teclado',
        price: 150.00,
        quantity: 5,
      );

      expect(product.totalValue, equals(750.00));
    });

    test('deve verificar se está em estoque', () {
      final inStock = ProductEntity(
        id: '1',
        name: 'Produto 1',
        price: 100.00,
        quantity: 5,
      );

      final outOfStock = ProductEntity(
        id: '2',
        name: 'Produto 2',
        price: 100.00,
        quantity: 0,
      );

      expect(inStock.inStock, isTrue);
      expect(outOfStock.inStock, isFalse);
    });

    test('deve criar cópia com campos atualizados', () {
      final original = ProductEntity(
        id: '1',
        name: 'Original',
        price: 100.00,
        quantity: 5,
      );

      final copy = original.copyWith(
        name: 'Atualizado',
        price: 200.00,
      );

      expect(copy.id, equals('1'));
      expect(copy.name, equals('Atualizado'));
      expect(copy.price, equals(200.00));
      expect(copy.quantity, equals(5));
    });
  });
}
