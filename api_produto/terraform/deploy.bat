@echo off
REM Script de deploy com Terraform (Windows)
REM Uso: deploy.bat [init|plan|apply|destroy] [dev|staging|production]

setlocal enabledelayedexpansion

REM Parâmetros
set ACTION=%1
set ENVIRONMENT=%2

if "%ACTION%"=="" set ACTION=plan
if "%ENVIRONMENT%"=="" set ENVIRONMENT=dev

echo ==========================================
echo   Terraform - API Produto
echo ==========================================
echo.

REM Validar ação
if not "%ACTION%"=="init" if not "%ACTION%"=="plan" if not "%ACTION%"=="apply" if not "%ACTION%"=="destroy" if not "%ACTION%"=="output" if not "%ACTION%"=="show" (
    echo [ERRO] Acao invalida!
    echo Uso: deploy.bat [init^|plan^|apply^|destroy^|output^|show] [dev^|staging^|production]
    exit /b 1
)

REM Validar ambiente
if not "%ENVIRONMENT%"=="dev" if not "%ENVIRONMENT%"=="staging" if not "%ENVIRONMENT%"=="production" (
    echo [ERRO] Ambiente invalido!
    echo Uso: deploy.bat [init^|plan^|apply^|destroy^|output^|show] [dev^|staging^|production]
    exit /b 1
)

echo Acao: %ACTION%
echo Ambiente: %ENVIRONMENT%
echo.

REM Verificar se terraform está instalado
terraform version >nul 2>&1
if errorlevel 1 (
    echo [ERRO] Terraform nao esta instalado!
    echo Instale: https://www.terraform.io/downloads
    exit /b 1
)

echo [OK] Terraform instalado
echo.

REM Arquivo de variáveis
set VAR_FILE=environments\%ENVIRONMENT%.tfvars

if not exist "%VAR_FILE%" (
    echo [ERRO] Arquivo de variaveis nao encontrado: %VAR_FILE%
    exit /b 1
)

REM Executar ação
if "%ACTION%"=="init" (
    echo Inicializando Terraform...
    terraform init
    echo [OK] Terraform inicializado
    goto :end
)

if "%ACTION%"=="plan" (
    echo Planejando mudancas...
    terraform plan -var-file="%VAR_FILE%" -out="tfplan-%ENVIRONMENT%"
    echo [OK] Plano criado: tfplan-%ENVIRONMENT%
    echo.
    echo Para aplicar: deploy.bat apply %ENVIRONMENT%
    goto :end
)

if "%ACTION%"=="apply" (
    if exist "tfplan-%ENVIRONMENT%" (
        echo Aplicando plano existente...
        terraform apply "tfplan-%ENVIRONMENT%"
        del "tfplan-%ENVIRONMENT%"
    ) else (
        echo Aplicando mudancas...
        terraform apply -var-file="%VAR_FILE%" -auto-approve
    )
    
    echo [OK] Mudancas aplicadas
    echo.
    
    echo Outputs:
    terraform output
    goto :end
)

if "%ACTION%"=="destroy" (
    echo ATENCAO: Isso ira destruir todos os recursos!
    set /p confirm="Tem certeza? Digite 'yes' para confirmar: "
    
    if "!confirm!"=="yes" (
        echo Destruindo recursos...
        terraform destroy -var-file="%VAR_FILE%" -auto-approve
        echo [OK] Recursos destruidos
    ) else (
        echo Operacao cancelada
    )
    goto :end
)

if "%ACTION%"=="output" (
    echo Outputs:
    terraform output
    goto :end
)

if "%ACTION%"=="show" (
    echo Estado atual:
    terraform show
    goto :end
)

:end
echo.
echo ==========================================
echo   Operacao concluida!
echo ==========================================
echo.
echo Comandos uteis:
echo   Ver pods:        kubectl get pods -n api-produto-%ENVIRONMENT%
echo   Ver services:    kubectl get svc -n api-produto-%ENVIRONMENT%
echo   Ver logs:        kubectl logs -f -l app=api-produto -n api-produto-%ENVIRONMENT%
echo   Ver outputs:     terraform output
echo.

pause
