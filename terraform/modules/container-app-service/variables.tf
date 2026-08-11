variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "container_app_environment_id" {
  type = string
}

variable "acr_login_server" {
  type = string
}

variable "acr_identity_id" {
  type = string
}

variable "identity_ids" {
  type = list(string)
}

variable "container_name" {
  type = string
}

variable "image" {
  type = string
}

variable "cpu" {
  type    = number
  default = 0.5
}

variable "memory" {
  type    = string
  default = "1Gi"
}

variable "target_port" {
  type = number
}

variable "external_enabled" {
  type = bool
}

variable "min_replicas" {
  type    = number
  default = 0
}

variable "max_replicas" {
  type    = number
  default = 1
}

variable "environment_variables" {
  type    = map(string)
  default = {}
}

variable "secret_environment_variables" {
  type    = map(string)
  default = {}
}

variable "key_vault_secret_refs" {
  type = map(object({
    key_vault_secret_id = string
    identity            = string
  }))
  default = {}
}

variable "tags" {
  type = map(string)
}
