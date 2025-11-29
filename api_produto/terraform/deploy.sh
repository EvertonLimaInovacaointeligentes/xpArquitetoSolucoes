#!/bin/bash

# Script de deploy com Terraform
# Uso: ./deploy.sh [init|plan|apply|destroy] [dev|staging|production]

set -e

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parâmetros
ACTION=${1:-plan}
ENVIRONMENT=${2:-dev}

echo -e "${BLUE}=========================================="
echo "  Terraform - API Produto"
echo "==========================================${NC}"
echo ""

# Validar ação
if [[ ! "$ACTION" =~ ^(init|plan|apply|destroy|output|show)$ ]]; then
    echo -e "${RED}Erro: Ação inválida!${NC}"
    echo "Uso: ./deploy.sh [init|plan|apply|destroy|output|show] [dev|staging|production]"
    exit 1
fi

# Validar ambiente
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|production)$ ]]; then
    echo -e "${RED}Erro: Ambiente inválido!${NC}"
    echo "Uso: ./deploy.sh [init|plan|apply|destroy|output|show] [dev|staging|production]"
    exit 1
fi

echo -e "${YELLOW}Ação: ${ACTION}${NC}"
echo -e "${YELLOW}Ambiente: ${ENVIRONMENT}${NC}"
echo ""

# Verificar se terraform está instalado
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}Terraform não está instalado!${NC}"
    echo "Instale: https://www.terraform.io/downloads"
    exit 1
fi

echo -e "${GREEN}✓ Terraform instalado: $(terraform version -json | jq -r '.terraform_version')${NC}"
echo ""

# Arquivo de variáveis
VAR_FILE="environments/${ENVIRONMENT}.tfvars"

if [ ! -f "$VAR_FILE" ]; then
    echo -e "${RED}Erro: Arquivo de variáveis não encontrado: ${VAR_FILE}${NC}"
    exit 1
fi

# Executar ação
case $ACTION in
    init)
        echo -e "${YELLOW}Inicializando Terraform...${NC}"
        terraform init
        echo -e "${GREEN}✓ Terraform inicializado${NC}"
        ;;
    
    plan)
        echo -e "${YELLOW}Planejando mudanças...${NC}"
        terraform plan -var-file="$VAR_FILE" -out="tfplan-${ENVIRONMENT}"
        echo -e "${GREEN}✓ Plano criado: tfplan-${ENVIRONMENT}${NC}"
        echo ""
        echo -e "${YELLOW}Para aplicar: ./deploy.sh apply ${ENVIRONMENT}${NC}"
        ;;
    
    apply)
        if [ -f "tfplan-${ENVIRONMENT}" ]; then
            echo -e "${YELLOW}Aplicando plano existente...${NC}"
            terraform apply "tfplan-${ENVIRONMENT}"
            rm -f "tfplan-${ENVIRONMENT}"
        else
            echo -e "${YELLOW}Aplicando mudanças...${NC}"
            terraform apply -var-file="$VAR_FILE" -auto-approve
        fi
        
        echo -e "${GREEN}✓ Mudanças aplicadas${NC}"
        echo ""
        
        # Mostrar outputs
        echo -e "${YELLOW}Outputs:${NC}"
        terraform output
        ;;
    
    destroy)
        echo -e "${RED}ATENÇÃO: Isso irá destruir todos os recursos!${NC}"
        read -p "Tem certeza? Digite 'yes' para confirmar: " confirm
        
        if [ "$confirm" == "yes" ]; then
            echo -e "${YELLOW}Destruindo recursos...${NC}"
            terraform destroy -var-file="$VAR_FILE" -auto-approve
            echo -e "${GREEN}✓ Recursos destruídos${NC}"
        else
            echo -e "${YELLOW}Operação cancelada${NC}"
        fi
        ;;
    
    output)
        echo -e "${YELLOW}Outputs:${NC}"
        terraform output
        ;;
    
    show)
        echo -e "${YELLOW}Estado atual:${NC}"
        terraform show
        ;;
esac

echo ""
echo -e "${GREEN}=========================================="
echo "  Operação concluída!"
echo "==========================================${NC}"
echo ""
echo "Comandos úteis:"
echo "  Ver pods:        kubectl get pods -n api-produto-${ENVIRONMENT}"
echo "  Ver services:    kubectl get svc -n api-produto-${ENVIRONMENT}"
echo "  Ver logs:        kubectl logs -f -l app=api-produto -n api-produto-${ENVIRONMENT}"
echo "  Ver outputs:     terraform output"
echo ""
