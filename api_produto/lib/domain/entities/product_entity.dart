/// Entidade de domínio - Produto
/// Representa a regra de negócio pura, sem dependências externas
class ProductEntity {
  final String id;
  final String name;
  final double price;
  final int quantity;

  ProductEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });

  /// Valida se o produto tem dados válidos
  bool isValid() {
    return name.isNotEmpty && price > 0 && quantity >= 0;
  }

  /// Calcula o valor total em estoque
  double get totalValue => price * quantity;

  /// Verifica se o produto está em estoque
  bool get inStock => quantity > 0;

  /// Cria uma cópia com campos atualizados
  ProductEntity copyWith({
    String? id,
    String? name,
    double? price,
    int? quantity,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }
}
