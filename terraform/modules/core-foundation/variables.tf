variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "tenant_id" {
  type = string
}

variable "acr_name" {
  type = string
}

variable "key_vault_name" {
  type = string
}

variable "log_analytics_workspace_name" {
  type = string
}

variable "sql_server_name" {
  type = string
}

variable "sql_database_name" {
  type = string
}

variable "sql_database_sku_name" {
  type    = string
  default = "GP_S_Gen5_2"
}

variable "sql_auto_pause_delay_in_minutes" {
  type    = number
  default = 60
}

variable "sql_min_capacity" {
  type    = number
  default = 0.5
}

variable "sql_admin_username" {
  type = string
}

variable "sql_admin_password" {
  type      = string
  sensitive = true
}

variable "containerapps_environment_name" {
  type = string
}

variable "openai_account_name" {
  type        = string
  description = "Name of the existing Azure OpenAI (Cognitive Services) account to deploy models into (shared across environments due to subscription account quota)."
}

variable "openai_resource_group_name" {
  type        = string
  description = "Resource group of the existing Azure OpenAI account."
}

variable "openai_chat_deployment_name" {
  type    = string
  default = "gpt-41-mini"
}

variable "openai_chat_model_name" {
  type    = string
  default = "gpt-4.1-mini"
}

variable "openai_chat_model_version" {
  type    = string
  default = "2025-04-14"
}

variable "openai_chat_sku_capacity" {
  type    = number
  default = 10
}

variable "openai_embeddings_deployment_name" {
  type    = string
  default = "text-embedding-ada-002"
}

variable "openai_embeddings_model_name" {
  type    = string
  default = "text-embedding-ada-002"
}

variable "openai_embeddings_model_version" {
  type    = string
  default = "2"
}

variable "openai_embeddings_sku_capacity" {
  type    = number
  default = 8
}

variable "storage_account_name" {
  type        = string
  description = "Storage account name for Products blob storage (product images)."
}

variable "storage_container_name" {
  type    = string
  default = "product-images"
}

variable "sql_backup_retention_days" {
  type        = number
  default     = 7
  description = "Point-in-time restore retention window (days) for the SQL database."
}

variable "subscription_id" {
  type        = string
  description = "Subscription id, used to scope the Service Health activity log alert."
}

variable "alert_email" {
  type        = string
  description = "Email address for cost budget and Service Health alert notifications."
}

variable "monthly_budget_amount" {
  type        = number
  default     = 20
  description = "Monthly cost budget (subscription currency) for this environment's resource group."
}

variable "budget_start_date" {
  type        = string
  description = "Budget time_period start date (RFC3339), must align to the first of a month."
}

variable "budget_end_date" {
  type        = string
  description = "Budget time_period end date (RFC3339). Azure requires an explicit end date; extend this periodically."
}
