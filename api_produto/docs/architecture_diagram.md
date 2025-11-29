# Diagrama da Arquitetura

## Visão Geral das Camadas

```
┌─────────────────────────────────────────────────────────────┐
│                      INFRASTRUCTURE                          │
│  ┌────────────────────────────────────────────────────┐     │
│  │         Dependency Injection Container              │     │
│  │  - Cria e conecta todas as dependências            │     │
│  └────────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────┘
                            │
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                      PRESENTATION                            │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │   Handler    │ →  │  Controller  │ →  │     DTO      │  │
│  │  (HTTP/API)  │    │ (Orquestra)  │    │  (Transfer)  │  │
│  └──────────────┘    └──────────────┘    └──────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            │
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                         DOMAIN                               │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │   Entity     │ ←  │   Use Case   │ →  │  Repository  │  │
│  │  (Business)  │    │   (Logic)    │    │  (Interface) │  │
│  └──────────────┘    └──────────────┘    └──────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            │
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                          DATA                                │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │    Model     │ ←  │  Repository  │ →  │  DataSource  │  │
│  │ (Serialize)  │    │    (Impl)    │    │   (Storage)  │  │
│  └──────────────┘    └──────────────┘    └──────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Fluxo de Criação de Produto

```
1. HTTP POST /products
   │
   ↓
2. ProductHandler._create()
   │ - Recebe Request
   │ - Extrai JSON
   ↓
3. ProductController.createProduct()
   │ - Valida entrada
   │ - Chama use case
   ↓
4. CreateProductUseCase.execute()
   │ - Validações de negócio
   │ - Cria ProductEntity
   ↓
5. ProductRepository.create()
   │ - Interface (contrato)
   ↓
6. ProductRepositoryImpl.create()
   │ - Converte Entity → Model
   │ - Chama DataSource
   ↓
7. ProductMemoryDataSource.create()
   │ - Gera ID
   │ - Armazena em memória
   │ - Retorna Model
   ↓
8. Retorno (caminho inverso)
   │ Model → Entity → DTO → JSON
   ↓
9. HTTP Response 201 Created
```

## Dependências entre Camadas

```
┌──────────────┐
│Infrastructure│
└──────┬───────┘
       │ conhece todas
       ↓
┌──────────────┐     ┌──────────────┐
│ Presentation │ →   │     Data     │
└──────┬───────┘     └──────┬───────┘
       │                    │
       └────────┬───────────┘
                ↓
         ┌──────────────┐
         │    Domain    │
         │ (Independente)│
         └──────────────┘
```

**Regra:** Dependências apontam para dentro (Domain é o centro)

## Componentes Detalhados

### Domain Layer (Núcleo)
```
ProductEntity
├── id: String
├── name: String
├── price: double
├── quantity: int
├── isValid(): bool
├── totalValue: double
└── inStock: bool

ProductRepository (Interface)
├── getAll(): Future<List<ProductEntity>>
├── getById(id): Future<ProductEntity?>
├── create(product): Future<ProductEntity>
├── update(id, product): Future<ProductEntity?>
└── delete(id): Future<bool>

Use Cases
├── CreateProductUseCase
├── UpdateProductUseCase
├── DeleteProductUseCase
├── GetAllProductsUseCase
└── GetProductByIdUseCase
```

### Data Layer
```
ProductModel extends ProductEntity
├── toJson(): Map<String, dynamic>
├── fromJson(json): ProductModel
├── fromEntity(entity): ProductModel
└── toEntity(): ProductEntity

ProductRepositoryImpl implements ProductRepository
└── dataSource: ProductDataSource

ProductMemoryDataSource implements ProductDataSource
├── _products: List<ProductModel>
├── _nextId: int
└── CRUD operations
```

### Presentation Layer
```
ProductHandler
├── router: Router
├── _getAll(request): Response
├── _getById(request, id): Response
├── _create(request): Response
├── _update(request, id): Response
└── _delete(request, id): Response

ProductController
├── getAllProductsUseCase
├── getProductByIdUseCase
├── createProductUseCase
├── updateProductUseCase
└── deleteProductUseCase

ProductDto
├── toJson(): Map<String, dynamic>
├── fromJson(json): ProductDto
├── fromEntity(entity): ProductDto
└── toEntity(): ProductEntity
```

## Exemplo de Teste Isolado

```
┌─────────────────────────────────────┐
│  Test: CreateProductUseCase         │
│                                     │
│  ┌─────────────────────────────┐   │
│  │  MockProductRepository      │   │
│  │  (Fake implementation)      │   │
│  └─────────────────────────────┘   │
│              ↑                      │
│              │                      │
│  ┌─────────────────────────────┐   │
│  │  CreateProductUseCase       │   │
│  │  (Real implementation)      │   │
│  └─────────────────────────────┘   │
│                                     │
│  Testa APENAS a lógica de negócio  │
│  sem depender de DB, HTTP, etc.    │
└─────────────────────────────────────┘
```

## Vantagens Visuais

### ✅ Adicionar novo DataSource
```
ProductMemoryDataSource ──┐
                          ├─→ ProductDataSource (Interface)
ProductDatabaseDataSource ─┘

Apenas criar nova implementação!
Nenhuma mudança em Domain ou Presentation.
```

### ✅ Trocar Framework HTTP
```
Shelf Handler ──┐
                ├─→ ProductController
Express Handler ─┘

Controller permanece o mesmo!
```

### ✅ Adicionar nova funcionalidade
```
1. Criar: SearchProductsByNameUseCase (Domain)
2. Adicionar: searchByName() no Repository (Domain)
3. Implementar: no DataSource (Data)
4. Expor: no Controller (Presentation)
5. Criar: endpoint no Handler (Presentation)

Cada passo é isolado e testável!
```
