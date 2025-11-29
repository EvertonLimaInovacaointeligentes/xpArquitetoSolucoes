# API Produto

API REST CRUD de produtos desenvolvida em Dart usando Shelf com documentação Swagger e Clean Architecture.

## Instalação

```bash
dart pub get
```

## Executar

### Localmente com Dart

```bash
dart run bin/server.dart
```

### Com Docker Compose

```bash
# Construir e iniciar o container
docker-compose up -d

# Ver logs
docker-compose logs -f

# Parar o container
docker-compose down

# Reconstruir após mudanças
docker-compose up -d --build
```

O servidor iniciará em `http://localhost:8080`

## Documentação Swagger

Acesse a documentação interativa da API em:
```
http://localhost:8080/swagger/
```

A documentação Swagger permite testar todos os endpoints diretamente pelo navegador.

## Comandos Úteis (Makefile)

```bash
make help           # Mostrar todos os comandos disponíveis
make install        # Instalar dependências
make run            # Executar aplicação
make test           # Executar testes
make docker-build   # Construir imagem Docker
make docker-up      # Iniciar container
make docker-down    # Parar container
make docker-logs    # Ver logs
```

## Endpoints

### Listar todos os produtos
```bash
GET /products
```

### Buscar produto por ID
```bash
GET /products/{id}
```

### Criar produto
```bash
POST /products
Content-Type: application/json

{
  "name": "Notebook",
  "price": 2500.00,
  "quantity": 10
}
```

### Atualizar produto
```bash
PUT /products/{id}
Content-Type: application/json

{
  "name": "Notebook Dell",
  "price": 2800.00,
  "quantity": 8
}
```

### Deletar produto
```bash
DELETE /products/{id}
```

## 🏗️ Arquitetura

Este projeto segue os princípios do **Clean Architecture**, organizando o código em camadas bem definidas:

```
lib/
├── domain/          # ⭐ Regras de Negócio (Entities, Use Cases, Repository Interfaces)
├── data/            # 💾 Acesso aos Dados (Models, DataSources, Repository Implementations)
├── presentation/    # 🌐 Interface/API (Controllers, DTOs, Handlers)
└── infrastructure/  # ⚙️ Configurações (Dependency Injection)
```

### Documentação Completa
- 📖 [Clean Architecture](docs/CLEAN_ARCHITECTURE.md) - Explicação detalhada das camadas
- 📊 [Diagramas](docs/architecture_diagram.md) - Visualização da arquitetura
- 🔄 [Guia de Migração](MIGRATION_GUIDE.md) - Como o projeto foi refatorado
- 💡 [Exemplos Práticos](docs/EXAMPLES.md) - Cenários comuns e soluções

## Testes

Execute todos os testes:
```bash
dart test
```

Execute testes por camada:
```bash
# Testar camada de domínio
dart test test/domain/

# Testar camada de dados
dart test test/data/

# Testar camada de apresentação
dart test test/presentation/
```

Execute testes com cobertura:
```bash
dart test --coverage=coverage
dart pub global activate coverage
dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib
```

## Exemplos com curl

```bash
# Criar produto
curl -X POST http://localhost:8080/products \
  -H "Content-Type: application/json" \
  -d '{"name":"Mouse","price":50.00,"quantity":20}'

# Listar produtos
curl http://localhost:8080/products

# Buscar produto
curl http://localhost:8080/products/1

# Atualizar produto
curl -X PUT http://localhost:8080/products/1 \
  -H "Content-Type: application/json" \
  -d '{"name":"Mouse Gamer","price":150.00,"quantity":15}'

# Deletar produto
curl -X DELETE http://localhost:8080/products/1
```
