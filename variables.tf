variable "subscription_id" {
  description = "Azure subscription ID to deploy into."
  type        = string
}

variable "tenant_id" {
  description = "Azure tenant ID for the service principal."
  type        = string
}

variable "client_id" {
  description = "Azure AD application/client ID for the service principal."
  type        = string
}

variable "client_secret" {
  description = "Password/client secret for the service principal."
  type        = string
  sensitive   = true
}
