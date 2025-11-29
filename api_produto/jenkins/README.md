# Configuração Jenkins para API Produto

Este diretório contém a configuração completa do Jenkins para CI/CD do projeto.

## Estrutura

- `Dockerfile` - Imagem customizada do Jenkins com Dart e Docker
- `docker-compose.yml` - Configuração para executar Jenkins em container
- `jenkins_casc.yaml` - Configuração as Code (JCasC) do Jenkins

## Início Rápido

### 1. Iniciar Jenkins

```bash
cd jenkins
docker-compose up -d
```

### 2. Acessar Jenkins

- URL: http://localhost:8081
- Usuário: `admin`
- Senha: `admin123`

**IMPORTANTE**: Altere a senha padrão após o primeiro acesso!

### 3. Configurar Credenciais

Se você usar Docker Registry privado:

1. Acesse: Jenkins → Manage Jenkins → Credentials
2. Adicione credencial do tipo "Username with password"
3. ID: `docker-credentials`
4. Username: seu usuário do Docker Hub
5. Password: seu token de acesso

### 4. Configurar Pipeline

1. O job `api_produto_pipeline` será criado automaticamente
2. Configure a URL do repositório Git em `jenkins_casc.yaml`
3. Reinicie o Jenkins: `docker-compose restart`

## Pipeline Stages

O Jenkinsfile inclui os seguintes estágios:

1. **Checkout** - Clone do repositório
2. **Install Dependencies** - `dart pub get`
3. **Lint & Analysis** - `dart analyze`
4. **Run Tests** - `dart test`
5. **Test Coverage** - Geração de relatório de cobertura
6. **Build Docker Image** - Construção da imagem
7. **Push Docker Image** - Push para registry (apenas branch main)
8. **Deploy** - Deploy com docker-compose (apenas branch main)

## Variáveis de Ambiente

Configure no Jenkinsfile:

```groovy
environment {
    DOCKER_IMAGE = 'api_produto'
    DOCKER_TAG = "${env.BUILD_NUMBER}"
    DOCKER_REGISTRY = 'docker.io/seu-usuario' // Opcional
}
```

## Webhooks Git

Para trigger automático em push:

### GitHub

1. Vá em: Settings → Webhooks → Add webhook
2. Payload URL: `http://seu-jenkins:8081/github-webhook/`
3. Content type: `application/json`
4. Events: `Just the push event`

### GitLab

1. Vá em: Settings → Webhooks
2. URL: `http://seu-jenkins:8081/project/api_produto_pipeline`
3. Trigger: `Push events`

## Plugins Instalados

- Git
- Docker Pipeline
- Pipeline Stage View
- Blue Ocean
- Workflow Aggregator
- Credentials Binding
- Timestamper
- Workspace Cleanup

## Troubleshooting

### Permissões Docker

Se houver erro de permissão do Docker:

```bash
docker exec -it jenkins_dart bash
usermod -aG docker jenkins
exit
docker-compose restart
```

### Logs

```bash
docker-compose logs -f jenkins
```

### Reset Completo

```bash
docker-compose down -v
docker-compose up -d
```

## Segurança

- Altere a senha padrão imediatamente
- Configure HTTPS em produção
- Use secrets para credenciais sensíveis
- Restrinja acesso à rede do Jenkins
- Mantenha plugins atualizados

## Customização

### Adicionar Plugins

Edite `Dockerfile` e adicione na linha `jenkins-plugin-cli`:

```dockerfile
RUN jenkins-plugin-cli --plugins \
    git \
    docker-workflow \
    seu-novo-plugin
```

### Modificar Configuração

Edite `jenkins_casc.yaml` e reinicie:

```bash
docker-compose restart
```

## Integração com Kubernetes

Para deploy em Kubernetes, adicione stage no Jenkinsfile:

```groovy
stage('Deploy to K8s') {
    steps {
        sh 'kubectl apply -f k8s/'
    }
}
```

## Monitoramento

Acesse métricas em:
- http://localhost:8081/monitoring
- http://localhost:8081/metrics

## Backup

Backup do volume Jenkins:

```bash
docker run --rm -v jenkins_jenkins_home:/data -v $(pwd):/backup ubuntu tar czf /backup/jenkins_backup.tar.gz /data
```

Restore:

```bash
docker run --rm -v jenkins_jenkins_home:/data -v $(pwd):/backup ubuntu tar xzf /backup/jenkins_backup.tar.gz -C /
```
