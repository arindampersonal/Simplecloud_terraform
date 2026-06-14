terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  # No credentials here!
  # Terraform reads ARM_* env vars automatically from pipeline
}

resource "azurerm_resource_group" "example" {
  name     = "my-resource-group"
  location = "East US"
}
resource "azurerm_resource_group" "vnet-resource" {
  name     = "my-vnet-resource-group"
  location = "East US"
}