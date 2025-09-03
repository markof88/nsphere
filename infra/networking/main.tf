resource "azurerm_resource_group" "net" {
  name     = var.resource_group_name
  location = var.location
  tags = { environment = "test" }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "nsphere-test-vnet1"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.net.location
  resource_group_name = azurerm_resource_group.net.name
  tags = { environment = "test" }
}

resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.net.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}
