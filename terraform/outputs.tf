output "resource_group_name" {
  value = module.core.resource_group_name
}

output "log_analytics_workspace_id" {
  value = module.core.log_analytics_workspace_id
}

output "acr_login_server" {
  value = module.core.acr_login_server
}

output "key_vault_id" {
  value = module.core.key_vault_id
}

output "sql_server_fqdn" {
  value = module.core.sql_server_fqdn
}

output "sql_database_name" {
  value = module.core.sql_database_name
}

output "containerapps_environment_id" {
  value = module.core.containerapps_environment_id
}

output "openai_endpoint" {
  value = module.core.openai_endpoint
}

output "storage_account_name" {
  value = module.core.storage_account_name
}

output "storage_primary_blob_endpoint" {
  value = module.core.storage_primary_blob_endpoint
}

output "store_managed_identity_client_id" {
  value = module.identities.store_managed_identity_client_id
}

output "products_managed_identity_client_id" {
  value = module.identities.products_managed_identity_client_id
}

output "store_container_app_fqdn" {
  value = module.store_app.container_app_fqdn
}

output "products_container_app_fqdn" {
  value = module.products_app.container_app_fqdn
}
