terraform {
  backend "azurerm" {
    key = "networking.tfstate"
  }
}
