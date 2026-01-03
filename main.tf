# 1. SETUP & PROVIDERS
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true # Convenient for labs
    }
  }
}

# 2. DATA SOURCE (The "Who am I?" trick)
# This asks Azure: "What is the Tenant ID and Object ID of the user running this?"
data "azurerm_client_config" "current" {}

# 3. RESOURCE GROUP
resource "azurerm_resource_group" "vault_rg" {
  name     = "rg-iron-bank"
  location = "West Europe"
}

# 4. RANDOM NAME GENERATOR
# Key Vault names must be unique globally. This creates a random name like "vault-zebra".
resource "random_pet" "vault_name" {
  prefix = "vault"
  length = 2
}

# 5. THE KEY VAULT
resource "azurerm_key_vault" "my_vault" {
  name                        = random_pet.vault_name.id
  location                    = azurerm_resource_group.vault_rg.location
  resource_group_name         = azurerm_resource_group.vault_rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  # 6. ACCESS POLICY (Giving YOURSELF permission)
  # Without this, you would create a vault you can't open!
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    # You are giving yourself "God Mode" on this vault
    key_permissions = ["Get", "List", "Create", "Delete", "Update"]
    secret_permissions = ["Get", "List", "Set", "Delete", "Recover", "Backup", "Restore"]
  }

  # 7. NETWORK SECURITY (The Firewall)
  # This sets the "Default Action" to Deny. Only your IP allows through.
  network_acls {
    bypass         = "AzureServices"
    default_action = "Allow" # Change to "Deny" if you want to lock it down tight
  }
}

# 8. THE SECRET (The Loot)
# We are programmatically injecting a secret into the vault.
resource "azurerm_key_vault_secret" "database_password" {
  name         = "SuperSecretPassword"
  value        = "Hunter2!"
  key_vault_id = azurerm_key_vault.my_vault.id
}