@echo off
REM Script de deploy para Kubernetes (Windows)
REM Uso: deploy.bat [dev|staging|production]

setlocal enabledelayedexpansion

REM Ambiente padrão
set ENVIRONMENT=%1
if "%ENVIRONMENT%"=="" set ENVIRONMENT=dev

echo ==========================================
echo   Deploy Kubernetes - API Produto
echo ==========================================
echo.

REM Validar ambiente
if not "%ENVIRONMENT%"=="dev" if not "%ENVIRONMENT%"=="staging" if not "%ENVIRONMENT%"=="production" (
    echo [ERRO] Ambiente invalido!
    echo Uso: deploy.bat [dev^|staging^|production]
    exit /b 1
)

echo Ambiente: %ENVIRONMENT%
echo.

REM Verificar se kubectl está instalado
kubectl version --client >nul 2>&1
if errorlevel 1 (
    echo [ERRO] kubectl nao esta instalado!
    exit /b 1
)

REM Verificar conexão com cluster
echo Verificando conexao com cluster...
kubectl cluster-info >nul 2>&1
if errorlevel 1 (
    echo [ERRO] Nao foi possivel conectar ao cluster Kubernetes!
    exit /b 1
)
echo [OK] Conectado ao cluster
echo.

REM Criar namespace
set NAMESPACE=api-produto
if not "%ENVIRONMENT%"=="production" set NAMESPACE=api-produto-%ENVIRONMENT%

echo Criando namespace %NAMESPACE%...
kubectl create namespace %NAMESPACE% --dry-run=client -o yaml | kubectl apply -f -
echo [OK] Namespace criado/atualizado
echo.

REM Deploy usando Kustomize
echo Aplicando manifests do Kubernetes...
kubectl apply -k overlays/%ENVIRONMENT%/
echo [OK] Manifests aplicados
echo.

REM Aguardar rollout
echo Aguardando rollout do deployment...
kubectl rollout status deployment/api-produto -n %NAMESPACE% --timeout=5m
echo [OK] Rollout concluido
echo.

REM Verificar pods
echo Verificando status dos pods...
kubectl get pods -n %NAMESPACE% -l app=api-produto
echo.

REM Verificar services
echo Verificando services...
kubectl get svc -n %NAMESPACE%
echo.

echo ==========================================
echo   Deploy concluido com sucesso!
echo ==========================================
echo.
echo Comandos uteis:
echo   Ver pods:        kubectl get pods -n %NAMESPACE%
echo   Ver logs:        kubectl logs -f -l app=api-produto -n %NAMESPACE%
echo   Ver services:    kubectl get svc -n %NAMESPACE%
echo   Escalar:         kubectl scale deployment/api-produto --replicas=5 -n %NAMESPACE%
echo   Deletar:         kubectl delete -k overlays/%ENVIRONMENT%/
echo.

pause
