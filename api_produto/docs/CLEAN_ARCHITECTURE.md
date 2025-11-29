# Clean Architecture - Estrutura do Projeto

Este projeto segue os princípios do Clean Architecture, organizando o código em camadas bem definidas com responsabilidades claras.

## Estrutura de Camadas

```
lib/
├── domain/              # Camada de Domínio (Regras de Negócio)
│   ├── entities/        # Entidades de negócio
│   ├── repositories/    # Interfaces dos repositórios
│   └── usecases/        # Casos de uso (lógica de negócio)
│
├── data/                # Camada de Dados
│   ├── datasources/     # Fontes de dados (API, DB, Memory)
│   ├── models/          # Modelos de dados (serialização)
│   └── repositories/    # Implementação dos repositórios
│
├── presentation/        # Camada de Apresentação
│   ├── controllers/     # Controladores (orquestração)
│   ├── dto/             # Data Transfer Objects
│   └── handlers/        # Handlers HTTP (Shelf)
│
└── infrastructure/      # Camada de Infraestrutura
    └── di/              # Dependency Injection
```

## Camadas

### 1. Domain (Domínio)
**Responsabilidade:** Contém as regras de negócio puras, independentes de frameworks.

- **Entities:** Objetos de negócio com lógica de domínio
  - `ProductEntity`: Representa um produto com validações de negócio

- **Repositories (Interfaces):** Contratos para acesso aos dados
  - `ProductRepository`: Define operações CRUD

- **Use Cases:** Casos de uso específicos da aplicação
  - `CreateProductUseCase`: Criar produto com validações
  - `UpdateProductUseCase`: Atualizar produto
  - `GetAllProductsUseCase`: Listar produtos
  - `GetProductByIdUseCase`: Buscar produto por ID
  - `DeleteProductUseCase`: Deletar produto

**Regra:** Esta camada NÃO depende de nenhuma outra camada.

### 2. Data (Dados)
**Responsabilidade:** Implementa o acesso aos dados e conversões.

- **DataSources:** Fontes de dados concretas
  - `ProductDataSource`: Interface do datasource
  - `ProductMemoryDataSource`: Implementação em memória

- **Models:** Modelos para serialização/deserialização
  - `ProductModel`: Converte entre JSON e entidades

- **Repositories (Implementação):** Implementa as interfaces do domínio
  - `ProductRepositoryImpl`: Conecta datasource com domínio

**Regra:** Depende apenas da camada de Domínio.

### 3. Presentation (Apresentação)
**Responsabilidade:** Gerencia a interface com o usuário/cliente.

- **Controllers:** Orquestram os use cases
  - `ProductController`: Coordena operações de produtos

- **DTOs:** Objetos de transferência de dados
  - `ProductDto`: Formato de dados para API

- **Handlers:** Gerenciam requisições HTTP
  - `ProductHandler`: Endpoints REST da API

**Regra:** Depende apenas da camada de Domínio.

### 4. Infrastructure (Infraestrutura)
**Responsabilidade:** Configurações e integrações externas.

- **Dependency Injection:** Configura e injeta dependências
  - `DependencyInjection`: Cria e conecta todas as camadas

**Regra:** Conhece todas as camadas para conectá-las.

## Fluxo de Dados

```
HTTP Request
    ↓
Handler (Presentation)
    ↓
Controller (Presentation)
    ↓
Use Case (Domain)
    ↓
Repository Interface (Domain)
    ↓
Repository Implementation (Data)
    ↓
DataSource (Data)
    ↓
Storage (Memory/DB)
```

## Princípios Aplicados

### 1. Dependency Inversion Principle (DIP)
- Camadas externas dependem de abstrações das camadas internas
- Domain define interfaces, Data implementa

### 2. Single Responsibility Principle (SRP)
- Cada classe tem uma única responsabilidade
- Use cases focados em uma operação específica

### 3. Open/Closed Principle (OCP)
- Fácil adicionar novos datasources sem modificar o domínio
- Exemplo: trocar `ProductMemoryDataSource` por `ProductDatabaseDataSource`

### 4. Interface Segregation Principle (ISP)
- Interfaces pequenas e específicas
- `ProductRepository` define apenas operações necessárias

### 5. Liskov Substitution Principle (LSP)
- Implementações podem ser substituídas sem quebrar o código
- Qualquer `ProductDataSource` pode ser usado

## Vantagens

✅ **Testabilidade:** Cada camada pode ser testada isoladamente
✅ **Manutenibilidade:** Mudanças em uma camada não afetam outras
✅ **Escalabilidade:** Fácil adicionar novos recursos
✅ **Independência de Framework:** Domínio não conhece Shelf, HTTP, etc.
✅ **Flexibilidade:** Trocar implementações facilmente (ex: memória → banco de dados)

## Exemplo de Extensão

Para adicionar persistência em banco de dados:

1. Criar `ProductDatabaseDataSource implements ProductDataSource`
2. Atualizar `DependencyInjection` para usar o novo datasource
3. Nenhuma mudança necessária em Domain ou Presentation!

```dart
// Novo datasource
class ProductDatabaseDataSource implements ProductDataSource {
  final Database db;
  // Implementação...
}

// Atualizar DI
final dataSource = ProductDatabaseDataSource(database);
```

## Testes

Cada camada tem seus próprios testes:

- **Domain:** Testa entidades e use cases
- **Data:** Testa datasources e repositories
- **Presentation:** Testa controllers e handlers
- **Integration:** Testa fluxo completo

## Referências

- [Clean Architecture - Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [SOLID Principles](https://en.wikipedia.org/wiki/SOLID)
