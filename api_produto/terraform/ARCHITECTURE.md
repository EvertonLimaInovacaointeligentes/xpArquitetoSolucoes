# Arquitetura Terraform + Kubernetes

## 🏗️ Visão Geral

```
┌─────────────────────────────────────────────────────────────────┐
│                      TERRAFORM                                  │
│  Infrastructure as Code (IaC)                                   │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ terraform apply
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                  KUBERNETES CLUSTER                             │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                    NAMESPACE                              │ │
│  │  api-produto / api-produto-dev / api-produto-staging     │ │
│  └───────────────────────────────────────────────────────────┘ │
│                             │                                   │
│  ┌──────────────────────────┴──────────────────────────┐       │
│  │                                                      │       │
│  ▼                                                      ▼       │
│  ┌─────────────────┐                        ┌─────────────────┐│
│  │   ConfigMap     │                        │     Secret      ││
│  │                 │                        │                 ││
│  │ • PORT          │                        │ • DATABASE_URL  ││
│  │ • ENVIRONMENT   │                        │ • API_KEY       ││
│  │ • LOG_LEVEL     │                        │ (encrypted)     ││
│  └─────────────────┘                        └─────────────────┘│
│           │                                          │          │
│           └──────────────┬───────────────────────────┘          │
│                          ▼                                      │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                    DEPLOYMENT                             │ │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐               │ │
│  │  │  POD 1   │  │  POD 2   │  │  POD 3   │               │ │
│  │  │          │  │          │  │          │               │ │
│  │  │ api-     │  │ api-     │  │ api-     │               │ │
│  │  │ produto  │  │ produto  │  │ produto  │               │ │
│  │  │ :8080    │  │ :8080    │  │ :8080    │               │ │
│  │  └──────────┘  └──────────┘  └──────────┘               │ │
│  │                                                           │ │
│  │  • Replicas: 3                                           │ │
│  │  • Rolling Update                                        │ │
│  │  • Health Checks                                         │ │
│  └───────────────────────────────────────────────────────────┘ │
│                          │                                      │
│                          ▼                                      │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                       SERVICE                             │ │
│  │  • Type: LoadBalancer                                     │ │
│  │  • Port: 80 → 8080                                        │ │
│  │  • Session Affinity                                       │ │
│  └───────────────────────────────────────────────────────────┘ │
│                          │                                      │
│           ┌──────────────┼──────────────┐                      │
│           │              │              │                      │
│           ▼              ▼              ▼                      │
│  ┌─────────────┐  ┌──────────┐  ┌─────────────────┐          │
│  │     HPA     │  │ Ingress  │  │ Network Policy  │          │
│  │             │  │          │  │                 │          │
│  │ Min: 2      │  │ SSL/TLS  │  │ Firewall Rules  │          │
│  │ Max: 10     │  │ Routing  │  │ Isolation       │          │
│  │ CPU: 70%    │  │          │  │                 │          │
│  └─────────────┘  └──────────┘  └─────────────────┘          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## 📦 Recursos Terraform

### 1. Providers

```hcl
provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}
```

**Função:** Conectar Terraform aos serviços

---

### 2. Namespace

```hcl
resource "kubernetes_namespace" "api_produto" {
  metadata {
    name = var.namespace
    labels = {
      environment = var.environment
      managed-by  = "terraform"
    }
  }
}
```

**Função:** Isolar recursos por ambiente

**Ambientes:**
- `api-produto-dev` (desenvolvimento)
- `api-produto-staging` (staging)
- `api-produto` (produção)

---

### 3. ConfigMap

```hcl
resource "kubernetes_config_map" "api_produto" {
  metadata {
    name      = "api-produto-config"
    namespace = kubernetes_namespace.api_produto.metadata[0].name
  }
  
  data = {
    PORT        = var.app_port
    ENVIRONMENT = var.environment
    LOG_LEVEL   = var.log_level
  }
}
```

**Função:** Configurações não sensíveis

**Vantagens:**
- ✅ Versionado no Git
- ✅ Fácil de atualizar
- ✅ Separação de config e código

---

### 4. Secret

```hcl
resource "kubernetes_secret" "api_produto" {
  metadata {
    name      = "api-produto-secret"
    namespace = kubernetes_namespace.api_produto.metadata[0].name
  }
  
  type = "Opaque"
  
  data = {
    DATABASE_URL = base64encode(var.database_url)
    API_KEY      = base64encode(var.api_key)
  }
}
```

**Função:** Dados sensíveis criptografados

**Segurança:**
- ✅ Criptografado no etcd
- ✅ Não commitado no Git
- ✅ Variáveis sensíveis

---

### 5. Deployment

```hcl
resource "kubernetes_deployment" "api_produto" {
  metadata {
    name      = "api-produto"
    namespace = kubernetes_namespace.api_produto.metadata[0].name
  }
  
  spec {
    replicas = var.replicas
    
    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_surge       = "1"
        max_unavailable = "0"
      }
    }
    
    template {
      spec {
        container {
          name  = "api-produto"
          image = "${var.docker_image}:${var.docker_tag}"
          
          resources {
            requests = {
              cpu    = var.resources_requests_cpu
              memory = var.resources_requests_memory
            }
            limits = {
              cpu    = var.resources_limits_cpu
              memory = var.resources_limits_memory
            }
          }
          
          liveness_probe { ... }
          readiness_probe { ... }
        }
      }
    }
  }
}
```

**Função:** Gerenciar pods da aplicação

**Features:**
- ✅ Rolling updates
- ✅ Health checks
- ✅ Resource limits
- ✅ Auto-restart

---

### 6. Service

```hcl
resource "kubernetes_service" "api_produto" {
  metadata {
    name      = "api-produto-service"
    namespace = kubernetes_namespace.api_produto.metadata[0].name
  }
  
  spec {
    type = var.service_type
    
    selector = {
      app = "api-produto"
    }
    
    port {
      port        = 80
      target_port = var.app_port
    }
  }
}
```

**Função:** Expor aplicação

**Tipos:**
- `ClusterIP` - Interno apenas
- `NodePort` - Acesso via node IP
- `LoadBalancer` - IP externo

---

### 7. HPA (Horizontal Pod Autoscaler)

```hcl
resource "kubernetes_horizontal_pod_autoscaler_v2" "api_produto" {
  metadata {
    name      = "api-produto-hpa"
    namespace = kubernetes_namespace.api_produto.metadata[0].name
  }
  
  spec {
    min_replicas = var.hpa_min_replicas
    max_replicas = var.hpa_max_replicas
    
    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = var.hpa_cpu_target
        }
      }
    }
  }
}
```

**Função:** Auto-scaling baseado em métricas

**Comportamento:**
- Scale Up: Rápido (30s)
- Scale Down: Gradual (5min)

---

### 8. Ingress

```hcl
resource "kubernetes_ingress_v1" "api_produto" {
  metadata {
    name      = "api-produto-ingress"
    namespace = kubernetes_namespace.api_produto.metadata[0].name
    
    annotations = {
      "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
      "cert-manager.io/cluster-issuer"           = "letsencrypt-prod"
    }
  }
  
  spec {
    tls {
      hosts       = [var.ingress_host]
      secret_name = "api-produto-tls"
    }
    
    rule {
      host = var.ingress_host
      http {
        path {
          path = "/"
          backend {
            service {
              name = kubernetes_service.api_produto.metadata[0].name
              port { number = 80 }
            }
          }
        }
      }
    }
  }
}
```

**Função:** Roteamento HTTP/HTTPS

**Features:**
- ✅ SSL/TLS automático
- ✅ Virtual hosting
- ✅ Path-based routing

---

### 9. Network Policy

```hcl
resource "kubernetes_network_policy" "api_produto" {
  metadata {
    name      = "api-produto-network-policy"
    namespace = kubernetes_namespace.api_produto.metadata[0].name
  }
  
  spec {
    pod_selector {
      match_labels = { app = "api-produto" }
    }
    
    policy_types = ["Ingress", "Egress"]
    
    ingress { ... }
    egress { ... }
  }
}
```

**Função:** Firewall de rede

**Segurança:**
- ✅ Whitelist de tráfego
- ✅ Isolamento entre namespaces
- ✅ Controle de egress

---

### 10. Pod Disruption Budget

```hcl
resource "kubernetes_pod_disruption_budget_v1" "api_produto" {
  metadata {
    name      = "api-produto-pdb"
    namespace = kubernetes_namespace.api_produto.metadata[0].name
  }
  
  spec {
    min_available = "1"
    
    selector {
      match_labels = { app = "api-produto" }
    }
  }
}
```

**Função:** Garantir disponibilidade

**Protege contra:**
- ✅ Evictions voluntárias
- ✅ Node drains
- ✅ Cluster upgrades

---

## 🔄 Fluxo de Deploy

```
1. Desenvolvedor
   │
   ├─► Edita código
   ├─► Commita no Git
   └─► Push para repositório
       │
       ▼
2. CI/CD (Jenkins)
   │
   ├─► Build Docker image
   ├─► Push para registry
   └─► Trigger Terraform
       │
       ▼
3. Terraform
   │
   ├─► terraform plan
   ├─► terraform apply
   └─► Atualiza Kubernetes
       │
       ▼
4. Kubernetes
   │
   ├─► Rolling update
   ├─► Health checks
   └─► Pods atualizados
       │
       ▼
5. Aplicação
   │
   └─► Rodando nova versão
```

## 📊 Variáveis por Ambiente

### Development

```hcl
namespace   = "api-produto-dev"
environment = "development"
replicas    = 1
enable_hpa  = false
service_type = "NodePort"

resources_requests_cpu = "50m"
resources_limits_cpu   = "200m"
```

### Staging

```hcl
namespace   = "api-produto-staging"
environment = "staging"
replicas    = 2
enable_hpa  = true
hpa_min_replicas = 2
hpa_max_replicas = 5
service_type = "LoadBalancer"

resources_requests_cpu = "100m"
resources_limits_cpu   = "400m"
```

### Production

```hcl
namespace   = "api-produto"
environment = "production"
replicas    = 3
enable_hpa  = true
hpa_min_replicas = 2
hpa_max_replicas = 10
service_type = "LoadBalancer"

resources_requests_cpu = "100m"
resources_limits_cpu   = "500m"
```

## 🎯 Dependências

```
Namespace
    │
    ├─► ConfigMap
    ├─► Secret
    │
    └─► Deployment
            │
            ├─► Service
            │       │
            │       └─► Ingress
            │
            ├─► HPA
            ├─► PDB
            └─► Network Policy
```

## 💡 Vantagens do Terraform

### 1. Infraestrutura como Código
- ✅ Versionado no Git
- ✅ Code review
- ✅ Histórico de mudanças

### 2. Declarativo
- ✅ Define estado desejado
- ✅ Terraform calcula mudanças
- ✅ Idempotente

### 3. Plan antes de Apply
- ✅ Preview de mudanças
- ✅ Evita surpresas
- ✅ Segurança

### 4. State Management
- ✅ Rastreia recursos
- ✅ Detecta drift
- ✅ Rollback fácil

### 5. Multi-Cloud
- ✅ AWS, GCP, Azure
- ✅ Kubernetes
- ✅ Docker

## 🔐 Segurança

### Secrets Management

```bash
# Variáveis de ambiente
export TF_VAR_database_url="postgresql://..."
export TF_VAR_api_key="secret"

# Terraform apply
terraform apply -var-file=environments/production.tfvars
```

### Remote State

```hcl
terraform {
  backend "s3" {
    bucket = "terraform-state"
    key    = "api-produto/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}
```

### State Locking

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state"
    key            = "api-produto/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
  }
}
```

## 📈 Monitoramento

### Outputs Úteis

```hcl
output "deployment_summary" {
  value = {
    namespace    = kubernetes_namespace.api_produto.metadata[0].name
    replicas     = kubernetes_deployment.api_produto.spec[0].replicas
    service_type = kubernetes_service.api_produto.spec[0].type
    ingress_url  = "https://${var.ingress_host}"
  }
}
```

### Comandos kubectl

```bash
# Ver recursos criados
terraform output kubectl_commands

# Executar comando
$(terraform output -raw kubectl_commands | jq -r '.get_pods')
```

## 🚀 Best Practices

1. ✅ **Usar workspaces** para ambientes
2. ✅ **Remote state** para colaboração
3. ✅ **State locking** para evitar conflitos
4. ✅ **Variáveis sensíveis** via env vars
5. ✅ **Módulos** para reutilização
6. ✅ **Validação** antes de apply
7. ✅ **Backup** do state
8. ✅ **Documentação** de mudanças

## 📚 Referências

- [Terraform Kubernetes Provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
