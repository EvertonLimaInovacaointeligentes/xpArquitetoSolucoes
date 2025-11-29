# Projeto Refatorado com Clean Architecture

## 🎯 O que mudou?

O projeto foi completamente refatorado seguindo os princípios do **Clean Architecture**, separando responsabilidades em camadas bem definidas.

### Estrutura Anterior
```
lib/
├── models/
│   └── product.dart
├── services/
│   └── product_service.dart
└── handlers/
    └── product_handler.dart
```

### Nova Estrutura (Clean Architecture)
```
lib/
├── domain/                    # Regras de Negócio
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
├── data/                      # Acesso aos Dados
│   ├── datasources/
│   │   ├── product_datasource.dart
│   │   └── product_memory_datasource.dart
│   ├── models/
│   │   └── product_model.dart
│   └── repositories/
│       └── product_repository_impl.dart
│
├── presentation/              # Interface/API
│   ├── controllers/
│   │   └── product_controller.dart
│   ├── dto/
│   │   └── product_dto.dart
│   └── handlers/
│       └── product_handler.dart
│
└── infrastructure/            # Configurações
    └── di/
        └── dependency_injection.dart
```

## 🔄 Fluxo de Dados

```
HTTP Request
    ↓
ProductHandler (Presentation)
    ↓
ProductController (Presentation)
    ↓
CreateProductUseCase (Domain)
    ↓
ProductRepository Interface (Domain)
    ↓
ProductRepositoryImpl (Data)
    ↓
ProductMemoryDataSource (Data)
    ↓
Storage (Memory)
```

## ✨ Benefícios

### 1. Separação de Responsabilidades
- **Domain:** Lógica de negócio pura, sem dependências externas
- **Data:** Gerencia persistência e conversão de dados
- **Presentation:** Lida com HTTP e formatação de respostas
- **Infrastructure:** Conecta todas as camadas

### 2. Testabilidade
Cada camada pode ser testada isoladamente:
```bash
# Testar apenas regras de negócio
dart test test/domain/

# Testar apenas acesso aos dados
dart test test/data/

# Testar apenas apresentação
dart test test/presentation/
```

### 3. Manutenibilidade
- Mudanças em uma camada não afetam outras
- Fácil adicionar novos recursos
- Código mais organizado e legível

### 4. Flexibilidade
Trocar implementações sem afetar o resto do código:

**Exemplo:** Mudar de memória para banco de dados
```dart
// Antes (DI)
final dataSource = ProductMemoryDataSource();

// Depois (apenas mudar esta linha!)
final dataSource = ProductDatabaseDataSource(database);
```

### 5. Independência de Framework
- Domain não conhece Shelf, HTTP ou qualquer framework
- Pode migrar de Shelf para outro framework facilmente
- Regras de negócio permanecem intactas

## 📋 Comparação

### Antes (Estrutura Simples)
```dart
// Tudo junto no handler
class ProductHandler {
  final ProductService _service = ProductService();
  
  Response _create(Request request) {
    // Validação + Lógica + Persistência tudo aqui
    final product = _service.create(name, price, quantity);
    return Response.ok(jsonEncode(product.toJson()));
  }
}
```

### Depois (Clean Architecture)
```dart
// Handler apenas gerencia HTTP
class ProductHandler {
  Future<Response> _create(Request request) async {
    final product = await controller.createProduct(...);
    return Response(201, body: jsonEncode(dto.toJson()));
  }
}

// Controller orquestra use cases
class ProductController {
  Future<ProductEntity> createProduct(...) async {
    return await createProductUseCase.execute(...);
  }
}

// Use Case contém lógica de negócio
class CreateProductUseCase {
  Future<ProductEntity> execute(...) async {
    // Validações de negócio
    if (name.isEmpty) throw Exception('Nome inválido');
    // Persistir via repositório
    return await repository.create(product);
  }
}
```

## 🚀 Como Usar

### Executar a aplicação
```bash
dart run bin/server.dart
```

### Executar testes
```bash
dart test
```

### Docker
```bash
docker-compose up -d
```

## 📚 Documentação Completa

Veja [docs/CLEAN_ARCHITECTURE.md](docs/CLEAN_ARCHITECTURE.md) para:
- Explicação detalhada de cada camada
- Princípios SOLID aplicados
- Exemplos de extensão
- Diagramas de fluxo

## 🎓 Aprendizado

Este projeto demonstra:
- ✅ Clean Architecture
- ✅ SOLID Principles
- ✅ Dependency Injection
- ✅ Repository Pattern
- ✅ Use Case Pattern
- ✅ DTO Pattern
- ✅ Separation of Concerns
