# Guia de Migração - Clean Architecture

## 📦 Estrutura do Projeto

### Antes
```
lib/
├── models/product.dart
├── services/product_service.dart
└── handlers/product_handler.dart
```

### Depois
```
lib/
├── domain/                           # ⭐ Regras de Negócio
│   ├── entities/
│   │   └── product_entity.dart
│   ├── repositories/
│   │   └── product_repository.dart
│   └── usecases/
│       ├── create_product_usecase.dart
│       ├── update_product_usecase.dart
│       ├── delete_product_usecase.dart
│       ├── get_all_products_usecase.dart
│       └── get_product_by_id_usecase.dart
│
├── data/                             # 💾 Acesso aos Dados
│   ├── datasources/
│   │   ├── product_datasource.dart
│   │   └── product_memory_datasource.dart
│   ├── models/
│   │   └── product_model.dart
│   └── repositories/
│       └── product_repository_impl.dart
│
├── presentation/                     # 🌐 Interface/API
│   ├── controllers/
│   │   └── product_controller.dart
│   ├── dto/
│   │   └── product_dto.dart
│   └── handlers/
│       └── product_handler.dart
│
└── infrastructure/                   # ⚙️ Configurações
    └── di/
        └── dependency_injection.dart
```

## 🔄 Mapeamento de Arquivos

| Arquivo Antigo | Novo(s) Arquivo(s) | Camada |
|----------------|-------------------|---------|
| `models/product.dart` | `domain/entities/product_entity.dart` | Domain |
| | `data/models/product_model.dart` | Data |
| | `presentation/dto/product_dto.dart` | Presentation |
| `services/product_service.dart` | `domain/usecases/*.dart` | Domain |
| | `data/datasources/product_memory_datasource.dart` | Data |
| | `data/repositories/product_repository_impl.dart` | Data |
| `handlers/product_handler.dart` | `presentation/handlers/product_handler.dart` | Presentation |
| | `presentation/controllers/product_controller.dart` | Presentation |

## 🎯 Principais Mudanças

### 1. Product → ProductEntity + ProductModel + ProductDto

**Antes:**
```dart
class Product {
  final String id;
  String name;
  double price;
  int quantity;
  
  Map<String, dynamic> toJson() => {...};
  factory Product.fromJson(Map json) => Product(...);
}
```

**Depois:**

**ProductEntity (Domain)** - Lógica de negócio
```dart
class ProductEntity {
  final String id;
  final String name;
  final double price;
  final int quantity;
  
  bool isValid() => name.isNotEmpty && price > 0;
  double get totalValue => price * quantity;
  bool get inStock => quantity > 0;
}
```

**ProductModel (Data)** - Serialização
```dart
class ProductModel extends ProductEntity {
  Map<String, dynamic> toJson() => {...};
  factory ProductModel.fromJson(Map json) => ProductModel(...);
  factory ProductModel.fromEntity(ProductEntity entity) => ProductModel(...);
  ProductEntity toEntity() => ProductEntity(...);
}
```

**ProductDto (Presentation)** - Transferência
```dart
class ProductDto {
  Map<String, dynamic> toJson() => {...};
  factory ProductDto.fromEntity(ProductEntity entity) => ProductDto(...);
}
```

### 2. ProductService → Use Cases + Repository + DataSource

**Antes:**
```dart
class ProductService {
  final List<Product> _products = [];
  
  List<Product> getAll() => _products;
  Product create(String name, double price, int quantity) {...}
  Product? update(String id, ...) {...}
  bool delete(String id) {...}
}
```

**Depois:**

**Use Cases (Domain)** - Lógica de negócio
```dart
class CreateProductUseCase {
  final ProductRepository repository;
  
  Future<ProductEntity> execute({...}) async {
    // Validações de negócio
    if (name.isEmpty) throw Exception('Nome inválido');
    if (price <= 0) throw Exception('Preço inválido');
    
    return await repository.create(product);
  }
}
```

**Repository Interface (Domain)**
```dart
abstract class ProductRepository {
  Future<List<ProductEntity>> getAll();
  Future<ProductEntity> create(ProductEntity product);
  // ...
}
```

**Repository Implementation (Data)**
```dart
class ProductRepositoryImpl implements ProductRepository {
  final ProductDataSource dataSource;
  
  Future<ProductEntity> create(ProductEntity product) async {
    final model = ProductModel.fromEntity(product);
    final created = dataSource.create(model);
    return created.toEntity();
  }
}
```

**DataSource (Data)**
```dart
class ProductMemoryDataSource implements ProductDataSource {
  final List<ProductModel> _products = [];
  
  ProductModel create(ProductModel product) {
    // Lógica de armazenamento
  }
}
```

### 3. ProductHandler → Handler + Controller

**Antes:**
```dart
class ProductHandler {
  final ProductService _service = ProductService();
  
  Response _create(Request request) {
    final product = _service.create(name, price, quantity);
    return Response.ok(jsonEncode(product.toJson()));
  }
}
```

**Depois:**

**Handler (Presentation)** - HTTP
```dart
class ProductHandler {
  final ProductController controller;
  
  Future<Response> _create(Request request) async {
    final product = await controller.createProduct(...);
    final dto = ProductDto.fromEntity(product);
    return Response(201, body: jsonEncode(dto.toJson()));
  }
}
```

**Controller (Presentation)** - Orquestração
```dart
class ProductController {
  final CreateProductUseCase createProductUseCase;
  
  Future<ProductEntity> createProduct({...}) async {
    return await createProductUseCase.execute(...);
  }
}
```

## 🔧 Dependency Injection

**Antes:** Instanciação direta
```dart
final handler = ProductHandler(); // Cria service internamente
```

**Depois:** Injeção de dependências
```dart
// infrastructure/di/dependency_injection.dart
class DependencyInjection {
  static ProductHandler createProductHandler() {
    final dataSource = ProductMemoryDataSource();
    final repository = ProductRepositoryImpl(dataSource);
    final createUseCase = CreateProductUseCase(repository);
    // ... outros use cases
    final controller = ProductController(
      createProductUseCase: createUseCase,
      // ...
    );
    return ProductHandler(controller);
  }
}

// bin/server.dart
final handler = DependencyInjection.createProductHandler();
```

## 🧪 Testes

### Antes
```
test/
├── models/product_test.dart
├── services/product_service_test.dart
└── handlers/product_handler_test.dart
```

### Depois
```
test/
├── domain/
│   ├── entities/product_entity_test.dart
│   └── usecases/create_product_usecase_test.dart
├── data/
│   └── repositories/product_repository_impl_test.dart
└── presentation/
    └── controllers/product_controller_test.dart
```

### Vantagem: Testes Isolados

**Antes:** Difícil testar lógica sem persistência
```dart
test('criar produto', () {
  final service = ProductService(); // Sempre usa lista em memória
  final product = service.create('Test', 100, 5);
  expect(product.name, 'Test');
});
```

**Depois:** Fácil usar mocks
```dart
test('criar produto', () async {
  final mockRepo = MockProductRepository(); // Mock!
  final useCase = CreateProductUseCase(mockRepo);
  
  final product = await useCase.execute(
    name: 'Test',
    price: 100,
    quantity: 5,
  );
  
  expect(product.name, 'Test');
  // Testa APENAS a lógica, sem persistência real
});
```

## 📊 Benefícios da Migração

### ✅ Testabilidade
- Cada camada testada isoladamente
- Fácil usar mocks e stubs
- Testes mais rápidos e confiáveis

### ✅ Manutenibilidade
- Código organizado por responsabilidade
- Fácil encontrar e modificar funcionalidades
- Mudanças localizadas

### ✅ Escalabilidade
- Fácil adicionar novos recursos
- Estrutura preparada para crescimento
- Padrões consistentes

### ✅ Flexibilidade
- Trocar implementações facilmente
- Independente de frameworks
- Reutilização de código

## 🚀 Próximos Passos

### 1. Adicionar Banco de Dados
```dart
// Criar novo datasource
class ProductDatabaseDataSource implements ProductDataSource {
  final Database db;
  // Implementação com SQL
}

// Atualizar DI
final dataSource = ProductDatabaseDataSource(database);
// Resto do código permanece igual!
```

### 2. Adicionar Cache
```dart
class ProductCachedDataSource implements ProductDataSource {
  final ProductDataSource remote;
  final Cache cache;
  
  ProductModel? getById(String id) {
    // Buscar no cache primeiro
    final cached = cache.get(id);
    if (cached != null) return cached;
    
    // Buscar no datasource remoto
    final product = remote.getById(id);
    cache.set(id, product);
    return product;
  }
}
```

### 3. Adicionar Validações Complexas
```dart
class ValidateProductUseCase {
  Future<bool> execute(ProductEntity product) async {
    // Validações complexas de negócio
    if (product.name.contains('proibido')) return false;
    if (product.price > 10000) return false;
    return true;
  }
}
```

## 📚 Recursos

- [docs/CLEAN_ARCHITECTURE.md](docs/CLEAN_ARCHITECTURE.md) - Documentação completa
- [docs/architecture_diagram.md](docs/architecture_diagram.md) - Diagramas visuais
- [README_CLEAN_ARCH.md](README_CLEAN_ARCH.md) - Resumo das mudanças

## ❓ FAQ

**P: Por que tantos arquivos?**
R: Separação de responsabilidades. Cada arquivo tem um propósito único e claro.

**P: Não é over-engineering?**
R: Para projetos pequenos, pode parecer. Mas facilita muito a manutenção e crescimento.

**P: Preciso usar todas as camadas?**
R: Sim, para manter a consistência e aproveitar os benefícios da arquitetura.

**P: Como adicionar uma nova funcionalidade?**
R: Siga o fluxo: Domain (use case) → Data (repository) → Presentation (controller/handler)

**P: Posso misturar com a estrutura antiga?**
R: Não recomendado. Mantenha a consistência usando apenas a nova estrutura.
