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
  name     = "${var.rg_name_prefix}-rg-example"
  location = var.location
  tags = {
    Environment = "Dev"
    Project     = "Infrastructure"
  }
}

resource "azurerm_resource_group" "vnet_resource" {
  name     = "${var.rg_name_prefix}-rg-network"
  location = var.location
  tags = {
    Environment = "Dev"
    Project     = "Infrastructure"
  }
}
