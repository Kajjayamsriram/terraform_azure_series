terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=5.0.0"
    }
  }
  backend "azurerm" {
    resource_group_name = "supero-rg"
    storage_account_name = "pocstorageaccount1013"
    container_name = "terraformstate"
    key = "terraform.tfstate"
    #State locking happens automatically on this blob!
  }
}
provider "azurerm" {
  features {}
  subscription_id = "eaa9d61d-1afc-49a4-a26f-b8ac0647fcb0"
}