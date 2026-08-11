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
