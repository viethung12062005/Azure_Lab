resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = var.log_analytics_workspace_name
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_container_registry" "main" {
  name                          = var.acr_name
  location                      = var.location
  resource_group_name           = azurerm_resource_group.main.name
  sku                           = "Basic"
  admin_enabled                 = false
  public_network_access_enabled = true
  tags                          = var.tags
}

resource "azurerm_key_vault" "main" {
  name                       = var.key_vault_name
  location                   = var.location
  resource_group_name        = azurerm_resource_group.main.name
  tenant_id                  = var.tenant_id
  sku_name                   = "standard"
  purge_protection_enabled   = true
  soft_delete_retention_days = 90
  rbac_authorization_enabled = true
  tags                       = var.tags
}

resource "azurerm_mssql_server" "main" {
  name                          = var.sql_server_name
  location                      = var.location
  resource_group_name           = azurerm_resource_group.main.name
  version                       = "12.0"
  administrator_login           = var.sql_admin_username
  administrator_login_password  = var.sql_admin_password
  public_network_access_enabled = true
  minimum_tls_version           = "1.2"
  tags                          = var.tags
}

resource "azurerm_mssql_database" "main" {
  name                        = var.sql_database_name
  server_id                   = azurerm_mssql_server.main.id
  sku_name                    = var.sql_database_sku_name
  auto_pause_delay_in_minutes = var.sql_auto_pause_delay_in_minutes
  min_capacity                = var.sql_min_capacity
  tags                        = merge(var.tags, { BackupRequired = "true" })

  # Point-in-time restore window. Azure SQL backs this up automatically; this
  # just makes the retention explicit/documented instead of relying on the
  # implicit platform default. No long-term retention (weekly/monthly/yearly)
  # policy is configured, since Azure Backup Vault storage is an extra cost
  # not justified for a student-subscription lab environment.
  short_term_retention_policy {
    retention_days = var.sql_backup_retention_days
  }
}

resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_container_app_environment" "main" {
  name                       = var.containerapps_environment_name
  location                   = var.location
  resource_group_name        = azurerm_resource_group.main.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  tags                       = var.tags
}

# Azure for Students subscriptions carry a very low quota on the number of
# Cognitive Services/OpenAI *accounts* (observed: creating a second one fails
# with InsufficientQuota even though the subscription has spare deployment
# capacity). Reuse the existing account instead of provisioning a new one per
# environment; only the two model deployments are managed by Terraform.
data "azurerm_cognitive_account" "openai" {
  name                = var.openai_account_name
  resource_group_name = var.openai_resource_group_name
}

resource "azurerm_cognitive_deployment" "chat" {
  name                 = var.openai_chat_deployment_name
  cognitive_account_id = data.azurerm_cognitive_account.openai.id

  model {
    format  = "OpenAI"
    name    = var.openai_chat_model_name
    version = var.openai_chat_model_version
  }

  sku {
    name     = "GlobalStandard"
    capacity = var.openai_chat_sku_capacity
  }
}

resource "azurerm_cognitive_deployment" "embeddings" {
  name                 = var.openai_embeddings_deployment_name
  cognitive_account_id = data.azurerm_cognitive_account.openai.id

  model {
    format  = "OpenAI"
    name    = var.openai_embeddings_model_name
    version = var.openai_embeddings_model_version
  }

  sku {
    name     = "Standard"
    capacity = var.openai_embeddings_sku_capacity
  }

  # Cognitive Services rejects concurrent deployment writes on the same account.
  depends_on = [azurerm_cognitive_deployment.chat]
}

resource "azurerm_storage_account" "products" {
  name                            = var.storage_account_name
  resource_group_name             = azurerm_resource_group.main.name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false
  tags                            = var.tags
}

resource "azurerm_storage_container" "product_images" {
  name                  = var.storage_container_name
  storage_account_id    = azurerm_storage_account.products.id
  container_access_type = "private"
}

resource "azurerm_monitor_action_group" "alerts" {
  name                = "ag-${var.resource_group_name}"
  resource_group_name = azurerm_resource_group.main.name
  short_name          = "eshoplite"
  tags                = var.tags

  email_receiver {
    name          = "admin"
    email_address = var.alert_email
  }
}

# Azure for Students has a fixed, small credit balance ($100) with no
# guardrail of its own, so a budget alert is the cheapest way to notice a
# runaway resource before the whole subscription is exhausted.
resource "azurerm_consumption_budget_resource_group" "monthly" {
  name              = "budget-${var.resource_group_name}"
  resource_group_id = azurerm_resource_group.main.id

  amount     = var.monthly_budget_amount
  time_grain = "Monthly"

  time_period {
    start_date = var.budget_start_date
    end_date   = var.budget_end_date
  }

  notification {
    enabled        = true
    threshold      = 80
    operator       = "GreaterThan"
    threshold_type = "Actual"
    contact_emails = [var.alert_email]
  }

  notification {
    enabled        = true
    threshold      = 100
    operator       = "GreaterThan"
    threshold_type = "Forecasted"
    contact_emails = [var.alert_email]
  }
}

# Azure Service Health incidents/planned maintenance for this subscription and
# region — the "cảnh báo sức khỏe dịch vụ" half of the Phase 5 requirement,
# distinct from application-level monitoring (which Log Analytics already covers).
resource "azurerm_monitor_activity_log_alert" "service_health" {
  name                = "alert-servicehealth-${var.resource_group_name}"
  resource_group_name = azurerm_resource_group.main.name
  location            = "global"
  scopes              = ["/subscriptions/${var.subscription_id}"]
  description         = "Azure Service Health incidents or maintenance affecting this subscription/region."

  criteria {
    category = "ServiceHealth"

    service_health {
      events    = ["Incident", "Maintenance"]
      locations = ["Global", var.location]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.alerts.id
  }
}
