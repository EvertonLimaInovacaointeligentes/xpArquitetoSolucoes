# Opções de Deploy no Kubernetes

Este projeto oferece duas formas de deploy no Kubernetes: **Kustomize** e **Helm**.

## 📊 Comparação

| Característica | Kustomize | Helm |
|----------------|-----------|------|
| **Complexidade** | Simples | Moderada |
| **Curva de aprendizado** | Baixa | Média |
| **Templating** | Patches/Overlays | Go Templates |
| **Gerenciamento de versões** | Git | Helm Releases |
| **Rollback** | Manual | Automático |
| **Dependências** | Não suporta | Suporta |
| **Integrado ao kubectl** | ✅ Sim | ❌ Não (requer instalação) |
| **Recomendado para** | Projetos simples/médios | Projetos complexos |

## 🎯 Kustomize (Recomendado para este projeto)

### Vantagens
- ✅ Integrado nativamente ao kubectl
- ✅ Não requer instalação adicional
- ✅ Sintaxe YAML pura (sem templating)
- ✅ Fácil de entender e manter
- ✅ Overlays para múltiplos ambientes

### Estrutura
```
k8s/
├── base/                    # Configurações base
│   └── kustomization.yaml
└── overlays/                # Configurações por ambiente
    ├── dev/
    ├── staging/
    └── production/
```

### Deploy

```bash
# Desenvolvimento
kubectl apply -k k8s/overlays/dev/

# Staging
kubectl apply -k k8s/overlays/staging/

# Produção
kubectl apply -k k8s/overlays/production/
```

### Atualizar

```bash
# Editar configuração
vim k8s/overlays/production/kustomization.yaml

# Aplicar mudanças
kubectl apply -k k8s/overlays/production/
```

### Visualizar antes de aplicar

```bash
kubectl kustomize k8s/overlays/production/
```

---

## ⚙️ Helm

### Vantagens
- ✅ Templating poderoso
- ✅ Gerenciamento de releases
- ✅ Rollback fácil
- ✅ Suporte a dependências
- ✅ Repositórios de charts

### Estrutura
```
k8s/helm/
├── Chart.yaml              # Metadados do chart
├── values.yaml             # Valores padrão
└── templates/              # Templates Kubernetes
    ├── deployment.yaml
    ├── service.yaml
    └── _helpers.tpl
```

### Instalação do Helm

```bash
# Linux
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# macOS
brew install helm

# Windows
choco install kubernetes-helm
```

### Deploy

```bash
# Instalar/Atualizar
helm upgrade --install api-produto k8s/helm/ \
  --namespace api-produto \
  --create-namespace

# Com valores customizados
helm upgrade --install api-produto k8s/helm/ \
  --namespace api-produto \
  --values k8s/helm/values-production.yaml
```

### Gerenciar Releases

```bash
# Listar releases
helm list -n api-produto

# Ver histórico
helm history api-produto -n api-produto

# Rollback
helm rollback api-produto 1 -n api-produto

# Desinstalar
helm uninstall api-produto -n api-produto
```

### Visualizar antes de aplicar

```bash
helm template api-produto k8s/helm/
```

---

## 🚀 Qual usar?

### Use **Kustomize** se:
- ✅ Projeto simples ou médio
- ✅ Quer simplicidade
- ✅ Não precisa de templating complexo
- ✅ Prefere YAML puro
- ✅ Não quer instalar ferramentas extras

### Use **Helm** se:
- ✅ Projeto complexo
- ✅ Precisa de templating avançado
- ✅ Quer gerenciamento de releases
- ✅ Precisa de rollback fácil
- ✅ Tem dependências entre charts
- ✅ Quer compartilhar charts

---

## 📝 Exemplos Práticos

### Kustomize: Alterar número de réplicas

```yaml
# k8s/overlays/production/kustomization.yaml
replicas:
- name: api-produto
  count: 5
```

```bash
kubectl apply -k k8s/overlays/production/
```

### Helm: Alterar número de réplicas

```yaml
# k8s/helm/values-production.yaml
replicaCount: 5
```

```bash
helm upgrade api-produto k8s/helm/ \
  --values k8s/helm/values-production.yaml
```

---

## 🔄 Migração entre Kustomize e Helm

### De Kustomize para Helm

1. Criar Chart.yaml
2. Mover YAMLs para templates/
3. Adicionar templating com {{ .Values.* }}
4. Criar values.yaml
5. Testar com `helm template`

### De Helm para Kustomize

1. Gerar YAMLs: `helm template > base.yaml`
2. Separar recursos em arquivos individuais
3. Criar kustomization.yaml
4. Criar overlays para ambientes
5. Testar com `kubectl kustomize`

---

## 🎓 Recursos de Aprendizado

### Kustomize
- [Documentação Oficial](https://kustomize.io/)
- [Kubernetes Kustomize](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/)
- [Kustomize Examples](https://github.com/kubernetes-sigs/kustomize/tree/master/examples)

### Helm
- [Documentação Oficial](https://helm.sh/docs/)
- [Helm Hub](https://artifacthub.io/)
- [Best Practices](https://helm.sh/docs/chart_best_practices/)

---

## 💡 Recomendação Final

Para este projeto (API Produto), **recomendamos Kustomize** porque:

1. ✅ Projeto de complexidade média
2. ✅ Não requer templating complexo
3. ✅ Integrado ao kubectl (sem instalação extra)
4. ✅ Mais fácil de entender para iniciantes
5. ✅ Suficiente para gerenciar múltiplos ambientes

Se o projeto crescer e precisar de features mais avançadas, você pode migrar para Helm facilmente.

---

## 🔧 Scripts Auxiliares

### Script para testar ambos

```bash
#!/bin/bash

echo "Testando Kustomize..."
kubectl kustomize k8s/overlays/production/ > /tmp/kustomize-output.yaml
echo "✓ Kustomize OK"

echo "Testando Helm..."
helm template api-produto k8s/helm/ > /tmp/helm-output.yaml
echo "✓ Helm OK"

echo "Comparando outputs..."
diff /tmp/kustomize-output.yaml /tmp/helm-output.yaml
```

### Script para deploy com escolha

```bash
#!/bin/bash

read -p "Usar Kustomize (k) ou Helm (h)? " choice

case $choice in
  k|K)
    echo "Deploying com Kustomize..."
    kubectl apply -k k8s/overlays/production/
    ;;
  h|H)
    echo "Deploying com Helm..."
    helm upgrade --install api-produto k8s/helm/ --namespace api-produto
    ;;
  *)
    echo "Opção inválida"
    exit 1
    ;;
esac
```
