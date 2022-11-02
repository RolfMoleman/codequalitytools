terraform {
  required_version = "__terraform_required_version__"
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "__azuread_provider_version__"
    }

    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "__azuredevops_provider_version__"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "__azurerm_provider_version__"
    }
    time = {
      source  = "hashicorp/time"
      version = "__time_provider_version__"
    }
  }
  backend "azurerm" {
  }
}

provider "azuread" {
  client_id     = var.client_id
  client_secret = var.client_secret
  tenant_id     = var.tenant_id
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy               = true
      purge_soft_deleted_certificates_on_destroy = true
      purge_soft_deleted_keys_on_destroy         = true
      purge_soft_deleted_secrets_on_destroy      = true
      recover_soft_deleted_certificates          = true
      recover_soft_deleted_key_vaults            = true
      recover_soft_deleted_keys                  = true
      recover_soft_deleted_secrets               = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
  client_id       = var.client_id
  client_secret   = var.client_secret
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

provider "time" {

}
