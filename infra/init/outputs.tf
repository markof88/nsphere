output "uami_client_id"    { value = azurerm_user_assigned_identity.this.client_id }
output "uami_principal_id" { value = azurerm_user_assigned_identity.this.principal_id }
output "state_rg"          { value = azurerm_resource_group.this.name }
output "state_account"     { value = azurerm_storage_account.this.name }
output "state_container"   { value = azurerm_storage_container.this.name }
