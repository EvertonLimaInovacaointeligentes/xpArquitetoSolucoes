# Development Environment

namespace   = "api-produto-dev"
environment = "development"

# Docker
docker_tag = "dev"

# Application
log_level = "debug"

# Deployment
replicas = 1

# Resources (minimal)
resources_requests_cpu    = "50m"
resources_requests_memory = "64Mi"
resources_limits_cpu      = "200m"
resources_limits_memory   = "256Mi"

# Service
service_type = "NodePort"

# HPA (disabled in dev)
enable_hpa = false

# Ingress (disabled in dev)
enable_ingress = false

# Network Policy (disabled in dev)
enable_network_policy = false
