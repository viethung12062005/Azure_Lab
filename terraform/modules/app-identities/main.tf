resource "azurerm_user_assigned_identity" "store" {
  name                = var.store_managed_identity_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = merge(var.tags, { Workload = "store" })
}

resource "azurerm_user_assigned_identity" "products" {
  name                = var.products_managed_identity_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = merge(var.tags, { Workload = "products" })
}

resource "azurerm_role_assignment" "store_acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.store.principal_id
}

resource "azurerm_role_assignment" "products_acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.products.principal_id
}
