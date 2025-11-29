#!/bin/bash

# Script de deploy para Kubernetes
# Uso: ./deploy.sh [dev|staging|production]

set -e

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Ambiente padrão
ENVIRONMENT=${1:-dev}

echo -e "${BLUE}=========================================="
echo "  Deploy Kubernetes - API Produto"
echo "==========================================${NC}"
echo ""

# Validar ambiente
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|production)$ ]]; then
    echo -e "${RED}Erro: Ambiente inválido!${NC}"
    echo "Uso: ./deploy.sh [dev|staging|production]"
    exit 1
fi

echo -e "${YELLOW}Ambiente: ${ENVIRONMENT}${NC}"
echo ""

# Verificar se kubectl está instalado
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}kubectl não está instalado!${NC}"
    exit 1
fi

# Verificar se kustomize está instalado
if ! command -v kustomize &> /dev/null; then
    echo -e "${YELLOW}kustomize não encontrado, usando kubectl apply -k${NC}"
    KUSTOMIZE_CMD="kubectl apply -k"
else
    KUSTOMIZE_CMD="kustomize build | kubectl apply -f -"
fi

# Verificar conexão com cluster
echo -e "${YELLOW}Verificando conexão com cluster...${NC}"
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}Não foi possível conectar ao cluster Kubernetes!${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Conectado ao cluster${NC}"
echo ""

# Criar namespace se não existir
NAMESPACE="api-produto"
if [ "$ENVIRONMENT" != "production" ]; then
    NAMESPACE="api-produto-${ENVIRONMENT}"
fi

echo -e "${YELLOW}Criando namespace ${NAMESPACE}...${NC}"
kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -
echo -e "${GREEN}✓ Namespace criado/atualizado${NC}"
echo ""

# Deploy usando Kustomize
echo -e "${YELLOW}Aplicando manifests do Kubernetes...${NC}"
kubectl apply -k overlays/${ENVIRONMENT}/
echo -e "${GREEN}✓ Manifests aplicados${NC}"
echo ""

# Aguardar rollout
echo -e "${YELLOW}Aguardando rollout do deployment...${NC}"
kubectl rollout status deployment/api-produto -n ${NAMESPACE} --timeout=5m
echo -e "${GREEN}✓ Rollout concluído${NC}"
echo ""

# Verificar pods
echo -e "${YELLOW}Verificando status dos pods...${NC}"
kubectl get pods -n ${NAMESPACE} -l app=api-produto
echo ""

# Verificar services
echo -e "${YELLOW}Verificando services...${NC}"
kubectl get svc -n ${NAMESPACE}
echo ""

# Obter URL do serviço
if [ "$ENVIRONMENT" == "production" ]; then
    echo -e "${YELLOW}Obtendo URL do serviço...${NC}"
    EXTERNAL_IP=$(kubectl get svc api-produto-service -n ${NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "pending")
    
    if [ "$EXTERNAL_IP" != "pending" ] && [ -n "$EXTERNAL_IP" ]; then
        echo -e "${GREEN}URL: http://${EXTERNAL_IP}${NC}"
        echo -e "${GREEN}Swagger: http://${EXTERNAL_IP}/swagger/${NC}"
    else
        echo -e "${YELLOW}IP externo ainda não disponível. Execute:${NC}"
        echo "kubectl get svc api-produto-service -n ${NAMESPACE} --watch"
    fi
fi

echo ""
echo -e "${GREEN}=========================================="
echo "  Deploy concluído com sucesso!"
echo "==========================================${NC}"
echo ""
echo "Comandos úteis:"
echo "  Ver pods:        kubectl get pods -n ${NAMESPACE}"
echo "  Ver logs:        kubectl logs -f -l app=api-produto -n ${NAMESPACE}"
echo "  Ver services:    kubectl get svc -n ${NAMESPACE}"
echo "  Escalar:         kubectl scale deployment/api-produto --replicas=5 -n ${NAMESPACE}"
echo "  Deletar:         kubectl delete -k overlays/${ENVIRONMENT}/"
echo ""
