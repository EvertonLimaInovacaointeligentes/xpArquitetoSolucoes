# Staging Environment

namespace   = "api-produto-staging"
environment = "staging"

# Docker
docker_tag = "staging"

# Application
log_level = "info"

# Deployment
replicas = 2

# Resources (medium)
resources_requests_cpu    = "100m"
resources_requests_memory = "128Mi"
resources_limits_cpu      = "400m"
resources_limits_memory   = "512Mi"

# Service
service_type = "LoadBalancer"

# HPA
enable_hpa       = true
hpa_min_replicas = 2
hpa_max_replicas = 5
hpa_cpu_target   = 70
hpa_memory_target = 80

# Ingress
enable_ingress = true
ingress_host   = "staging.api-produto.example.com"

# Network Policy
enable_network_policy = true
