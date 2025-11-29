# Integração CI/CD com Terraform

Guia para integrar Terraform no pipeline de CI/CD.

## 🔄 Jenkins Pipeline

### Jenkinsfile com Terraform

```groovy
pipeline {
    agent any
    
    environment {
        TF_VAR_docker_tag = "${env.BUILD_NUMBER}"
        TF_VAR_database_url = credentials('database-url')
        TF_VAR_api_key = credentials('api-key')
    }
    
    stages {
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t api_produto:${BUILD_NUMBER} .'
            }
        }
        
        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                }
            }
        }
        
        stage('Terraform Plan') {
            steps {
                dir('terraform') {
                    sh '''
                        terraform plan \
                            -var-file=environments/production.tfvars \
                            -var="docker_tag=${BUILD_NUMBER}" \
                            -out=tfplan
                    '''
                }
            }
        }
        
        stage('Terraform Apply') {
            when {
                branch 'main'
            }
            steps {
                dir('terraform') {
                    sh 'terraform apply tfplan'
                }
            }
        }
        
        stage('Verify Deployment') {
            when {
                branch 'main'
            }
            steps {
                sh '''
                    kubectl rollout status deployment/api-produto -n api-produto
                    kubectl get pods -n api-produto
                '''
            }
        }
    }
    
    post {
        always {
            dir('terraform') {
                sh 'rm -f tfplan'
            }
        }
    }
}
```

## 🔧 GitLab CI

### .gitlab-ci.yml

```yaml
stages:
  - build
  - plan
  - apply
  - verify

variables:
  TF_ROOT: terraform
  TF_VAR_docker_tag: $CI_COMMIT_SHORT_SHA

build:
  stage: build
  script:
    - docker build -t api_produto:$CI_COMMIT_SHORT_SHA .
    - docker push api_produto:$CI_COMMIT_SHORT_SHA

terraform:init:
  stage: plan
  script:
    - cd $TF_ROOT
    - terraform init

terraform:plan:
  stage: plan
  script:
    - cd $TF_ROOT
    - terraform plan -var-file=environments/production.tfvars -out=tfplan
  artifacts:
    paths:
      - $TF_ROOT/tfplan

terraform:apply:
  stage: apply
  script:
    - cd $TF_ROOT
    - terraform apply tfplan
  only:
    - main
  when: manual

verify:
  stage: verify
  script:
    - kubectl rollout status deployment/api-produto -n api-produto
    - kubectl get pods -n api-produto
  only:
    - main
```

## 🐙 GitHub Actions

### .github/workflows/terraform.yml

```yaml
name: Terraform Deploy

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  TF_VAR_docker_tag: ${{ github.sha }}

jobs:
  terraform:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2
      with:
        terraform_version: 1.6.0
    
    - name: Build Docker Image
      run: |
        docker build -t api_produto:${{ github.sha }} .
        docker push api_produto:${{ github.sha }}
    
    - name: Terraform Init
      working-directory: terraform
      run: terraform init
    
    - name: Terraform Plan
      working-directory: terraform
      run: |
        terraform plan \
          -var-file=environments/production.tfvars \
          -var="docker_tag=${{ github.sha }}" \
          -out=tfplan
    
    - name: Terraform Apply
      if: github.ref == 'refs/heads/main'
      working-directory: terraform
      run: terraform apply tfplan
      env:
        TF_VAR_database_url: ${{ secrets.DATABASE_URL }}
        TF_VAR_api_key: ${{ secrets.API_KEY }}
    
    - name: Verify Deployment
      if: github.ref == 'refs/heads/main'
      run: |
        kubectl rollout status deployment/api-produto -n api-produto
        kubectl get pods -n api-produto
```

## 🔐 Secrets Management

### Jenkins Credentials

```groovy
environment {
    TF_VAR_database_url = credentials('database-url')
    TF_VAR_api_key = credentials('api-key')
    KUBECONFIG = credentials('kubeconfig')
}
```

### GitLab CI Variables

```yaml
variables:
  TF_VAR_database_url: $DATABASE_URL
  TF_VAR_api_key: $API_KEY
```

### GitHub Secrets

```yaml
env:
  TF_VAR_database_url: ${{ secrets.DATABASE_URL }}
  TF_VAR_api_key: ${{ secrets.API_KEY }}
```

## 📦 Remote State

### S3 Backend (AWS)

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-api-produto"
    key            = "kubernetes/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

### GCS Backend (Google Cloud)

```hcl
terraform {
  backend "gcs" {
    bucket = "terraform-state-api-produto"
    prefix = "kubernetes"
  }
}
```

### Azure Backend

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state"
    storage_account_name = "tfstateapiproduto"
    container_name       = "tfstate"
    key                  = "kubernetes.tfstate"
  }
}
```

## 🔄 Workflow Completo

### 1. Feature Branch

```bash
# Desenvolvedor cria feature
git checkout -b feature/new-endpoint

# Faz mudanças
vim lib/handlers/product_handler.dart

# Commit
git add .
git commit -m "Add new endpoint"
git push origin feature/new-endpoint
```

### 2. Pull Request

```yaml
# CI roda automaticamente
- Build Docker image
- Terraform plan (preview)
- Testes
- Code review
```

### 3. Merge to Main

```yaml
# CI/CD roda automaticamente
- Build Docker image
- Push to registry
- Terraform apply
- Deploy to Kubernetes
- Health checks
- Notificações
```

## 🎯 Estratégias de Deploy

### Blue-Green Deployment

```hcl
resource "kubernetes_deployment" "api_produto_blue" {
  metadata {
    name = "api-produto-blue"
  }
  spec {
    replicas = var.blue_replicas
    template {
      metadata {
        labels = {
          app     = "api-produto"
          version = "blue"
        }
      }
    }
  }
}

resource "kubernetes_deployment" "api_produto_green" {
  metadata {
    name = "api-produto-green"
  }
  spec {
    replicas = var.green_replicas
    template {
      metadata {
        labels = {
          app     = "api-produto"
          version = "green"
        }
      }
    }
  }
}

resource "kubernetes_service" "api_produto" {
  spec {
    selector = {
      app     = "api-produto"
      version = var.active_version  # "blue" ou "green"
    }
  }
}
```

### Canary Deployment

```hcl
resource "kubernetes_deployment" "api_produto_stable" {
  spec {
    replicas = 9  # 90% do tráfego
  }
}

resource "kubernetes_deployment" "api_produto_canary" {
  spec {
    replicas = 1  # 10% do tráfego
  }
}
```

## 📊 Monitoramento

### Terraform Cloud

```hcl
terraform {
  cloud {
    organization = "my-org"
    
    workspaces {
      name = "api-produto-production"
    }
  }
}
```

### Atlantis (Terraform PR Automation)

```yaml
# atlantis.yaml
version: 3
projects:
- name: api-produto
  dir: terraform
  workspace: production
  terraform_version: v1.6.0
  autoplan:
    when_modified: ["*.tf", "*.tfvars"]
  apply_requirements: ["approved"]
```

## 🚨 Rollback

### Rollback Automático

```groovy
stage('Verify Deployment') {
    steps {
        script {
            def healthy = sh(
                script: 'kubectl rollout status deployment/api-produto -n api-produto',
                returnStatus: true
            )
            
            if (healthy != 0) {
                echo 'Deployment failed! Rolling back...'
                dir('terraform') {
                    sh '''
                        terraform apply \
                            -var-file=environments/production.tfvars \
                            -var="docker_tag=${PREVIOUS_TAG}"
                    '''
                }
                error 'Deployment failed and rolled back'
            }
        }
    }
}
```

### Rollback Manual

```bash
# Ver histórico
terraform state list

# Rollback para versão anterior
terraform apply -var="docker_tag=previous-version"

# Ou usar Kubernetes
kubectl rollout undo deployment/api-produto -n api-produto
```

## 📝 Checklist de Deploy

### Pré-Deploy

- [ ] Código revisado
- [ ] Testes passando
- [ ] Docker image buildada
- [ ] Terraform plan revisado
- [ ] Secrets configurados
- [ ] Backup do state

### Deploy

- [ ] Terraform apply
- [ ] Rollout status OK
- [ ] Health checks passando
- [ ] Logs sem erros
- [ ] Métricas normais

### Pós-Deploy

- [ ] Smoke tests
- [ ] Monitoramento ativo
- [ ] Documentação atualizada
- [ ] Notificações enviadas
- [ ] Rollback plan pronto

## 🔧 Troubleshooting

### Terraform Apply Falha

```bash
# Ver erro detalhado
terraform apply -var-file=environments/production.tfvars

# Ver estado
terraform show

# Refresh state
terraform refresh

# Reimportar recurso
terraform import kubernetes_deployment.api_produto api-produto/api-produto
```

### Deployment Não Atualiza

```bash
# Forçar recreação
terraform taint kubernetes_deployment.api_produto
terraform apply

# Ou usar Kubernetes
kubectl rollout restart deployment/api-produto -n api-produto
```

### State Lock

```bash
# Forçar unlock (cuidado!)
terraform force-unlock <lock-id>
```

## 📚 Recursos

- [Terraform CI/CD Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/part3.html)
- [Atlantis Documentation](https://www.runatlantis.io/)
- [Terraform Cloud](https://www.terraform.io/cloud)
