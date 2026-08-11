variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "acr_id" {
  type = string
}

variable "store_managed_identity_name" {
  type = string
}

variable "products_managed_identity_name" {
  type = string
}
