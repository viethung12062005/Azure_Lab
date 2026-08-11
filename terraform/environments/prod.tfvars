project_name = "eShopLite"
environment  = "prod"
location     = "southeastasia"

owner       = "viethung12062005"
cost_center = "azure-students"
repository  = "viethung12062005/Azure_Lab"

criticality         = "high"
data_classification = "confidential"

resource_group_name            = "rg-eshoplite-prod-sea"
acr_name                       = "acreshopliteprod01"
log_analytics_workspace_name   = "law-eshoplite-prod-01"
key_vault_name                 = "kv-eshoplite-prod-01"
sql_server_name                = "sql-eshoplite-prod-01"
sql_database_name              = "sqldb-eshoplite-prod-01"
containerapps_environment_name = "cae-eshoplite-prod-01"
store_managed_identity_name    = "uai-eshoplite-store-prod-01"
products_managed_identity_name = "uai-eshoplite-products-prod-01"
openai_account_name            = "openai-eshoplite-prod-01"
storage_account_name           = "steshopliteprod01"

sql_admin_username = "sqladminuser"

additional_tags = {
  ReleaseTrack = "production"
}
