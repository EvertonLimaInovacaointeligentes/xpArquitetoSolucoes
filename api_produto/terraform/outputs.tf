# Namespace
output "namespace" {
  description = "Kubernetes namespace"
  value       = kubernetes_namespace.api_produto.metadata[0].name
}

# Deployment
output "deployment_name" {
  description = "Deployment name"
  value       = kubernetes_deployment.api_produto.metadata[0].name
}

output "deployment_replicas" {
  description = "Number of replicas"
  value       = kubernetes_deployment.api_produto.spec[0].replicas
}

# Service
output "service_name" {
  description = "Service name"
  value       = kubernetes_service.api_produto.metadata[0].name
}

output "service_type" {
  description = "Service type"
  value       = kubernetes_service.api_produto.spec[0].type
}

output "service_port" {
  description = "Service port"
  value       = kubernetes_service.api_produto.spec[0].port[0].port
}

# Load Balancer IP (if available)
output "load_balancer_ip" {
  description = "Load Balancer IP address"
  value       = try(kubernetes_service.api_produto.status[0].load_balancer[0].ingress[0].ip, "pending")
}

# Ingress
output "ingress_host" {
  description = "Ingress host"
  value       = var.enable_ingress ? var.ingress_host : "ingress disabled"
}

output "ingress_url" {
  description = "Ingress URL"
  value       = var.enable_ingress ? "https://${var.ingress_host}" : "ingress disabled"
}

# HPA
output "hpa_enabled" {
  description = "HPA enabled"
  value       = var.enable_hpa
}

output "hpa_min_replicas" {
  description = "HPA minimum replicas"
  value       = var.enable_hpa ? var.hpa_min_replicas : 0
}

output "hpa_max_replicas" {
  description = "HPA maximum replicas"
  value       = var.enable_hpa ? var.hpa_max_replicas : 0
}

# ConfigMap
output "configmap_name" {
  description = "ConfigMap name"
  value       = kubernetes_config_map.api_produto.metadata[0].name
}

# Secret
output "secret_name" {
  description = "Secret name"
  value       = kubernetes_secret.api_produto.metadata[0].name
}

# Useful commands
output "kubectl_commands" {
  description = "Useful kubectl commands"
  value = {
    get_pods        = "kubectl get pods -n ${kubernetes_namespace.api_produto.metadata[0].name}"
    get_services    = "kubectl get svc -n ${kubernetes_namespace.api_produto.metadata[0].name}"
    get_deployments = "kubectl get deployments -n ${kubernetes_namespace.api_produto.metadata[0].name}"
    logs            = "kubectl logs -f -l app=api-produto -n ${kubernetes_namespace.api_produto.metadata[0].name}"
    describe        = "kubectl describe deployment api-produto -n ${kubernetes_namespace.api_produto.metadata[0].name}"
    port_forward    = "kubectl port-forward svc/${kubernetes_service.api_produto.metadata[0].name} 8080:80 -n ${kubernetes_namespace.api_produto.metadata[0].name}"
  }
}

# Summary
output "deployment_summary" {
  description = "Deployment summary"
  value = {
    namespace    = kubernetes_namespace.api_produto.metadata[0].name
    environment  = var.environment
    image        = "${var.docker_image}:${var.docker_tag}"
    replicas     = kubernetes_deployment.api_produto.spec[0].replicas
    service_type = kubernetes_service.api_produto.spec[0].type
    hpa_enabled  = var.enable_hpa
    ingress_url  = var.enable_ingress ? "https://${var.ingress_host}" : "ingress disabled"
  }
}
