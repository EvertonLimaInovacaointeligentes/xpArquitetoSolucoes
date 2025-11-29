# Kubernetes - API Produto

Configuração completa de Kubernetes para deploy e gerenciamento da API Produto.

## 📁 Estrutura

```
k8s/
├── base/                      # Configurações base
│   └── kustomization.yaml
├── overlays/                  # Configurações por ambiente
│   ├── dev/
│   │   └── kustomization.yaml
│   ├── staging/
│   │   └── kustomization.yaml
│   └── production/
│       └── kustomization.yaml
├── namespace.yaml             # Namespace da aplicação
├── deployment.yaml            # Deployment com 3 réplicas
├── service.yaml               # Service LoadBalancer
├── configmap.yaml             # Configurações da aplicação
├── secret.yaml                # Secrets (senhas, tokens)
├── hpa.yaml                   # Horizontal Pod Autoscaler
├── ingress.yaml               # Ingress para acesso externo
├── pdb.yaml                   # Pod Disruption Budget
├── networkpolicy.yaml         # Políticas de rede
├── deploy.sh                  # Script de deploy (Linux/Mac)
├── deploy.bat                 # Script de deploy (Windows)
└── README.md                  # Este arquivo
```

## 🚀 Quick Start

### Pré-requisitos

1. **Kubernetes Cluster** (escolha um):
   - Minikube (local)
   - Docker Desktop (local)
   - GKE (Google Cloud)
   - EKS (AWS)
   - AKS (Azure)

2. **Ferramentas**:
   ```bash
   # kubectl
   kubectl version --client
   
   # kustomize (opcional, kubectl já inclui)
   kustomize version
   ```

### Deploy Rápido

```bash
# Linux/Mac
cd k8s
chmod +x deploy.sh
./deploy.sh dev

# Windows
cd k8s
deploy.bat dev
```

### Deploy Manual

```bash
# Desenvolvimento
kubectl apply -k overlays/dev/

# Staging
kubectl apply -k overlays/staging/

# Produção
kubectl apply -k overlays/production/
```

## 🏗️ Componentes

### 1. Namespace
Isola recursos da aplicação em um namespace dedicado.

```yaml
namespace: api-produto
```

### 2. Deployment
Gerencia 3 réplicas da aplicação com:
- Rolling updates
- Health checks (liveness/readiness)
- Resource limits
- Graceful shutdown

```bash
# Ver deployment
kubectl get deployment -n api-produto

# Escalar manualmente
kubectl scale deployment/api-produto --replicas=5 -n api-produto
```

### 3. Service
Expõe a aplicação via LoadBalancer:
- Porta 80 → 8080 (container)
- Session affinity
- Health checks

```bash
# Ver service
kubectl get svc -n api-produto

# Obter IP externo
kubectl get svc api-produto-service -n api-produto
```

### 4. ConfigMap
Configurações não sensíveis:
- PORT
- ENVIRONMENT
- LOG_LEVEL

```bash
# Ver configmap
kubectl get configmap -n api-produto

# Editar
kubectl edit configmap api-produto-config -n api-produto
```

### 5. Secret
Dados sensíveis (criptografados):
- Database URLs
- API Keys
- JWT Secrets

```bash
# Criar secret
kubectl create secret generic api-produto-secret \
  --from-literal=DATABASE_URL=postgresql://... \
  -n api-produto

# Ver secrets (valores ocultos)
kubectl get secrets -n api-produto
```

### 6. HPA (Horizontal Pod Autoscaler)
Auto-scaling baseado em:
- CPU: 70%
- Memória: 80%
- Min: 2 réplicas
- Max: 10 réplicas

```bash
# Ver HPA
kubectl get hpa -n api-produto

# Descrever
kubectl describe hpa api-produto-hpa -n api-produto
```

### 7. Ingress
Roteamento HTTP/HTTPS:
- SSL/TLS automático
- Rate limiting
- Path-based routing

```bash
# Ver ingress
kubectl get ingress -n api-produto

# Descrever
kubectl describe ingress api-produto-ingress -n api-produto
```

### 8. PDB (Pod Disruption Budget)
Garante disponibilidade durante:
- Atualizações do cluster
- Manutenção de nodes
- Evictions

```bash
# Ver PDB
kubectl get pdb -n api-produto
```

### 9. Network Policy
Controla tráfego de rede:
- Ingress: apenas de ingress-nginx
- Egress: DNS e HTTPS
- Isolamento entre namespaces

```bash
# Ver network policies
kubectl get networkpolicy -n api-produto
```

## 🌍 Ambientes

### Development (dev)
- 1 réplica
- Recursos mínimos
- Log level: debug
- Namespace: api-produto-dev

```bash
./deploy.sh dev
```

### Staging
- 2 réplicas
- Recursos médios
- Log level: info
- Namespace: api-produto-staging

```bash
./deploy.sh staging
```

### Production
- 3 réplicas (auto-scale até 10)
- Recursos completos
- Log level: warn
- Namespace: api-produto
- HPA habilitado

```bash
./deploy.sh production
```

## 📊 Monitoramento

### Ver Pods

```bash
# Listar pods
kubectl get pods -n api-produto

# Ver detalhes
kubectl describe pod <pod-name> -n api-produto

# Ver logs
kubectl logs -f <pod-name> -n api-produto

# Ver logs de todos os pods
kubectl logs -f -l app=api-produto -n api-produto
```

### Métricas

```bash
# Uso de recursos
kubectl top pods -n api-produto
kubectl top nodes

# Status do HPA
kubectl get hpa -n api-produto --watch
```

### Events

```bash
# Ver eventos do namespace
kubectl get events -n api-produto --sort-by='.lastTimestamp'
```

## 🔧 Operações Comuns

### Atualizar Imagem

```bash
# Atualizar para nova versão
kubectl set image deployment/api-produto \
  api-produto=api_produto:v2.0.0 \
  -n api-produto

# Verificar rollout
kubectl rollout status deployment/api-produto -n api-produto
```

### Rollback

```bash
# Ver histórico
kubectl rollout history deployment/api-produto -n api-produto

# Rollback para versão anterior
kubectl rollout undo deployment/api-produto -n api-produto

# Rollback para versão específica
kubectl rollout undo deployment/api-produto --to-revision=2 -n api-produto
```

### Escalar

```bash
# Escalar manualmente
kubectl scale deployment/api-produto --replicas=5 -n api-produto

# Desabilitar HPA temporariamente
kubectl delete hpa api-produto-hpa -n api-produto
```

### Restart

```bash
# Restart sem downtime
kubectl rollout restart deployment/api-produto -n api-produto
```

### Debug

```bash
# Executar shell em pod
kubectl exec -it <pod-name> -n api-produto -- /bin/sh

# Port forward para teste local
kubectl port-forward svc/api-produto-service 8080:80 -n api-produto

# Ver configuração completa
kubectl get deployment api-produto -n api-produto -o yaml
```

## 🔐 Segurança

### Secrets Management

```bash
# Criar secret de arquivo
kubectl create secret generic api-produto-secret \
  --from-file=./secrets.env \
  -n api-produto

# Criar secret de literal
kubectl create secret generic api-produto-secret \
  --from-literal=API_KEY=abc123 \
  -n api-produto

# Ver secret (base64)
kubectl get secret api-produto-secret -n api-produto -o yaml

# Decodificar secret
kubectl get secret api-produto-secret -n api-produto -o jsonpath='{.data.API_KEY}' | base64 -d
```

### RBAC (Role-Based Access Control)

```bash
# Criar service account
kubectl create serviceaccount api-produto-sa -n api-produto

# Criar role
kubectl create role api-produto-role \
  --verb=get,list,watch \
  --resource=pods,services \
  -n api-produto

# Bind role
kubectl create rolebinding api-produto-binding \
  --role=api-produto-role \
  --serviceaccount=api-produto:api-produto-sa \
  -n api-produto
```

## 🧪 Testes

### Health Check

```bash
# Testar liveness
kubectl exec <pod-name> -n api-produto -- curl -f http://localhost:8080/

# Testar readiness
kubectl get pods -n api-produto -o wide
```

### Load Test

```bash
# Instalar hey
go install github.com/rakyll/hey@latest

# Executar load test
hey -z 60s -c 50 http://<external-ip>/products
```

## 📦 Backup e Restore

### Backup

```bash
# Backup de todos os recursos
kubectl get all -n api-produto -o yaml > backup.yaml

# Backup de configmaps e secrets
kubectl get configmap,secret -n api-produto -o yaml > config-backup.yaml
```

### Restore

```bash
# Restore
kubectl apply -f backup.yaml
```

## 🚨 Troubleshooting

### Pod não inicia

```bash
# Ver eventos
kubectl describe pod <pod-name> -n api-produto

# Ver logs
kubectl logs <pod-name> -n api-produto

# Ver logs do container anterior (se crashou)
kubectl logs <pod-name> -n api-produto --previous
```

### Service não acessível

```bash
# Verificar endpoints
kubectl get endpoints -n api-produto

# Testar conectividade
kubectl run test-pod --image=busybox -it --rm -- wget -O- http://api-produto-service.api-produto.svc.cluster.local
```

### HPA não funciona

```bash
# Verificar metrics-server
kubectl get deployment metrics-server -n kube-system

# Ver métricas
kubectl top pods -n api-produto
```

### Problemas de rede

```bash
# Testar DNS
kubectl run test-pod --image=busybox -it --rm -- nslookup api-produto-service.api-produto.svc.cluster.local

# Ver network policies
kubectl describe networkpolicy -n api-produto
```

## 🔄 CI/CD Integration

### Jenkins Pipeline

Adicione ao Jenkinsfile:

```groovy
stage('Deploy to Kubernetes') {
    steps {
        sh '''
            kubectl set image deployment/api-produto \
              api-produto=api_produto:${BUILD_NUMBER} \
              -n api-produto
            kubectl rollout status deployment/api-produto -n api-produto
        '''
    }
}
```

### GitLab CI

```yaml
deploy:
  stage: deploy
  script:
    - kubectl apply -k k8s/overlays/production/
    - kubectl rollout status deployment/api-produto -n api-produto
```

## 📚 Recursos Adicionais

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Kustomize Documentation](https://kustomize.io/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)

## 🆘 Suporte

Para problemas ou dúvidas:
1. Verifique os logs: `kubectl logs -f -l app=api-produto -n api-produto`
2. Verifique eventos: `kubectl get events -n api-produto`
3. Descreva o recurso: `kubectl describe <resource> <name> -n api-produto`
