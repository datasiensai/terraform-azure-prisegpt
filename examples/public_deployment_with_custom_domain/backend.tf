terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "jlterrastatestorage"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}