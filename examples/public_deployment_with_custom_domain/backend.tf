terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "bkterrastatestorage"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}