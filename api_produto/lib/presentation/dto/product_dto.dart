import '../../domain/entities/product_entity.dart';

/// DTO - Data Transfer Object
/// Usado para transferir dados entre camadas
class ProductDto {
  final String id;
  final String name;
  final double price;
  final int quantity;

  ProductDto({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'quantity': quantity,
      };

  factory ProductDto.fromJson(Map<String, dynamic> json) => ProductDto(
        id: json['id'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        quantity: json['quantity'] as int,
      );

  factory ProductDto.fromEntity(ProductEntity entity) => ProductDto(
        id: entity.id,
        name: entity.name,
        price: entity.price,
        quantity: entity.quantity,
      );

  ProductEntity toEntity() => ProductEntity(
        id: id,
        name: name,
        price: price,
        quantity: quantity,
      );
}
