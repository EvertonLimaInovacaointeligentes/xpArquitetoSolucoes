# Terraform - API Produto Kubernetes

Infraestrutura como Código (IaC) para provisionar e gerenciar a API Produto no Kubernetes usando Terraform.

## 📁 Estrutura

```
terraform/
├── main.tf                      # Recursos principais
├── variables.tf                 # Definição de variáveis
├── outputs.tf                   # Outputs do Terraform
├── terraform.tfvars.example     # Exemplo de variáveis
├── environments/                # Configurações por ambiente
│   ├── dev.tfvars
│   ├── staging.tfvars
│   └── production.tfvars
├── deploy.sh                    # Script de deploy (Linux/Mac)
├── deploy.bat                   # Script de deploy (Windows)
└── README.md                    # Este arquivo
```

## 🚀 Quick Start

### Pré-requisitos

1. **Terraform** (>= 1.0)
   ```bash
   # Linux
   wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
   unzip terraform_1.6.0_linux_amd64.zip
   sudo mv terraform /usr/local/bin/
   
   # macOS
   brew install terraform
   
   # Windows
   choco install terraform
   ```

2. **kubectl** configurado
   ```bash
   kubectl cluster-info
   ```

3. **Cluster Kubernetes** (Minikube, Docker Desktop, GKE, EKS, AKS)

### Instalação Rápida

```bash
# 1. Entrar no diretório
cd terraform

# 2. Inicializar Terraform
./deploy.sh init

# 3. Planejar deploy (dev)
./deploy.sh plan dev

# 4. Aplicar mudanças
./deploy.sh apply dev
```

### Windows

```cmd
cd terraform
deploy.bat init
deploy.bat plan dev
deploy.bat apply dev
```

## 🌍 Ambientes

### Development
```bash
./deploy.sh apply dev
```

**Configuração:**
- Namespace: `api-produto-dev`
- Réplicas: 1
- Recursos: Mínimos
- HPA: Desabilitado
- Ingress: Desabilitado
- Service: NodePort

### Staging
```bash
./deploy.sh apply staging
```

**Configuração:**
- Namespace: `api-produto-staging`
- Réplicas: 2
- Recursos: Médios
- HPA: 2-5 pods
- Ingress: Habilitado
- Service: LoadBalancer

### Production
```bash
./deploy.sh apply production
```

**Configuração:**
- Namespace: `api-produto`
- Réplicas: 3
- Recursos: Completos
- HPA: 2-10 pods
- Ingress: Habilitado
- Service: LoadBalancer

## 📋 Recursos Criados

O Terraform cria os seguintes recursos no Kubernetes:

1. **Namespace** - Isolamento de recursos
2. **ConfigMap** - Configurações da aplicação
3. **Secret** - Dados sensíveis
4. **Deployment** - Gerenciamento de pods
5. **Service** - Exposição da aplicação
6. **HPA** - Auto-scaling horizontal
7. **Ingress** - Roteamento HTTP/HTTPS
8. **PDB** - Pod Disruption Budget
9. **Network Policy** - Políticas de rede

## 🔧 Comandos

### Inicializar

```bash
# Inicializar Terraform (primeira vez)
terraform init

# Atualizar providers
terraform init -upgrade
```

### Planejar

```bash
# Ver mudanças sem aplicar
terraform plan -var-file=environments/dev.tfvars

# Salvar plano
terraform plan -var-file=environments/dev.tfvars -out=tfplan
```

### Aplicar

```bash
# Aplicar mudanças
terraform apply -var-file=environments/dev.tfvars

# Aplicar sem confirmação
terraform apply -var-file=environments/dev.tfvars -auto-approve

# Aplicar plano salvo
terraform apply tfplan
```

### Destruir

```bash
# Destruir todos os recursos
terraform destroy -var-file=environments/dev.tfvars

# Destruir sem confirmação
terraform destroy -var-file=environments/dev.tfvars -auto-approve
```

### Outputs

```bash
# Ver todos os outputs
terraform output

# Ver output específico
terraform output namespace

# Ver em JSON
terraform output -json
```

### Estado

```bash
# Ver estado atual
terraform show

# Listar recursos
terraform state list

# Ver recurso específico
terraform state show kubernetes_deployment.api_produto

# Atualizar estado
terraform refresh
```

## 📝 Variáveis

### Principais Variáveis

```hcl
# Kubernetes
kubeconfig_path = "~/.kube/config"
namespace       = "api-produto"
environment     = "production"

# Docker
docker_image = "api_produto"
docker_tag   = "latest"

# Application
app_port    = 8080
log_level   = "info"

# Deployment
replicas = 3

# Resources
resources_requests_cpu    = "100m"
resources_requests_memory = "128Mi"
resources_limits_cpu      = "500m"
resources_limits_memory   = "512Mi"

# HPA
enable_hpa       = true
hpa_min_replicas = 2
hpa_max_replicas = 10

# Ingress
enable_ingress = true
ingress_host   = "api-produto.example.com"
```

### Variáveis Sensíveis

Use variáveis de ambiente ou arquivo `.tfvars` (não commitar):

```bash
# Exportar variáveis
export TF_VAR_database_url="postgresql://..."
export TF_VAR_api_key="secret-key"

# Ou criar terraform.tfvars
cat > terraform.tfvars <<EOF
database_url = "postgresql://..."
api_key      = "secret-key"
EOF
```

## 🔐 Secrets Management

### Opção 1: Variáveis de Ambiente

```bash
export TF_VAR_database_url="postgresql://user:pass@host:5432/db"
export TF_VAR_api_key="your-secret-key"

terraform apply -var-file=environments/production.tfvars
```

### Opção 2: Arquivo .tfvars (não commitar)

```bash
# Criar arquivo de secrets
cat > secrets.tfvars <<EOF
database_url = "postgresql://user:pass@host:5432/db"
api_key      = "your-secret-key"
EOF

# Adicionar ao .gitignore
echo "secrets.tfvars" >> .gitignore

# Usar no apply
terraform apply -var-file=environments/production.tfvars -var-file=secrets.tfvars
```

### Opção 3: HashiCorp Vault

```hcl
data "vault_generic_secret" "database" {
  path = "secret/api-produto/database"
}

variable "database_url" {
  default = data.vault_generic_secret.database.data["url"]
}
```

## 📊 Outputs

Após aplicar, você verá:

```
Outputs:

deployment_name = "api-produto"
deployment_replicas = 3
ingress_host = "api-produto.example.com"
ingress_url = "https://api-produto.example.com"
kubectl_commands = {
  "describe" = "kubectl describe deployment api-produto -n api-produto"
  "get_deployments" = "kubectl get deployments -n api-produto"
  "get_pods" = "kubectl get pods -n api-produto"
  "get_services" = "kubectl get svc -n api-produto"
  "logs" = "kubectl logs -f -l app=api-produto -n api-produto"
  "port_forward" = "kubectl port-forward svc/api-produto-service 8080:80 -n api-produto"
}
load_balancer_ip = "34.123.45.67"
namespace = "api-produto"
service_name = "api-produto-service"
```

## 🔄 Workflow Completo

### 1. Desenvolvimento Local

```bash
# Inicializar
terraform init

# Planejar
terraform plan -var-file=environments/dev.tfvars

# Aplicar
terraform apply -var-file=environments/dev.tfvars

# Testar
kubectl port-forward svc/api-produto-service 8080:80 -n api-produto-dev
curl http://localhost:8080
```

### 2. Deploy em Staging

```bash
# Planejar
terraform plan -var-file=environments/staging.tfvars

# Aplicar
terraform apply -var-file=environments/staging.tfvars

# Verificar
kubectl get pods -n api-produto-staging
```

### 3. Deploy em Produção

```bash
# Planejar e revisar
terraform plan -var-file=environments/production.tfvars -out=tfplan-prod

# Revisar plano
terraform show tfplan-prod

# Aplicar
terraform apply tfplan-prod

# Verificar
kubectl get all -n api-produto
```

## 🧪 Testes

### Validar Configuração

```bash
# Validar sintaxe
terraform validate

# Formatar código
terraform fmt

# Verificar segurança (tfsec)
tfsec .
```

### Dry Run

```bash
# Ver mudanças sem aplicar
terraform plan -var-file=environments/dev.tfvars
```

### Testar Localmente

```bash
# Aplicar em dev
terraform apply -var-file=environments/dev.tfvars

# Port forward
kubectl port-forward svc/api-produto-service 8080:80 -n api-produto-dev

# Testar
curl http://localhost:8080/products
```

## 🔄 Atualizações

### Atualizar Imagem Docker

```bash
# Editar variável
terraform apply -var-file=environments/production.tfvars -var="docker_tag=v2.0.0"

# Ou editar arquivo
vim environments/production.tfvars
# docker_tag = "v2.0.0"

terraform apply -var-file=environments/production.tfvars
```

### Escalar Réplicas

```bash
# Via variável
terraform apply -var-file=environments/production.tfvars -var="replicas=5"

# Ou editar arquivo
vim environments/production.tfvars
# replicas = 5

terraform apply -var-file=environments/production.tfvars
```

### Atualizar Recursos

```bash
# Editar arquivo
vim environments/production.tfvars
# resources_limits_cpu = "1000m"
# resources_limits_memory = "1Gi"

terraform apply -var-file=environments/production.tfvars
```

## 🚨 Troubleshooting

### Erro: Cluster não acessível

```bash
# Verificar kubeconfig
kubectl cluster-info

# Verificar contexto
kubectl config current-context

# Atualizar variável
terraform apply -var="kubeconfig_path=/path/to/kubeconfig"
```

### Erro: Namespace já existe

```bash
# Importar namespace existente
terraform import kubernetes_namespace.api_produto api-produto

# Ou deletar e recriar
kubectl delete namespace api-produto
terraform apply
```

### Erro: Resource already exists

```bash
# Importar recurso
terraform import kubernetes_deployment.api_produto api-produto/api-produto

# Ver estado
terraform state list
```

### Limpar Estado

```bash
# Remover recurso do estado
terraform state rm kubernetes_deployment.api_produto

# Limpar estado completamente (cuidado!)
rm -rf .terraform terraform.tfstate*
terraform init
```

## 📚 Recursos Adicionais

- [Terraform Documentation](https://www.terraform.io/docs)
- [Kubernetes Provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)
- [Helm Provider](https://registry.terraform.io/providers/hashicorp/helm/latest/docs)
- [Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)

## 🔒 Segurança

### Checklist

- [ ] Não commitar `terraform.tfvars` com secrets
- [ ] Usar variáveis de ambiente para dados sensíveis
- [ ] Habilitar Network Policies
- [ ] Configurar RBAC adequadamente
- [ ] Usar secrets do Kubernetes
- [ ] Habilitar TLS/SSL no Ingress
- [ ] Revisar planos antes de aplicar
- [ ] Usar remote state (S3, GCS, etc)

### Remote State

```hcl
terraform {
  backend "s3" {
    bucket = "terraform-state-api-produto"
    key    = "kubernetes/terraform.tfstate"
    region = "us-east-1"
  }
}
```

## 🆘 Suporte

Para problemas:

1. Verificar logs: `terraform show`
2. Validar: `terraform validate`
3. Ver estado: `terraform state list`
4. Verificar K8s: `kubectl get all -n api-produto`
5. Ver eventos: `kubectl get events -n api-produto`
