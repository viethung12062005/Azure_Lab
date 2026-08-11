variable "project_name" {
  type        = string
  default     = "eShopLite"
  description = "Logical project name used for tags and naming conventions."
}

variable "environment" {
  type        = string
  description = "Target environment name."

  validation {
    condition     = contains(["dev", "test", "staging", "prod"], lower(var.environment))
    error_message = "environment must be one of: dev, test, staging, prod."
  }
}

variable "location" {
  type        = string
  description = "Azure region for the workload."
}

variable "owner" {
  type        = string
  description = "Owning team or person."
}

variable "cost_center" {
  type        = string
  description = "Cost center or budget code."
}

variable "repository" {
  type        = string
  description = "GitHub repository name in owner/repo format."
}

variable "criticality" {
  type        = string
  description = "Workload criticality tag."

  validation {
    condition     = contains(["low", "medium", "high"], lower(var.criticality))
    error_message = "criticality must be one of: low, medium, high."
  }
}

variable "data_classification" {
  type        = string
  description = "Data classification tag."

  validation {
    condition     = contains(["public", "internal", "confidential", "restricted"], lower(var.data_classification))
    error_message = "data_classification must be one of: public, internal, confidential, restricted."
  }
}

variable "additional_tags" {
  type        = map(string)
  default     = {}
  description = "Optional extra tags merged into every resource."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group for the core Azure foundation."
}

variable "acr_name" {
  type        = string
  description = "Azure Container Registry name."
}

variable "log_analytics_workspace_name" {
  type        = string
  description = "Log Analytics Workspace name."
}

variable "key_vault_name" {
  type        = string
  description = "Key Vault name."
}

variable "sql_server_name" {
  type        = string
  description = "Azure SQL logical server name."
}

variable "sql_database_name" {
  type        = string
  description = "Azure SQL database name."
}

variable "containerapps_environment_name" {
  type        = string
  description = "Azure Container Apps Environment name."
}

variable "store_managed_identity_name" {
  type        = string
  description = "Managed Identity name for the Store workload."
}

variable "products_managed_identity_name" {
  type        = string
  description = "Managed Identity name for the Products workload."
}

variable "sql_admin_username" {
  type        = string
  description = "SQL administrator username used only for bootstrap."
}

variable "store_image_tag" {
  type        = string
  default     = "latest"
  description = "Image tag for the Store container app."
}

variable "products_image_tag" {
  type        = string
  default     = "latest"
  description = "Image tag for the Products container app."
}

variable "store_environment_variables" {
  type        = map(string)
  default     = {}
  description = "Additional environment variables for Store."
}

variable "products_environment_variables" {
  type        = map(string)
  default     = {}
  description = "Additional environment variables for Products."
}

variable "store_container_name" {
  type        = string
  default     = "store"
  description = "Container name for the Store app."
}

variable "products_container_name" {
  type        = string
  default     = "products"
  description = "Container name for the Products app."
}

variable "store_external_enabled" {
  type        = bool
  default     = true
  description = "Whether Store should expose public ingress."
}

variable "products_external_enabled" {
  type        = bool
  default     = false
  description = "Whether Products should expose public ingress."
}

variable "store_target_port" {
  type        = number
  default     = 80
  description = "Ingress target port for Store."
}

variable "products_target_port" {
  type        = number
  default     = 80
  description = "Ingress target port for Products."
}
