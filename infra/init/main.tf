terraform {
  required_version = ">= 1.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    # (Optional) Terraform will auto-install this when it sees local_file.
    # Keeping it explicit avoids surprises.
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id     = var.subscription_id
  storage_use_azuread = true
}

# --- Storage resources ---
resource "azurerm_resource_group" "this" {
  name     = "nsphere-init-rg"
  location = "Germany West Central"
}

resource "azurerm_storage_account" "this" {
  name                            = "${var.environment}initst" # e.g., "prdinitst"
  resource_group_name             = azurerm_resource_group.this.name
  location                        = azurerm_resource_group.this.location
  account_tier                    = "Standard"
  account_replication_type        = "ZRS"
  shared_access_key_enabled       = false
  default_to_oauth_authentication = true
}

# Give the initial operator Blob Data Contributor so it can create the container
resource "azurerm_role_assignment" "blob_data_contributor_initial_user_admin" {
  principal_id         = var.initial_user_admin_object_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = azurerm_storage_account.this.id
}

resource "azurerm_storage_container" "this" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"

  depends_on = [azurerm_role_assignment.blob_data_contributor_initial_user_admin]
}

resource "azurerm_user_assigned_identity" "this" {
  name                = "cloudchronicles-init-msi"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_federated_identity_credential" "this" {
  name                = "GitHub-markof88-nsphere-environment-test"
  resource_group_name = azurerm_resource_group.this.name
  parent_id           = azurerm_user_assigned_identity.this.id

  issuer    = "https://token.actions.githubusercontent.com"
  audience = ["api://AzureADTokenExchange"]
  subject   = "repo:markof88/nsphere:environment:test"
}

resource "azurerm_role_assignment" "blob_data_contributor_msi" {
  principal_id                     = azurerm_user_assigned_identity.this.principal_id
  role_definition_name             = "Storage Blob Data Contributor"
  scope                            = azurerm_storage_account.this.id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "uami_contributor_subscription" {
  principal_id         = azurerm_user_assigned_identity.this.principal_id
  role_definition_name = "Contributor"
  scope                = "/subscriptions/${var.subscription_id}"
}

# --- Auto-generate backend config files (partial backend) ---
resource "local_file" "tfbackend" {
  content  = <<EOD
resource_group_name  = "${azurerm_resource_group.this.name}"
storage_account_name = "${azurerm_storage_account.this.name}"
container_name       = "${azurerm_storage_container.this.name}"
use_azuread_auth     = true
EOD
  # Writes to a sibling .config folder one level up, like the post
  filename = "../.config/${var.environment}.tfbackend"
}

resource "local_file" "backend" {
  content  = <<EOD
terraform {
  backend "azurerm" {
    key = "init.tfstate"
  }
}
EOD
  filename = "./backend.tf"
}
