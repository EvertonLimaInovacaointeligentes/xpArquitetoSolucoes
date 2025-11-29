# Exemplos Práticos - Clean Architecture

## 🎯 Cenários Comuns

### 1. Adicionar Nova Validação de Negócio

**Requisito:** Produtos com preço acima de R$ 10.000 precisam de aprovação.

**Solução:**

```dart
// 1. Adicionar propriedade na entidade (domain/entities/product_entity.dart)
class ProductEntity {
  // ... campos existentes
  
  bool needsApproval() => price > 10000;
}

// 2. Criar novo use case (domain/usecases/approve_product_usecase.dart)
class ApproveProductUseCase {
  final ProductRepository repository;
  
  ApproveProductUseCase(this.repository);
  
  Future<ProductEntity?> execute(String id) async {
    final product = await repository.getById(id);
    
    if (product == null) {
      throw Exception('Produto não encontrado');
    }
    
    if (!product.needsApproval()) {
      throw Exception('Produto não precisa de aprovação');
    }
    
    // Lógica de aprovação
    return product;
  }
}

// 3. Adicionar no controller (presentation/controllers/product_controller.dart)
class ProductController {
  final ApproveProductUseCase approveProductUseCase;
  
  Future<ProductEntity?> approveProduct(String id) async {
    return await approveProductUseCase.execute(id);
  }
}

// 4. Adicionar endpoint (presentation/handlers/product_handler.dart)
Router get router {
  // ... rotas existentes
  router.post('/products/<id>/approve', _approve);
}

Future<Response> _approve(Request request, String id) async {
  try {
    final product = await controller.approveProduct(id);
    final dto = ProductDto.fromEntity(product!);
    return Response.ok(jsonEncode(dto.toJson()));
  } catch (e) {
    return Response.badRequest(body: jsonEncode({'error': e.toString()}));
  }
}
```

### 2. Trocar Armazenamento (Memória → Banco de Dados)

**Requisito:** Persistir produtos em PostgreSQL.

**Solução:**

```dart
// 1. Adicionar dependência no pubspec.yaml
dependencies:
  postgres: ^2.6.0

// 2. Criar novo datasource (data/datasources/product_database_datasource.dart)
import 'package:postgres/postgres.dart';

class ProductDatabaseDataSource implements ProductDataSource {
  final PostgreSQLConnection connection;
  
  ProductDatabaseDataSource(this.connection);
  
  @override
  Future<List<ProductModel>> getAll() async {
    final results = await connection.query('SELECT * FROM products');
    return results.map((row) => ProductModel(
      id: row[0].toString(),
      name: row[1] as String,
      price: row[2] as double,
      quantity: row[3] as int,
    )).toList();
  }
  
  @override
  Future<ProductModel> create(ProductModel product) async {
    final result = await connection.query(
      'INSERT INTO products (name, price, quantity) VALUES (@name, @price, @quantity) RETURNING id',
      substitutionValues: {
        'name': product.name,
        'price': product.price,
        'quantity': product.quantity,
      },
    );
    
    return ProductModel(
      id: result.first[0].toString(),
      name: product.name,
      price: product.price,
      quantity: product.quantity,
    );
  }
  
  // ... outros métodos
}

// 3. Atualizar DI (infrastructure/di/dependency_injection.dart)
class DependencyInjection {
  static Future<ProductHandler> createProductHandler() async {
    // Conectar ao banco
    final connection = PostgreSQLConnection(
      'localhost', 5432, 'products_db',
      username: 'user', password: 'pass',
    );
    await connection.open();
    
    // Usar novo datasource
    final ProductDataSource dataSource = ProductDatabaseDataSource(connection);
    
    // Resto permanece igual!
    final repository = ProductRepositoryImpl(dataSource);
    // ...
  }
}
```

**Nenhuma mudança necessária em:**
- ✅ Domain (entities, use cases, repository interface)
- ✅ Presentation (controllers, handlers, DTOs)

### 3. Adicionar Cache

**Requisito:** Cachear produtos para melhorar performance.

**Solução:**

```dart
// 1. Criar datasource com cache (data/datasources/product_cached_datasource.dart)
class ProductCachedDataSource implements ProductDataSource {
  final ProductDataSource remoteDataSource;
  final Map<String, ProductModel> _cache = {};
  
  ProductCachedDataSource(this.remoteDataSource);
  
  @override
  ProductModel? getById(String id) {
    // Verificar cache
    if (_cache.containsKey(id)) {
      print('Cache hit: $id');
      return _cache[id];
    }
    
    // Buscar no datasource remoto
    print('Cache miss: $id');
    final product = remoteDataSource.getById(id);
    
    // Armazenar no cache
    if (product != null) {
      _cache[id] = product;
    }
    
    return product;
  }
  
  @override
  ProductModel create(ProductModel product) {
    final created = remoteDataSource.create(product);
    _cache[created.id] = created; // Adicionar ao cache
    return created;
  }
  
  @override
  bool delete(String id) {
    final deleted = remoteDataSource.delete(id);
    if (deleted) {
      _cache.remove(id); // Remover do cache
    }
    return deleted;
  }
  
  // ... outros métodos
}

// 2. Atualizar DI
final baseDataSource = ProductMemoryDataSource();
final cachedDataSource = ProductCachedDataSource(baseDataSource);
final repository = ProductRepositoryImpl(cachedDataSource);
```

### 4. Adicionar Logging

**Requisito:** Registrar todas as operações de produtos.

**Solução:**

```dart
// 1. Criar datasource com logging (data/datasources/product_logging_datasource.dart)
class ProductLoggingDataSource implements ProductDataSource {
  final ProductDataSource dataSource;
  
  ProductLoggingDataSource(this.dataSource);
  
  @override
  ProductModel create(ProductModel product) {
    print('[LOG] Criando produto: ${product.name}');
    final created = dataSource.create(product);
    print('[LOG] Produto criado com ID: ${created.id}');
    return created;
  }
  
  @override
  bool delete(String id) {
    print('[LOG] Deletando produto: $id');
    final deleted = dataSource.delete(id);
    print('[LOG] Produto deletado: $deleted');
    return deleted;
  }
  
  // ... outros métodos com logging
}

// 2. Atualizar DI (pode combinar com cache!)
final baseDataSource = ProductMemoryDataSource();
final loggedDataSource = ProductLoggingDataSource(baseDataSource);
final cachedDataSource = ProductCachedDataSource(loggedDataSource);
final repository = ProductRepositoryImpl(cachedDataSource);
```

### 5. Adicionar Busca por Nome

**Requisito:** Buscar produtos por nome.

**Solução:**

```dart
// 1. Adicionar método na interface do repositório (domain/repositories/product_repository.dart)
abstract class ProductRepository {
  // ... métodos existentes
  Future<List<ProductEntity>> searchByName(String query);
}

// 2. Criar use case (domain/usecases/search_products_by_name_usecase.dart)
class SearchProductsByNameUseCase {
  final ProductRepository repository;
  
  SearchProductsByNameUseCase(this.repository);
  
  Future<List<ProductEntity>> execute(String query) async {
    if (query.trim().isEmpty) {
      throw Exception('Query não pode ser vazia');
    }
    
    return await repository.searchByName(query.trim().toLowerCase());
  }
}

// 3. Implementar no datasource (data/datasources/product_memory_datasource.dart)
class ProductMemoryDataSource implements ProductDataSource {
  // ... métodos existentes
  
  @override
  List<ProductModel> searchByName(String query) {
    return _products
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}

// 4. Implementar no repositório (data/repositories/product_repository_impl.dart)
class ProductRepositoryImpl implements ProductRepository {
  // ... métodos existentes
  
  @override
  Future<List<ProductEntity>> searchByName(String query) async {
    final models = dataSource.searchByName(query);
    return models.map((m) => m.toEntity()).toList();
  }
}

// 5. Adicionar no controller
class ProductController {
  final SearchProductsByNameUseCase searchProductsByNameUseCase;
  
  Future<List<ProductEntity>> searchProducts(String query) async {
    return await searchProductsByNameUseCase.execute(query);
  }
}

// 6. Adicionar endpoint
router.get('/products/search', _search);

Future<Response> _search(Request request) async {
  final query = request.url.queryParameters['q'] ?? '';
  
  try {
    final products = await controller.searchProducts(query);
    final dtos = products.map((p) => ProductDto.fromEntity(p).toJson()).toList();
    return Response.ok(jsonEncode(dtos));
  } catch (e) {
    return Response.badRequest(body: jsonEncode({'error': e.toString()}));
  }
}
```

### 6. Adicionar Paginação

**Requisito:** Listar produtos com paginação.

**Solução:**

```dart
// 1. Criar entidade de paginação (domain/entities/paginated_result.dart)
class PaginatedResult<T> {
  final List<T> items;
  final int page;
  final int pageSize;
  final int totalItems;
  
  PaginatedResult({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalItems,
  });
  
  int get totalPages => (totalItems / pageSize).ceil();
  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;
}

// 2. Atualizar repositório
abstract class ProductRepository {
  Future<PaginatedResult<ProductEntity>> getAllPaginated(int page, int pageSize);
}

// 3. Criar use case
class GetProductsPaginatedUseCase {
  final ProductRepository repository;
  
  GetProductsPaginatedUseCase(this.repository);
  
  Future<PaginatedResult<ProductEntity>> execute(int page, int pageSize) async {
    if (page < 1) throw Exception('Página deve ser >= 1');
    if (pageSize < 1 || pageSize > 100) {
      throw Exception('Page size deve estar entre 1 e 100');
    }
    
    return await repository.getAllPaginated(page, pageSize);
  }
}

// 4. Implementar no datasource
class ProductMemoryDataSource implements ProductDataSource {
  List<ProductModel> getAllPaginated(int page, int pageSize) {
    final skip = (page - 1) * pageSize;
    return _products.skip(skip).take(pageSize).toList();
  }
  
  int getTotalCount() => _products.length;
}

// 5. Adicionar endpoint
router.get('/products', _getAllPaginated);

Future<Response> _getAllPaginated(Request request) async {
  final page = int.tryParse(request.url.queryParameters['page'] ?? '1') ?? 1;
  final pageSize = int.tryParse(request.url.queryParameters['pageSize'] ?? '10') ?? 10;
  
  try {
    final result = await controller.getProductsPaginated(page, pageSize);
    
    return Response.ok(jsonEncode({
      'items': result.items.map((p) => ProductDto.fromEntity(p).toJson()).toList(),
      'page': result.page,
      'pageSize': result.pageSize,
      'totalItems': result.totalItems,
      'totalPages': result.totalPages,
      'hasNextPage': result.hasNextPage,
      'hasPreviousPage': result.hasPreviousPage,
    }));
  } catch (e) {
    return Response.badRequest(body: jsonEncode({'error': e.toString()}));
  }
}
```

## 🧪 Testando Novos Recursos

### Teste de Use Case com Mock

```dart
import 'package:test/test.dart';

class MockProductRepository implements ProductRepository {
  @override
  Future<List<ProductEntity>> searchByName(String query) async {
    return [
      ProductEntity(id: '1', name: 'Mouse Gamer', price: 150, quantity: 10),
      ProductEntity(id: '2', name: 'Mouse Pad', price: 30, quantity: 20),
    ];
  }
  
  // ... outros métodos
}

void main() {
  test('deve buscar produtos por nome', () async {
    final repository = MockProductRepository();
    final useCase = SearchProductsByNameUseCase(repository);
    
    final results = await useCase.execute('mouse');
    
    expect(results.length, equals(2));
    expect(results[0].name, contains('Mouse'));
  });
}
```

## 📊 Padrões de Design Aplicados

### Repository Pattern
- Abstrai acesso aos dados
- Permite trocar implementações

### Use Case Pattern
- Encapsula lógica de negócio
- Um caso de uso por operação

### Dependency Injection
- Inverte dependências
- Facilita testes

### DTO Pattern
- Separa representação de dados
- Controla o que é exposto na API

### Decorator Pattern
- Adiciona funcionalidades (cache, logging)
- Sem modificar código existente

## 🎓 Boas Práticas

1. **Uma responsabilidade por classe**
2. **Use cases focados e pequenos**
3. **Interfaces no domínio, implementações na data**
4. **DTOs para API, Entities para negócio**
5. **Testes para cada camada**
6. **Dependency Injection para conectar tudo**
