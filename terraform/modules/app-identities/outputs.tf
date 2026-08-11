output "store_managed_identity_id" {
  value = azurerm_user_assigned_identity.store.id
}

output "store_managed_identity_client_id" {
  value = azurerm_user_assigned_identity.store.client_id
}

output "products_managed_identity_id" {
  value = azurerm_user_assigned_identity.products.id
}

output "products_managed_identity_client_id" {
  value = azurerm_user_assigned_identity.products.client_id
}

output "products_managed_identity_principal_id" {
  value = azurerm_user_assigned_identity.products.principal_id
}
