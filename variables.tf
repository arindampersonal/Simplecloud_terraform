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

variable "common_tags" {
  type        = map(string)
  description = "Common tags to apply to all resources."
  default = {
    Environment = "Dev"
    Project     = "Infrastructure"
  }
}