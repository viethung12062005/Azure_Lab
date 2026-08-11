output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "resource_group_id" {
  value = azurerm_resource_group.main.id
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.main.id
}

output "acr_id" {
  value = azurerm_container_registry.main.id
}

output "acr_login_server" {
  value = azurerm_container_registry.main.login_server
}

output "key_vault_id" {
  value = azurerm_key_vault.main.id
}

output "sql_server_id" {
  value = azurerm_mssql_server.main.id
}

output "sql_server_fqdn" {
  value = azurerm_mssql_server.main.fully_qualified_domain_name
}

output "sql_database_name" {
  value = azurerm_mssql_database.main.name
}

output "containerapps_environment_id" {
  value = azurerm_container_app_environment.main.id
}

output "openai_id" {
  value = azurerm_cognitive_account.openai.id
}

output "openai_endpoint" {
  value = azurerm_cognitive_account.openai.endpoint
}

output "openai_chat_deployment_name" {
  value = azurerm_cognitive_deployment.chat.name
}

output "openai_embeddings_deployment_name" {
  value = azurerm_cognitive_deployment.embeddings.name
}

output "storage_account_id" {
  value = azurerm_storage_account.products.id
}

output "storage_account_name" {
  value = azurerm_storage_account.products.name
}

output "storage_primary_blob_endpoint" {
  value = azurerm_storage_account.products.primary_blob_endpoint
}

output "storage_container_name" {
  value = azurerm_storage_container.product_images.name
}
