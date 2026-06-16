variable "location" {
  type        = string
  description = "The Azure region where resources will be deployed."
  default     = "East US"
}

variable "rg_name_prefix" {
  type        = string
  description = "Prefix for the resource group names."
  default     = "my-app"
}