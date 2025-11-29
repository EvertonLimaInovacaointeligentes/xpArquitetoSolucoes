# Arquitetura Kubernetes - API Produto

## 🏗️ Visão Geral

```
┌─────────────────────────────────────────────────────────────────┐
│                         INTERNET                                │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                      INGRESS CONTROLLER                         │
│  • NGINX Ingress                                                │
│  • SSL/TLS Termination                                          │
│  • Rate Limiting                                                │
│  • Path-based Routing                                           │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    KUBERNETES SERVICE                           │
│  • Type: LoadBalancer                                           │
│  • Port: 80 → 8080                                              │
│  • Session Affinity: ClientIP                                   │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                      DEPLOYMENT                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │   POD 1      │  │   POD 2      │  │   POD 3      │         │
│  │              │  │              │  │              │         │
│  │ api-produto  │  │ api-produto  │  │ api-produto  │         │
│  │   :8080      │  │   :8080      │  │   :8080      │         │
│  │              │  │              │  │              │         │
│  │ CPU: 100m    │  │ CPU: 100m    │  │ CPU: 100m    │         │
│  │ MEM: 128Mi   │  │ MEM: 128Mi   │  │ MEM: 128Mi   │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
│                                                                 │
│  • Replicas: 3 (min: 2, max: 10)                               │
│  • Rolling Update Strategy                                      │
│  • Health Checks (Liveness + Readiness)                        │
└─────────────────────────────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│              HORIZONTAL POD AUTOSCALER (HPA)                    │
│  • Min Replicas: 2                                              │
│  • Max Replicas: 10                                             │
│  • Target CPU: 70%                                              │
│  • Target Memory: 80%                                           │
└─────────────────────────────────────────────────────────────────┘
```

## 📦 Componentes

### 1. Namespace
```yaml
Name: api-produto
Labels:
  - name: api-produto
  - environment: production
```

**Função:** Isola recursos da aplicação

---

### 2. Deployment
```yaml
Name: api-produto
Replicas: 3
Strategy: RollingUpdate
  MaxSurge: 1
  MaxUnavailable: 0
```

**Função:** Gerencia pods e garante disponibilidade

**Features:**
- ✅ Rolling updates sem downtime
- ✅ Self-healing (recria pods com falha)
- ✅ Declarativo (estado desejado)
- ✅ Versionamento (rollback fácil)

---

### 3. Pods
```yaml
Container: api-produto
Image: api_produto:latest
Port: 8080
Resources:
  Requests:
    CPU: 100m
    Memory: 128Mi
  Limits:
    CPU: 500m
    Memory: 512Mi
```

**Função:** Executa a aplicação

**Health Checks:**
- **Liveness Probe:** Verifica se app está viva (restart se falhar)
- **Readiness Probe:** Verifica se app está pronta (remove do service se falhar)

---

### 4. Service
```yaml
Name: api-produto-service
Type: LoadBalancer
Port: 80 → 8080
SessionAffinity: ClientIP
```

**Função:** Expõe pods e faz load balancing

**Features:**
- ✅ IP estável (mesmo com pods mudando)
- ✅ Load balancing automático
- ✅ Service discovery (DNS interno)
- ✅ Session affinity (sticky sessions)

---

### 5. Ingress
```yaml
Name: api-produto-ingress
Host: api-produto.example.com
Path: /
Backend: api-produto-service:80
```

**Função:** Roteamento HTTP/HTTPS externo

**Features:**
- ✅ SSL/TLS automático (cert-manager)
- ✅ Rate limiting
- ✅ Path-based routing
- ✅ Virtual hosting

---

### 6. HPA (Horizontal Pod Autoscaler)
```yaml
Name: api-produto-hpa
Min: 2 replicas
Max: 10 replicas
Targets:
  - CPU: 70%
  - Memory: 80%
```

**Função:** Auto-scaling baseado em métricas

**Comportamento:**
- **Scale Up:** Rápido (30s)
- **Scale Down:** Gradual (5min)

---

### 7. ConfigMap
```yaml
Name: api-produto-config
Data:
  PORT: "8080"
  ENVIRONMENT: "production"
  LOG_LEVEL: "info"
```

**Função:** Configurações não sensíveis

---

### 8. Secret
```yaml
Name: api-produto-secret
Type: Opaque
Data:
  DATABASE_URL: <base64>
  API_KEY: <base64>
```

**Função:** Dados sensíveis criptografados

---

### 9. PDB (Pod Disruption Budget)
```yaml
Name: api-produto-pdb
MinAvailable: 1
```

**Função:** Garante disponibilidade durante manutenção

**Protege contra:**
- ✅ Evictions voluntárias
- ✅ Atualizações de nodes
- ✅ Drain de nodes

---

### 10. Network Policy
```yaml
Name: api-produto-network-policy
Ingress:
  - From: ingress-nginx
  - From: api-produto pods
Egress:
  - To: DNS (53)
  - To: HTTPS (443)
```

**Função:** Controle de tráfego de rede

**Segurança:**
- ✅ Isolamento entre namespaces
- ✅ Whitelist de tráfego
- ✅ Princípio do menor privilégio

---

## 🔄 Fluxo de Requisição

```
1. Cliente → HTTPS → api-produto.example.com
                     │
2. DNS Resolution    │
                     ▼
3. Load Balancer → Ingress Controller (NGINX)
                     │
4. SSL Termination   │
                     ▼
5. Ingress → Service (api-produto-service)
                     │
6. Load Balancing    │
                     ▼
7. Service → Pod (api-produto)
                     │
8. Health Check      │
                     ▼
9. Pod → Application (Dart)
                     │
10. Response         │
                     ▼
11. Pod → Service → Ingress → Cliente
```

## 📊 Escalabilidade

### Vertical (Recursos por Pod)
```yaml
Requests:  CPU: 100m, Memory: 128Mi
Limits:    CPU: 500m, Memory: 512Mi
```

**Quando aumentar:**
- Pod usando >80% dos limites
- OOMKilled frequente
- CPU throttling

### Horizontal (Número de Pods)
```yaml
Min: 2 pods
Max: 10 pods
Auto-scale: CPU > 70% ou Memory > 80%
```

**Quando aumentar:**
- Tráfego crescente
- Latência aumentando
- HPA atingindo max replicas

## 🔐 Segurança

### 1. Network Policies
- ✅ Isolamento de rede
- ✅ Whitelist de tráfego
- ✅ Egress controlado

### 2. RBAC
- ✅ Service accounts
- ✅ Roles e permissions
- ✅ Least privilege

### 3. Secrets
- ✅ Dados criptografados
- ✅ Não commitados no Git
- ✅ Rotação de secrets

### 4. Pod Security
- ✅ Non-root user
- ✅ Read-only filesystem
- ✅ No privilege escalation

## 🎯 Alta Disponibilidade

### 1. Múltiplas Réplicas
```
3 pods distribuídos em diferentes nodes
```

### 2. Health Checks
```
Liveness: Restart pods com falha
Readiness: Remove pods não prontos do service
```

### 3. Rolling Updates
```
MaxSurge: 1 (cria novo antes de deletar antigo)
MaxUnavailable: 0 (sempre mantém pods disponíveis)
```

### 4. PDB
```
MinAvailable: 1 (sempre mantém pelo menos 1 pod)
```

### 5. Auto-scaling
```
HPA: Escala automaticamente baseado em carga
```

## 📈 Monitoramento

### Métricas Coletadas
- ✅ CPU usage
- ✅ Memory usage
- ✅ Network I/O
- ✅ Request rate
- ✅ Response time
- ✅ Error rate

### Ferramentas
- **Metrics Server:** Métricas básicas
- **Prometheus:** Métricas avançadas
- **Grafana:** Dashboards
- **Jaeger:** Distributed tracing

## 🔄 CI/CD Integration

```
┌──────────────┐
│   Git Push   │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   Jenkins    │
│   Pipeline   │
└──────┬───────┘
       │
       ├─► Build Docker Image
       ├─► Push to Registry
       ├─► Update K8s Deployment
       └─► Verify Health
              │
              ▼
       ┌──────────────┐
       │  Kubernetes  │
       │   Cluster    │
       └──────────────┘
```

## 🌍 Multi-Environment

### Development
```yaml
Namespace: api-produto-dev
Replicas: 1
Resources: Minimal
HPA: Disabled
```

### Staging
```yaml
Namespace: api-produto-staging
Replicas: 2
Resources: Medium
HPA: Enabled (2-5)
```

### Production
```yaml
Namespace: api-produto
Replicas: 3
Resources: Full
HPA: Enabled (2-10)
```

## 💡 Best Practices Implementadas

1. ✅ **Namespaces:** Isolamento de recursos
2. ✅ **Labels:** Organização e seleção
3. ✅ **Resource Limits:** Prevenção de resource starvation
4. ✅ **Health Checks:** Auto-healing
5. ✅ **Rolling Updates:** Zero downtime
6. ✅ **HPA:** Auto-scaling
7. ✅ **PDB:** Alta disponibilidade
8. ✅ **Network Policies:** Segurança de rede
9. ✅ **ConfigMaps/Secrets:** Separação de config
10. ✅ **Ingress:** Roteamento centralizado

## 📚 Referências

- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
- [Production Checklist](https://kubernetes.io/docs/setup/best-practices/)
- [Security Best Practices](https://kubernetes.io/docs/concepts/security/overview/)
