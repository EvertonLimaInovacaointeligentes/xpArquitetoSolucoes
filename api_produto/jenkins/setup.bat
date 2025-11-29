@echo off
REM Script de setup do Jenkins para API Produto (Windows)

echo ==========================================
echo   Setup Jenkins - API Produto
echo ==========================================
echo.

REM Verificar se Docker está instalado
docker --version >nul 2>&1
if errorlevel 1 (
    echo [ERRO] Docker nao esta instalado!
    echo Instale o Docker: https://docs.docker.com/get-docker/
    exit /b 1
)

REM Verificar se Docker Compose está instalado
docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo [ERRO] Docker Compose nao esta instalado!
    echo Instale o Docker Compose: https://docs.docker.com/compose/install/
    exit /b 1
)

echo [OK] Docker e Docker Compose encontrados
echo.

REM Criar diretório para volumes se não existir
if not exist jenkins_home mkdir jenkins_home

REM Construir imagem customizada
echo Construindo imagem customizada do Jenkins...
docker-compose build

REM Iniciar Jenkins
echo Iniciando Jenkins...
docker-compose up -d

REM Aguardar Jenkins iniciar
echo Aguardando Jenkins inicializar...
timeout /t 30 /nobreak >nul

REM Verificar se está rodando
docker ps | findstr jenkins_dart >nul
if errorlevel 1 (
    echo [ERRO] Erro ao iniciar Jenkins!
    echo Verifique os logs: docker-compose logs
    exit /b 1
)

echo.
echo ==========================================
echo   Jenkins iniciado com sucesso!
echo ==========================================
echo.
echo Acesse: http://localhost:8081
echo.
echo Credenciais padrao:
echo   Usuario: admin
echo   Senha: admin123
echo.
echo IMPORTANTE: Altere a senha apos o primeiro login!
echo.
echo Comandos uteis:
echo   Ver logs:     docker-compose logs -f
echo   Parar:        docker-compose down
echo   Reiniciar:    docker-compose restart
echo.

pause
