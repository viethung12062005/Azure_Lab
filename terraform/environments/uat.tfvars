project_name = "eShopLite"
environment  = "uat"
location     = "japaneast"

owner       = "viethung12062005"
cost_center = "azure-students"
repository  = "viethung12062005/Azure_Lab"

criticality         = "high"
data_classification = "internal"

resource_group_name            = "rg-eshoplite-uat-jpe"
acr_name                       = "acreshopliteuat01"
log_analytics_workspace_name   = "law-eshoplite-uat-01"
key_vault_name                 = "kv-eshoplite-uat-01"
sql_server_name                = "sql-eshoplite-uat-01"
sql_database_name              = "sqldb-eshoplite-uat-01"
containerapps_environment_name = "cae-eshoplite-uat-01"
store_managed_identity_name    = "uai-eshoplite-store-uat-01"
products_managed_identity_name = "uai-eshoplite-products-uat-01"
openai_account_name            = "oai-eshoplab-dev"
openai_resource_group_name     = "rg-eshop-lab-dev"
storage_account_name           = "steshopliteuat01"

sql_admin_username = "sqladminuser"

additional_tags = {
  ReleaseTrack = "uat"
}

admin_object_id = "691b0002-2314-498a-b55d-9cd84cc517d9"
