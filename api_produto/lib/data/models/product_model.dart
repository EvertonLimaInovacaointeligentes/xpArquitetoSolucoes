import '../../domain/entities/product_entity.dart';

/// Model - Camada de dados
/// Responsável pela serialização/deserialização
class ProductModel extends ProductEntity {
  ProductModel({
    required super.id,
    required super.name,
    required super.price,
    required super.quantity,
  });

  /// Converte para JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'quantity': quantity,
      };

  /// Cria a partir de JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        quantity: json['quantity'] as int,
      );

  /// Converte de entidade para model
  factory ProductModel.fromEntity(ProductEntity entity) => ProductModel(
        id: entity.id,
        name: entity.name,
        price: entity.price,
        quantity: entity.quantity,
      );

  /// Converte para entidade
  ProductEntity toEntity() => ProductEntity(
        id: id,
        name: name,
        price: price,
        quantity: quantity,
      );
}
