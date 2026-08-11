module "core" {
  source = "./modules/core-foundation"

  resource_group_name            = var.resource_group_name
  location                       = var.location
  tags                           = local.base_tags
  tenant_id                      = data.azurerm_client_config.current.tenant_id
  acr_name                       = var.acr_name
  key_vault_name                 = var.key_vault_name
  log_analytics_workspace_name   = var.log_analytics_workspace_name
  sql_server_name                = var.sql_server_name
  sql_database_name              = var.sql_database_name
  sql_admin_username             = var.sql_admin_username
  sql_admin_password             = random_password.sql_admin.result
  containerapps_environment_name = var.containerapps_environment_name
}

module "identities" {
  source = "./modules/app-identities"

  resource_group_name            = module.core.resource_group_name
  location                       = var.location
  tags                           = local.base_tags
  acr_id                         = module.core.acr_id
  store_managed_identity_name    = var.store_managed_identity_name
  products_managed_identity_name = var.products_managed_identity_name
}

resource "random_password" "sql_admin" {
  length           = 24
  special          = true
  override_special = "!#$%&*+-=?@^_"
}

resource "azurerm_role_assignment" "terraform_key_vault_secrets_officer" {
  scope                = module.core.key_vault_id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "products_key_vault_secrets_user" {
  scope                = module.core.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.identities.products_managed_identity_principal_id
}

resource "azurerm_key_vault_secret" "products_connection_string" {
  name         = "products-context-connection-string"
  value        = "Server=tcp:${module.core.sql_server_fqdn},1433;Initial Catalog=${module.core.sql_database_name};Persist Security Info=False;User ID=${var.sql_admin_username};Password=${random_password.sql_admin.result};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  key_vault_id = module.core.key_vault_id

  depends_on = [
    azurerm_role_assignment.terraform_key_vault_secrets_officer,
  ]
}

module "products_app" {
  source = "./modules/container-app-service"

  name                         = "products"
  resource_group_name          = module.core.resource_group_name
  container_app_environment_id = module.core.containerapps_environment_id
  acr_login_server             = module.core.acr_login_server
  acr_identity_id              = module.identities.products_managed_identity_id
  identity_ids                 = [module.identities.products_managed_identity_id]
  container_name               = var.products_container_name
  image                        = "${module.core.acr_login_server}/products:${var.products_image_tag}"
  target_port                  = var.products_target_port
  external_enabled             = var.products_external_enabled
  environment_variables = merge(
    {
      ASPNETCORE_ENVIRONMENT              = var.environment
      AzureOpenAIEndpoint                 = try(var.products_environment_variables["AzureOpenAIEndpoint"], "")
      AzureOpenAIDeploymentName           = try(var.products_environment_variables["AzureOpenAIDeploymentName"], "gpt-41-mini")
      AzureOpenAIEmbeddingsDeploymentName = try(var.products_environment_variables["AzureOpenAIEmbeddingsDeploymentName"], "text-embedding-ada-002")
      AzureBlobStorageEndpoint            = try(var.products_environment_variables["AzureBlobStorageEndpoint"], "")
    },
    var.products_environment_variables,
  )
  secret_environment_variables = {
    ConnectionStrings__ProductsContext = "products-context-connection-string"
  }
  key_vault_secret_refs = {
    products-context-connection-string = {
      key_vault_secret_id = azurerm_key_vault_secret.products_connection_string.resource_versionless_id
      identity            = module.identities.products_managed_identity_id
    }
  }
  tags = local.products_tags

  depends_on = [
    azurerm_role_assignment.products_key_vault_secrets_user,
    azurerm_key_vault_secret.products_connection_string,
  ]
}

module "store_app" {
  source = "./modules/container-app-service"

  name                         = "store"
  resource_group_name          = module.core.resource_group_name
  container_app_environment_id = module.core.containerapps_environment_id
  acr_login_server             = module.core.acr_login_server
  acr_identity_id              = module.identities.store_managed_identity_id
  identity_ids                 = [module.identities.store_managed_identity_id]
  container_name               = var.store_container_name
  image                        = "${module.core.acr_login_server}/store:${var.store_image_tag}"
  target_port                  = var.store_target_port
  external_enabled             = var.store_external_enabled
  environment_variables = merge(
    {
      ASPNETCORE_ENVIRONMENT = var.environment
      ProductEndpoint        = "http://products"
    },
    var.store_environment_variables,
  )
  tags = local.store_tags
}
