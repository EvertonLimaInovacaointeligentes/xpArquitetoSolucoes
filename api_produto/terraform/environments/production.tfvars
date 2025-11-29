# Production Environment

namespace   = "api-produto"
environment = "production"

# Docker
docker_tag = "latest"

# Application
log_level = "warn"

# Deployment
replicas = 3

# Resources (full)
resources_requests_cpu    = "100m"
resources_requests_memory = "128Mi"
resources_limits_cpu      = "500m"
resources_limits_memory   = "512Mi"

# Service
service_type = "LoadBalancer"

# HPA
enable_hpa        = true
hpa_min_replicas  = 2
hpa_max_replicas  = 10
hpa_cpu_target    = 70
hpa_memory_target = 80

# Ingress
enable_ingress = true
ingress_host   = "api-produto.example.com"

# Network Policy
enable_network_policy = true
