terraform {
  required_version = ">= 1.0"
  
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# Provider Kubernetes
provider "kubernetes" {
  config_path = var.kubeconfig_path
}

# Provider Helm
provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_path
  }
}

# Provider Docker
provider "docker" {
  host = var.docker_host
}

# Namespace
resource "kubernetes_namespace" "api_produto" {
  metadata {
    name = var.namespace
    
    labels = {
      name        = var.namespace
      environment = var.environment
      managed-by  = "terraform"
    }
  }
}

# ConfigMap
resource "kubernetes_config_map" "api_produto" {
  metadata {
    name      = "api-produto-config"
    namespace = kubernetes_namespace.api_produto.metadata[0].name
  }

  data = {
    PORT        = var.app_port
    ENVIRONMENT = var.environment
    LOG_LEVEL   = var.log_level
    API_VERSION = var.api_version
  }
}

# Secret
resource "kubernetes_secret" "api_produto" {
  metadata {
    name      = "api-produto-secret"
    namespace = kubernetes_namespace.api_produto.metadata[0].name
  }

  type = "Opaque"

  data = {
    DATABASE_URL = base64encode(var.database_url)
    API_KEY      = base64encode(var.api_key)
  }
}

# Deployment
resource "kubernetes_deployment" "api_produto" {
  metadata {
    name      = "api-produto"
    namespace = kubernetes_namespace.api_produto.metadata[0].name
    
    labels = {
      app     = "api-produto"
      version = "v1"
    }
  }

  spec {
    replicas = var.replicas

    strategy {
      type = "RollingUpdate"
      
      rolling_update {
        max_surge       = "1"
        max_unavailable = "0"
      }
    }

    selector {
      match_labels = {
        app = "api-produto"
      }
    }

    template {
      metadata {
        labels = {
          app     = "api-produto"
          version = "v1"
        }
      }

      spec {
        container {
          name  = "api-produto"
          image = "${var.docker_image}:${var.docker_tag}"
          
          port {
            container_port = var.app_port
            name           = "http"
            protocol       = "TCP"
          }

          env {
            name = "PORT"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.api_produto.metadata[0].name
                key  = "PORT"
              }
            }
          }

          env {
            name = "ENVIRONMENT"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.api_produto.metadata[0].name
                key  = "ENVIRONMENT"
              }
            }
          }

          env {
            name = "DATABASE_URL"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.api_produto.metadata[0].name
                key  = "DATABASE_URL"
              }
            }
          }

          resources {
            requests = {
              cpu    = var.resources_requests_cpu
              memory = var.resources_requests_memory
            }
            limits = {
              cpu    = var.resources_limits_cpu
              memory = var.resources_limits_memory
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = var.app_port
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/"
              port = var.app_port
            }
            initial_delay_seconds = 10
            period_seconds        = 5
            timeout_seconds       = 3
            failure_threshold     = 3
          }

          lifecycle {
            pre_stop {
              exec {
                command = ["/bin/sh", "-c", "sleep 10"]
              }
            }
          }
        }

        termination_grace_period_seconds = 30
        restart_policy                   = "Always"
      }
    }
  }

  depends_on = [
    kubernetes_config_map.api_produto,
    kubernetes_secret.api_produto
  ]
}

# Service
resource "kubernetes_service" "api_produto" {
  metadata {
    name      = "api-produto-service"
    namespace = kubernetes_namespace.api_produto.metadata[0].name
    
    labels = {
      app = "api-produto"
    }
  }

  spec {
    type = var.service_type

    selector = {
      app = "api-produto"
    }

    port {
      name        = "http"
      port        = 80
      target_port = var.app_port
      protocol    = "TCP"
    }

    session_affinity = "ClientIP"
  }

  depends_on = [kubernetes_deployment.api_produto]
}

# Horizontal Pod Autoscaler
resource "kubernetes_horizontal_pod_autoscaler_v2" "api_produto" {
  count = var.enable_hpa ? 1 : 0

  metadata {
    name      = "api-produto-hpa"
    namespace = kubernetes_namespace.api_produto.metadata[0].name
  }

  spec {
    min_replicas = var.hpa_min_replicas
    max_replicas = var.hpa_max_replicas

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.api_produto.metadata[0].name
    }

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = var.hpa_cpu_target
        }
      }
    }

    metric {
      type = "Resource"
      resource {
        name = "memory"
        target {
          type                = "Utilization"
          average_utilization = var.hpa_memory_target
        }
      }
    }

    behavior {
      scale_down {
        stabilization_window_seconds = 300
        
        policy {
          type           = "Percent"
          value          = 50
          period_seconds = 60
        }
      }

      scale_up {
        stabilization_window_seconds = 0
        
        policy {
          type           = "Percent"
          value          = 100
          period_seconds = 30
        }
        
        policy {
          type           = "Pods"
          value          = 2
          period_seconds = 30
        }
        
        select_policy = "Max"
      }
    }
  }

  depends_on = [kubernetes_deployment.api_produto]
}

# Ingress
resource "kubernetes_ingress_v1" "api_produto" {
  count = var.enable_ingress ? 1 : 0

  metadata {
    name      = "api-produto-ingress"
    namespace = kubernetes_namespace.api_produto.metadata[0].name
    
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
      "nginx.ingress.kubernetes.io/ssl-redirect"   = "true"
      "cert-manager.io/cluster-issuer"             = "letsencrypt-prod"
      "nginx.ingress.kubernetes.io/rate-limit"     = "100"
    }
  }

  spec {
    ingress_class_name = "nginx"

    tls {
      hosts       = [var.ingress_host]
      secret_name = "api-produto-tls"
    }

    rule {
      host = var.ingress_host

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.api_produto.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_service.api_produto]
}

# Pod Disruption Budget
resource "kubernetes_pod_disruption_budget_v1" "api_produto" {
  metadata {
    name      = "api-produto-pdb"
    namespace = kubernetes_namespace.api_produto.metadata[0].name
  }

  spec {
    min_available = "1"

    selector {
      match_labels = {
        app = "api-produto"
      }
    }
  }

  depends_on = [kubernetes_deployment.api_produto]
}

# Network Policy
resource "kubernetes_network_policy" "api_produto" {
  count = var.enable_network_policy ? 1 : 0

  metadata {
    name      = "api-produto-network-policy"
    namespace = kubernetes_namespace.api_produto.metadata[0].name
  }

  spec {
    pod_selector {
      match_labels = {
        app = "api-produto"
      }
    }

    policy_types = ["Ingress", "Egress"]

    ingress {
      from {
        namespace_selector {
          match_labels = {
            name = "ingress-nginx"
          }
        }
      }

      from {
        pod_selector {
          match_labels = {
            app = "api-produto"
          }
        }
      }

      ports {
        protocol = "TCP"
        port     = var.app_port
      }
    }

    egress {
      to {
        namespace_selector {}
      }

      ports {
        protocol = "TCP"
        port     = "53"
      }

      ports {
        protocol = "UDP"
        port     = "53"
      }
    }

    egress {
      to {
        namespace_selector {}
      }

      ports {
        protocol = "TCP"
        port     = "443"
      }

      ports {
        protocol = "TCP"
        port     = "80"
      }
    }
  }

  depends_on = [kubernetes_deployment.api_produto]
}
