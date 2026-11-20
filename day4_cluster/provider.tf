terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.1.0"
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">= 0.1.0"
    }
  }
}

provider "azurerm" {
  features {}
  #subscription_id = ""
}
provider "azuread" {}

provider "azuredevops" {
  org_service_url       = "https://dev.azure.com/sriramkajjayam143"
  personal_access_token = var.azdev_pat
}