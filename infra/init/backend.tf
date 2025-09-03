terraform {
  backend "azurerm" {
    key = "init.tfstate"
  }
}
