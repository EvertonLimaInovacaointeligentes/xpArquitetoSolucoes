# 🚀 Stages do Pipeline CI/CD

Este documento descreve cada etapa do pipeline Jenkins para a API Produto.

## Fluxo do Pipeline

```
┌─────────────────────────────────────────────────────────────────┐
│                    🚀 INICIANDO PIPELINE                        │
│  • Exibe informações do build (número, branch, commit)         │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                      📥 CHECKOUT                                │
│  • Clone do repositório Git                                     │
│  • Exibe último commit                                          │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                📦 INSTALANDO DEPENDÊNCIAS                       │
│  • Verifica versão do Dart                                      │
│  • Executa: dart pub get                                        │
│  • Baixa todas as dependências do pubspec.yaml                  │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                  🔍 ANÁLISE DE CÓDIGO                           │
│  • Executa: dart analyze --fatal-infos                          │
│  • Verifica:                                                    │
│    - Erros de sintaxe                                           │
│    - Warnings de código                                         │
│    - Problemas de estilo                                        │
│    - Code smells                                                │
│  • Falha se encontrar problemas                                 │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                   🧪 TESTES UNITÁRIOS                           │
│  • Executa: dart test --reporter=expanded                       │
│  • Roda todos os testes em:                                     │
│    - test/domain/                                               │
│    - test/data/                                                 │
│    - test/presentation/                                         │
│  • Exibe resultado detalhado de cada teste                      │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                 📊 COBERTURA DE CÓDIGO                          │
│  • Gera relatório de cobertura                                  │
│  • Calcula porcentagem de código testado                        │
│  • Cria arquivo lcov.info                                       │
│  • Exibe: "Cobertura de código: XX%"                            │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                 🏗️ BUILD DA APLICAÇÃO                           │
│  • Compila: dart compile exe bin/server.dart                    │
│  • Gera executável nativo otimizado                             │
│  • Valida que a aplicação compila sem erros                     │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                 🐳 BUILD DOCKER IMAGE                           │
│  • Constrói imagem Docker usando Dockerfile                     │
│  • Tags criadas:                                                │
│    - api_produto:BUILD_NUMBER                                   │
│    - api_produto:latest                                         │
│  • Exibe informações da imagem criada                           │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                  🔐 SCAN DE SEGURANÇA                           │
│  • Verifica dependências desatualizadas                         │
│  • Executa: dart pub outdated                                   │
│  • Identifica vulnerabilidades conhecidas                       │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                    ┌─────────────────┐
                    │  Branch main?   │
                    └─────────────────┘
                       Sim ↓    ↓ Não (pula para fim)
┌─────────────────────────────────────────────────────────────────┐
│                 📤 PUSH DOCKER IMAGE                            │
│  • Envia imagem para Docker Registry                            │
│  • Push de ambas as tags (BUILD_NUMBER e latest)                │
│  • Requer credenciais configuradas                              │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                      🚀 DEPLOY                                  │
│  • Para containers antigos: docker-compose down                 │
│  • Inicia novos containers: docker-compose up -d                │
│  • Aguarda 10 segundos para inicialização                       │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                   ✅ HEALTH CHECK                               │
│  • Verifica se aplicação está respondendo                       │
│  • Tenta até 5 vezes com intervalo de 5s                        │
│  • Verifica endpoint: http://localhost:8080/                    │
│  • Espera status HTTP 200                                       │
│  • Exibe logs do container                                      │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                 📋 RESUMO DO DEPLOY                             │
│  • Exibe informações finais:                                    │
│    - Número do build                                            │
│    - Tag da imagem                                              │
│    - URL da aplicação                                           │
│    - URL do Swagger                                             │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    🧹 LIMPEZA (POST)                            │
│  • Arquiva relatórios de cobertura                             │
│  • Publica relatório HTML                                       │
│  • Limpa workspace                                              │
│  • Exibe duração total do pipeline                              │
└─────────────────────────────────────────────────────────────────┘
```

## Detalhamento dos Stages

### 1. 🚀 Iniciando Pipeline
**Duração:** ~5 segundos  
**Objetivo:** Inicializar o pipeline e exibir informações contextuais

**Ações:**
- Exibe banner do pipeline
- Mostra número do build
- Exibe branch atual
- Mostra hash do commit

**Saída esperada:**
```
==========================================
  Pipeline CI/CD - API Produto
==========================================
Build: #42
Branch: main
Commit: a1b2c3d
==========================================
```

---

### 2. 📥 Checkout
**Duração:** ~10-30 segundos  
**Objetivo:** Obter código fonte do repositório

**Ações:**
- Clone do repositório Git
- Checkout da branch específica
- Exibe informações do último commit

**Falha se:**
- Repositório inacessível
- Credenciais inválidas
- Branch não existe

---

### 3. 📦 Instalando Dependências
**Duração:** ~20-60 segundos  
**Objetivo:** Baixar e instalar todas as dependências do projeto

**Ações:**
- Verifica versão do Dart SDK
- Executa `dart pub get`
- Baixa pacotes do pub.dev

**Falha se:**
- Dart não instalado
- pubspec.yaml inválido
- Dependências não encontradas
- Conflitos de versão

---

### 4. 🔍 Análise de Código
**Duração:** ~15-45 segundos  
**Objetivo:** Garantir qualidade e padrões do código

**Ações:**
- Executa análise estática
- Verifica regras do analysis_options.yaml
- Identifica code smells
- Valida imports não utilizados

**Verifica:**
- ✅ Erros de sintaxe
- ✅ Warnings
- ✅ Hints
- ✅ Lints configurados

**Falha se:**
- Erros de sintaxe encontrados
- Warnings críticos (--fatal-infos)
- Violações de regras de lint

---

### 5. 🧪 Testes Unitários
**Duração:** ~30-120 segundos  
**Objetivo:** Validar funcionalidade do código

**Ações:**
- Executa todos os testes
- Usa reporter expandido para detalhes
- Testa todas as camadas (domain, data, presentation)

**Estrutura de testes:**
```
test/
├── domain/         # Testes de entidades e use cases
├── data/           # Testes de repositories e datasources
└── presentation/   # Testes de controllers e handlers
```

**Falha se:**
- Qualquer teste falhar
- Timeout em testes
- Erros de execução

---

### 6. 📊 Cobertura de Código
**Duração:** ~20-60 segundos  
**Objetivo:** Medir qualidade dos testes

**Ações:**
- Gera dados de cobertura
- Cria relatório LCOV
- Calcula porcentagem de cobertura
- Identifica código não testado

**Métricas:**
- Lines Hit (LH): Linhas executadas
- Lines Found (LF): Total de linhas
- Coverage: (LH / LF) * 100

**Saída esperada:**
```
✅ Cobertura de código: 85.5%
```

---

### 7. 🏗️ Build da Aplicação
**Duração:** ~30-90 segundos  
**Objetivo:** Compilar aplicação para executável nativo

**Ações:**
- Compila bin/server.dart
- Gera executável otimizado
- Valida compilação sem erros

**Benefícios:**
- Startup mais rápido
- Menor uso de memória
- Não requer Dart SDK em produção

**Falha se:**
- Erros de compilação
- Dependências faltando
- Problemas de sintaxe

---

### 8. 🐳 Build Docker Image
**Duração:** ~60-180 segundos  
**Objetivo:** Criar imagem Docker da aplicação

**Ações:**
- Executa Dockerfile
- Cria imagem com multi-stage build
- Gera duas tags (BUILD_NUMBER e latest)
- Otimiza tamanho da imagem

**Tags criadas:**
```
api_produto:42
api_produto:latest
```

**Falha se:**
- Dockerfile inválido
- Erro no build
- Falta de espaço em disco

---

### 9. 🔐 Scan de Segurança
**Duração:** ~15-45 segundos  
**Objetivo:** Identificar vulnerabilidades

**Ações:**
- Verifica dependências desatualizadas
- Lista pacotes com vulnerabilidades
- Sugere atualizações

**Saída esperada:**
```
Checking dependencies...
All dependencies are up to date!
```

---

### 10. 📤 Push Docker Image
**Duração:** ~30-120 segundos  
**Objetivo:** Enviar imagem para registry  
**Condição:** Apenas branch `main`

**Ações:**
- Autentica no Docker Registry
- Faz push da imagem com tag BUILD_NUMBER
- Faz push da imagem com tag latest

**Requer:**
- Credencial `docker-credentials` configurada
- DOCKER_REGISTRY definido

**Falha se:**
- Credenciais inválidas
- Registry inacessível
- Timeout de rede

---

### 11. 🚀 Deploy
**Duração:** ~20-60 segundos  
**Objetivo:** Implantar aplicação em ambiente  
**Condição:** Apenas branch `main`

**Ações:**
1. Para containers antigos
2. Remove containers parados
3. Inicia novos containers
4. Aguarda inicialização

**Comandos:**
```bash
docker-compose down
docker-compose up -d
```

**Falha se:**
- docker-compose.yml inválido
- Porta já em uso
- Recursos insuficientes

---

### 12. ✅ Health Check
**Duração:** ~10-30 segundos  
**Objetivo:** Validar que aplicação está funcionando  
**Condição:** Apenas branch `main`

**Ações:**
- Tenta acessar endpoint raiz
- Retenta até 5 vezes
- Intervalo de 5 segundos entre tentativas
- Exibe logs do container

**Verifica:**
- HTTP Status 200
- Aplicação respondendo
- Container em execução

**Falha se:**
- Aplicação não responde após 5 tentativas
- Status HTTP diferente de 200
- Container crashou

---

### 13. 📋 Resumo do Deploy
**Duração:** ~5 segundos  
**Objetivo:** Exibir informações finais  
**Condição:** Apenas branch `main`

**Saída:**
```
==========================================
  Deploy Concluído com Sucesso!
==========================================
Build: #42
Imagem: api_produto:42
URL: http://localhost:8080
Swagger: http://localhost:8080/swagger/
==========================================
```

---

### 14. 🧹 Limpeza (Post Actions)
**Duração:** ~10-30 segundos  
**Objetivo:** Limpar recursos e arquivar artefatos

**Ações:**
- Arquiva relatórios de cobertura
- Publica relatório HTML
- Limpa workspace
- Exibe duração total

**Sempre executado:**
- ✅ Em caso de sucesso
- ❌ Em caso de falha
- ⚠️ Em caso de instabilidade

---

## Tempos Estimados

| Stage | Tempo Mínimo | Tempo Médio | Tempo Máximo |
|-------|--------------|-------------|--------------|
| Iniciando | 5s | 5s | 10s |
| Checkout | 10s | 20s | 60s |
| Dependências | 20s | 40s | 120s |
| Análise | 15s | 30s | 60s |
| Testes | 30s | 60s | 180s |
| Cobertura | 20s | 40s | 90s |
| Build App | 30s | 60s | 120s |
| Build Docker | 60s | 120s | 300s |
| Scan | 15s | 30s | 60s |
| Push | 30s | 60s | 180s |
| Deploy | 20s | 40s | 90s |
| Health Check | 10s | 20s | 35s |
| **TOTAL** | **~4min** | **~8min** | **~23min** |

## Variáveis de Ambiente

```groovy
DOCKER_IMAGE = 'api_produto'           // Nome da imagem
DOCKER_TAG = "${BUILD_NUMBER}"         // Tag da imagem
DOCKER_REGISTRY = ''                   // Registry (opcional)
APP_PORT = '8080'                      // Porta da aplicação
```

## Condições de Execução

### Stages que sempre executam:
- 🚀 Iniciando Pipeline
- 📥 Checkout
- 📦 Instalando Dependências
- 🔍 Análise de Código
- 🧪 Testes Unitários
- 📊 Cobertura de Código
- 🏗️ Build da Aplicação
- 🐳 Build Docker Image
- 🔐 Scan de Segurança

### Stages condicionais (apenas branch `main`):
- 📤 Push Docker Image
- 🚀 Deploy
- ✅ Health Check
- 📋 Resumo do Deploy

## Artefatos Gerados

1. **Executável compilado:** `bin/server`
2. **Relatório de cobertura:** `coverage/lcov.info`
3. **Imagem Docker:** `api_produto:BUILD_NUMBER`
4. **Logs do pipeline:** Disponíveis no Jenkins

## Notificações

### Sucesso ✅
```
==========================================
  ✅ Pipeline Executado com Sucesso!
==========================================
Duração: 8min 32s
Build: #42
==========================================
```

### Falha ❌
```
==========================================
  ❌ Pipeline Falhou!
==========================================
Build: #42
Stage: Testes Unitários
==========================================
```

## Troubleshooting

### Pipeline falha em "Análise de Código"
- Execute localmente: `dart analyze`
- Corrija warnings e erros
- Commit e push novamente

### Pipeline falha em "Testes"
- Execute localmente: `dart test`
- Verifique testes falhando
- Corrija e commit

### Pipeline falha em "Health Check"
- Verifique logs: `docker-compose logs`
- Verifique porta 8080 disponível
- Verifique configuração do docker-compose.yml

### Build Docker muito lento
- Use cache de layers
- Otimize Dockerfile
- Limpe imagens antigas: `docker system prune`

## Melhorias Futuras

- [ ] Testes de integração
- [ ] Testes de performance
- [ ] Deploy em múltiplos ambientes (dev, staging, prod)
- [ ] Notificações Slack/Email
- [ ] Rollback automático em falha
- [ ] Blue-Green deployment
- [ ] Análise de segurança com Trivy
- [ ] Métricas de qualidade (SonarQube)
