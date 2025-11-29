#!/bin/bash

# Script de setup do Jenkins para API Produto

set -e

echo "=========================================="
echo "  Setup Jenkins - API Produto"
echo "=========================================="
echo ""

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Verificar se Docker está instalado
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker não está instalado!${NC}"
    echo "Instale o Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

# Verificar se Docker Compose está instalado
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}Docker Compose não está instalado!${NC}"
    echo "Instale o Docker Compose: https://docs.docker.com/compose/install/"
    exit 1
fi

echo -e "${GREEN}✓ Docker e Docker Compose encontrados${NC}"
echo ""

# Criar diretório para volumes se não existir
mkdir -p jenkins_home

# Construir imagem customizada
echo -e "${YELLOW}Construindo imagem customizada do Jenkins...${NC}"
docker-compose build

# Iniciar Jenkins
echo -e "${YELLOW}Iniciando Jenkins...${NC}"
docker-compose up -d

# Aguardar Jenkins iniciar
echo -e "${YELLOW}Aguardando Jenkins inicializar...${NC}"
sleep 30

# Verificar se está rodando
if docker ps | grep -q jenkins_dart; then
    echo ""
    echo -e "${GREEN}=========================================="
    echo "  Jenkins iniciado com sucesso!"
    echo "==========================================${NC}"
    echo ""
    echo "Acesse: http://localhost:8081"
    echo ""
    echo "Credenciais padrão:"
    echo "  Usuário: admin"
    echo "  Senha: admin123"
    echo ""
    echo -e "${RED}IMPORTANTE: Altere a senha após o primeiro login!${NC}"
    echo ""
    echo "Comandos úteis:"
    echo "  Ver logs:     docker-compose logs -f"
    echo "  Parar:        docker-compose down"
    echo "  Reiniciar:    docker-compose restart"
    echo ""
else
    echo -e "${RED}Erro ao iniciar Jenkins!${NC}"
    echo "Verifique os logs: docker-compose logs"
    exit 1
fi
