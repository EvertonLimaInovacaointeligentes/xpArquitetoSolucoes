# Kubernetes Cheat Sheet - API Produto

Comandos úteis para gerenciar a aplicação no Kubernetes.

## 🚀 Deploy

```bash
# Deploy com Kustomize
kubectl apply -k k8s/overlays/production/

# Deploy com Helm
helm upgrade --install api-produto k8s/helm/ -n api-produto

# Deploy com script
cd k8s && ./deploy.sh production
```

## 📦 Pods

```bash
# Listar pods
kubectl get pods -n api-produto

# Listar com mais detalhes
kubectl get pods -n api-produto -o wide

# Ver detalhes de um pod
kubectl describe pod <pod-name> -n api-produto

# Ver logs
kubectl logs <pod-name> -n api-produto

# Ver logs em tempo real
kubectl logs -f <pod-name> -n api-produto

# Ver logs de todos os pods
kubectl logs -f -l app=api-produto -n api-produto

# Ver logs do container anterior (se crashou)
kubectl logs <pod-name> -n api-produto --previous

# Executar comando em pod
kubectl exec -it <pod-name> -n api-produto -- /bin/sh

# Copiar arquivo para pod
kubectl cp local-file.txt <pod-name>:/tmp/file.txt -n api-produto

# Copiar arquivo de pod
kubectl cp <pod-name>:/tmp/file.txt local-file.txt -n api-produto
```

## 🔄 Deployments

```bash
# Listar deployments
kubectl get deployments -n api-produto

# Ver detalhes
kubectl describe deployment api-produto -n api-produto

# Escalar
kubectl scale deployment api-produto --replicas=5 -n api-produto

# Atualizar imagem
kubectl set image deployment/api-produto \
  api-produto=api_produto:v2.0.0 \
  -n api-produto

# Ver status do rollout
kubectl rollout status deployment/api-produto -n api-produto

# Ver histórico
kubectl rollout history deployment/api-produto -n api-produto

# Rollback
kubectl rollout undo deployment/api-produto -n api-produto

# Rollback para revisão específica
kubectl rollout undo deployment/api-produto --to-revision=2 -n api-produto

# Pausar rollout
kubectl rollout pause deployment/api-produto -n api-produto

# Retomar rollout
kubectl rollout resume deployment/api-produto -n api-produto

# Restart (sem downtime)
kubectl rollout restart deployment/api-produto -n api-produto

# Editar deployment
kubectl edit deployment api-produto -n api-produto
```

## 🌐 Services

```bash
# Listar services
kubectl get svc -n api-produto

# Ver detalhes
kubectl describe svc api-produto-service -n api-produto

# Ver endpoints
kubectl get endpoints -n api-produto

# Port forward para teste local
kubectl port-forward svc/api-produto-service 8080:80 -n api-produto

# Testar service internamente
kubectl run test-pod --image=busybox -it --rm -- \
  wget -O- http://api-produto-service.api-produto.svc.cluster.local
```

## 📊 Monitoramento

```bash
# Ver uso de recursos dos pods
kubectl top pods -n api-produto

# Ver uso de recursos dos nodes
kubectl top nodes

# Ver eventos
kubectl get events -n api-produto

# Ver eventos ordenados por tempo
kubectl get events -n api-produto --sort-by='.lastTimestamp'

# Ver eventos de um pod específico
kubectl get events -n api-produto --field-selector involvedObject.name=<pod-name>

# Ver métricas do HPA
kubectl get hpa -n api-produto

# Ver detalhes do HPA
kubectl describe hpa api-produto-hpa -n api-produto

# Watch HPA
kubectl get hpa -n api-produto --watch
```

## 🔧 ConfigMaps e Secrets

```bash
# Listar ConfigMaps
kubectl get configmap -n api-produto

# Ver ConfigMap
kubectl get configmap api-produto-config -n api-produto -o yaml

# Editar ConfigMap
kubectl edit configmap api-produto-config -n api-produto

# Criar ConfigMap de arquivo
kubectl create configmap api-produto-config \
  --from-file=config.yaml \
  -n api-produto

# Criar ConfigMap de literal
kubectl create configmap api-produto-config \
  --from-literal=PORT=8080 \
  --from-literal=ENV=production \
  -n api-produto

# Listar Secrets
kubectl get secrets -n api-produto

# Ver Secret (valores em base64)
kubectl get secret api-produto-secret -n api-produto -o yaml

# Decodificar Secret
kubectl get secret api-produto-secret -n api-produto \
  -o jsonpath='{.data.API_KEY}' | base64 -d

# Criar Secret
kubectl create secret generic api-produto-secret \
  --from-literal=API_KEY=abc123 \
  --from-literal=DB_PASSWORD=secret \
  -n api-produto

# Criar Secret de arquivo
kubectl create secret generic api-produto-secret \
  --from-file=./secrets.env \
  -n api-produto
```

## 🔍 Debug

```bash
# Ver todos os recursos
kubectl get all -n api-produto

# Ver recursos com labels
kubectl get all -l app=api-produto -n api-produto

# Descrever todos os recursos
kubectl describe all -n api-produto

# Ver YAML de um recurso
kubectl get deployment api-produto -n api-produto -o yaml

# Ver JSON de um recurso
kubectl get deployment api-produto -n api-produto -o json

# Ver apenas campos específicos
kubectl get pods -n api-produto -o custom-columns=NAME:.metadata.name,STATUS:.status.phase

# Ver com JSONPath
kubectl get pods -n api-produto -o jsonpath='{.items[*].metadata.name}'

# Verificar conectividade
kubectl run test-pod --image=busybox -it --rm -- ping api-produto-service.api-produto.svc.cluster.local

# Verificar DNS
kubectl run test-pod --image=busybox -it --rm -- nslookup api-produto-service.api-produto.svc.cluster.local

# Verificar porta
kubectl run test-pod --image=busybox -it --rm -- telnet api-produto-service.api-produto.svc.cluster.local 80
```

## 🗑️ Limpeza

```bash
# Deletar pod (será recriado pelo deployment)
kubectl delete pod <pod-name> -n api-produto

# Deletar deployment
kubectl delete deployment api-produto -n api-produto

# Deletar service
kubectl delete svc api-produto-service -n api-produto

# Deletar tudo com label
kubectl delete all -l app=api-produto -n api-produto

# Deletar namespace (cuidado!)
kubectl delete namespace api-produto

# Deletar com Kustomize
kubectl delete -k k8s/overlays/production/

# Deletar com Helm
helm uninstall api-produto -n api-produto

# Forçar deleção de pod travado
kubectl delete pod <pod-name> -n api-produto --force --grace-period=0
```

## 📝 Namespaces

```bash
# Listar namespaces
kubectl get namespaces

# Criar namespace
kubectl create namespace api-produto

# Deletar namespace
kubectl delete namespace api-produto

# Definir namespace padrão
kubectl config set-context --current --namespace=api-produto

# Ver namespace atual
kubectl config view --minify | grep namespace:
```

## 🔐 RBAC

```bash
# Listar service accounts
kubectl get serviceaccounts -n api-produto

# Criar service account
kubectl create serviceaccount api-produto-sa -n api-produto

# Listar roles
kubectl get roles -n api-produto

# Listar role bindings
kubectl get rolebindings -n api-produto

# Ver permissões de um service account
kubectl auth can-i --list --as=system:serviceaccount:api-produto:api-produto-sa
```

## 🌐 Ingress

```bash
# Listar ingress
kubectl get ingress -n api-produto

# Ver detalhes
kubectl describe ingress api-produto-ingress -n api-produto

# Ver logs do ingress controller
kubectl logs -f -n ingress-nginx -l app.kubernetes.io/component=controller
```

## 📦 Backup e Restore

```bash
# Backup de todos os recursos
kubectl get all -n api-produto -o yaml > backup.yaml

# Backup de recursos específicos
kubectl get deployment,service,configmap,secret -n api-produto -o yaml > backup.yaml

# Restore
kubectl apply -f backup.yaml

# Backup com Velero (se instalado)
velero backup create api-produto-backup --include-namespaces api-produto
```

## 🔄 Contextos e Clusters

```bash
# Listar contextos
kubectl config get-contexts

# Ver contexto atual
kubectl config current-context

# Mudar contexto
kubectl config use-context <context-name>

# Ver configuração
kubectl config view

# Ver informações do cluster
kubectl cluster-info

# Ver nodes
kubectl get nodes

# Ver detalhes de um node
kubectl describe node <node-name>
```

## 🎯 Seletores e Labels

```bash
# Listar com labels
kubectl get pods -n api-produto --show-labels

# Filtrar por label
kubectl get pods -n api-produto -l app=api-produto

# Filtrar por múltiplas labels
kubectl get pods -n api-produto -l app=api-produto,version=v1

# Adicionar label
kubectl label pod <pod-name> environment=production -n api-produto

# Remover label
kubectl label pod <pod-name> environment- -n api-produto

# Atualizar label
kubectl label pod <pod-name> environment=staging --overwrite -n api-produto
```

## 📊 Recursos e Limites

```bash
# Ver recursos alocados
kubectl describe nodes | grep -A 5 "Allocated resources"

# Ver limites de um pod
kubectl get pod <pod-name> -n api-produto -o jsonpath='{.spec.containers[*].resources}'

# Ver uso real vs limites
kubectl top pod <pod-name> -n api-produto
```

## 🚨 Troubleshooting Rápido

```bash
# Pod não inicia
kubectl describe pod <pod-name> -n api-produto
kubectl logs <pod-name> -n api-produto

# Service não responde
kubectl get endpoints -n api-produto
kubectl describe svc api-produto-service -n api-produto

# HPA não funciona
kubectl get hpa -n api-produto
kubectl top pods -n api-produto
kubectl get deployment metrics-server -n kube-system

# Imagem não baixa
kubectl describe pod <pod-name> -n api-produto | grep -A 5 "Events"

# Pod em CrashLoopBackOff
kubectl logs <pod-name> -n api-produto --previous
kubectl describe pod <pod-name> -n api-produto

# Problemas de rede
kubectl get networkpolicy -n api-produto
kubectl describe networkpolicy -n api-produto
```

## 🔧 Comandos Úteis Combinados

```bash
# Ver pods com problemas
kubectl get pods -n api-produto --field-selector=status.phase!=Running

# Deletar pods com erro
kubectl delete pods -n api-produto --field-selector=status.phase=Failed

# Ver logs de todos os pods com erro
kubectl get pods -n api-produto --field-selector=status.phase=Failed -o name | \
  xargs -I {} kubectl logs {} -n api-produto

# Restart de todos os deployments
kubectl get deployments -n api-produto -o name | \
  xargs -I {} kubectl rollout restart {} -n api-produto

# Ver uso de recursos de todos os namespaces
kubectl top pods --all-namespaces

# Listar imagens de todos os pods
kubectl get pods -n api-produto -o jsonpath='{.items[*].spec.containers[*].image}'
```

## 📚 Aliases Úteis

Adicione ao seu `.bashrc` ou `.zshrc`:

```bash
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgd='kubectl get deployments'
alias kga='kubectl get all'
alias kd='kubectl describe'
alias kl='kubectl logs -f'
alias ke='kubectl exec -it'
alias kn='kubectl config set-context --current --namespace'
alias kctx='kubectl config use-context'
```

## 🎓 Recursos

- [Kubectl Cheat Sheet Oficial](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [kubectl Reference](https://kubernetes.io/docs/reference/kubectl/)
