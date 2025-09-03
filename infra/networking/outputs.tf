output "resource_group_id" { value = azurerm_resource_group.net.id }
output "vnet_id"           { value = azurerm_virtual_network.vnet.id }
output "subnet1_id"        { value = azurerm_subnet.subnet1.id }
