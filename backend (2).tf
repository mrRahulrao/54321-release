terraform {
  required_version = ">= 1.6.0"
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-54321"
    storage_account_name = "tfstate54321"
    container_name       = "state"
    key                  = "appraps/prod.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}
