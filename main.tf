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
  skip_provider_registration = true
  # No credentials here!
  # Terraform reads ARM_* env vars automatically from pipeline
}

resource "azurerm_resource_group" "example" {
  name     = "my-resource-group"
  location = "East US"
}