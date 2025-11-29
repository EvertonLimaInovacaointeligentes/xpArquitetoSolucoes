# Kubernetes Configuration
variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
  default     = "api-produto"
}

variable "environment" {
  description = "Environment (dev, staging, production)"
  type        = string
  default     = "production"
}

# Docker Configuration
variable "docker_host" {
  description = "Docker host"
  type        = string
  default     = "unix:///var/run/docker.sock"
}

variable "docker_image" {
  description = "Docker image name"
  type        = string
  default     = "api_produto"
}

variable "docker_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

# Application Configuration
variable "app_port" {
  description = "Application port"
  type        = number
  default     = 8080
}

variable "api_version" {
  description = "API version"
  type        = string
  default     = "v1"
}

variable "log_level" {
  description = "Log level (debug, info, warn, error)"
  type        = string
  default     = "info"
}

# Deployment Configuration
variable "replicas" {
  description = "Number of replicas"
  type        = number
  default     = 3
}

# Resources
variable "resources_requests_cpu" {
  description = "CPU request"
  type        = string
  default     = "100m"
}

variable "resources_requests_memory" {
  description = "Memory request"
  type        = string
  default     = "128Mi"
}

variable "resources_limits_cpu" {
  description = "CPU limit"
  type        = string
  default     = "500m"
}

variable "resources_limits_memory" {
  description = "Memory limit"
  type        = string
  default     = "512Mi"
}

# Service Configuration
variable "service_type" {
  description = "Service type (ClusterIP, NodePort, LoadBalancer)"
  type        = string
  default     = "LoadBalancer"
}

# HPA Configuration
variable "enable_hpa" {
  description = "Enable Horizontal Pod Autoscaler"
  type        = bool
  default     = true
}

variable "hpa_min_replicas" {
  description = "Minimum number of replicas for HPA"
  type        = number
  default     = 2
}

variable "hpa_max_replicas" {
  description = "Maximum number of replicas for HPA"
  type        = number
  default     = 10
}

variable "hpa_cpu_target" {
  description = "Target CPU utilization percentage for HPA"
  type        = number
  default     = 70
}

variable "hpa_memory_target" {
  description = "Target memory utilization percentage for HPA"
  type        = number
  default     = 80
}

# Ingress Configuration
variable "enable_ingress" {
  description = "Enable Ingress"
  type        = bool
  default     = true
}

variable "ingress_host" {
  description = "Ingress host"
  type        = string
  default     = "api-produto.example.com"
}

# Network Policy
variable "enable_network_policy" {
  description = "Enable Network Policy"
  type        = bool
  default     = true
}

# Secrets
variable "database_url" {
  description = "Database URL"
  type        = string
  default     = "postgresql://user:password@localhost:5432/api_produto"
  sensitive   = true
}

variable "api_key" {
  description = "API Key"
  type        = string
  default     = "change-me-in-production"
  sensitive   = true
}
