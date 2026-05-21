# Simplecloud Terraform

This project contains a small Terraform setup for deploying Azure infrastructure with the `azurerm` provider. It is configured for non-interactive authentication so Terraform can run locally or from Azure DevOps without prompting for `az login`.

## Features

- Uses the official HashiCorp AzureRM provider.
- Authenticates with an Azure service principal using tenant ID, subscription ID, client ID, and client secret.
- Stores reusable Terraform input values in a separate `terraform.tfvars` file.
- Keeps secrets and Terraform state files out of source control through `.gitignore`.
- Creates an Azure resource group named `my-resource-group` in the `East US` region.
- Includes an Azure DevOps pipeline with separate plan, approval, and apply stages.

## Project Structure

```text
.
|-- main.tf
|-- variables.tf
|-- terraform.tfvars
|-- azure-pipelines.yml
|-- .gitignore
|-- .terraform.lock.hcl
```

### `main.tf`

Defines the Terraform provider and Azure resource.

The AzureRM provider uses these variables:

- `subscription_id`
- `tenant_id`
- `client_id`
- `client_secret`

The current resource definition creates one Azure resource group:

```hcl
resource "azurerm_resource_group" "example" {
  name     = "my-resource-group"
  location = "East US"
}
```

### `variables.tf`

Declares all input variables required by the provider. The `client_secret` variable is marked as sensitive so Terraform hides it in normal CLI output.

### `terraform.tfvars`

Stores the actual variable values for local runs. Terraform automatically loads this file, so you only need to enter the values once.

Example format:

```hcl
subscription_id = "your-subscription-id"
tenant_id       = "your-tenant-id"
client_id       = "your-client-id"
client_secret   = "your-client-secret"
```

Do not commit this file because it contains credentials.

### `.gitignore`

Excludes local and sensitive Terraform files:

- `terraform.tfvars`
- `*.tfstate`
- `*.tfstate.*`
- `.terraform/`

### `azure-pipelines.yml`

Defines an Azure DevOps pipeline that runs on the `main` branch. It accepts a runtime parameter (`action`) to choose between `apply` and `destroy` flows.

Pipeline stages:

1. `ConfirmAction`: pauses the pipeline for manual validation of the selected action (`apply` or `destroy`).
2. `Plan`: installs Terraform (v1.7.5), runs `terraform init`, and creates a Terraform plan (runs only for `apply`).
3. `Approval`: pauses the pipeline for manual approval before making changes (runs only for `apply`).
4. `Apply`: installs Terraform, runs `terraform init`, and applies the Terraform configuration (runs only for `apply`).
5. `Destroy`: installs Terraform, runs `terraform init`, and tears down the infrastructure (runs only for `destroy`).

The pipeline references a variable group named `SimpleCloud_Variable_Group_Secrets` for Azure credentials.

Expected secret variables:

- `ARM_CLIENT_ID`
- `ARM_CLIENT_SECRET`
- `ARM_SUBSCRIPTION_ID`
- `ARM_TENANT_ID`

## Prerequisites

- Terraform installed locally.
- An Azure subscription.
- An Azure service principal with permissions to create resources in the target subscription.
- The following service principal details:
  - Subscription ID
  - Tenant ID
  - Client ID
  - Client secret

## Local Usage

Initialize Terraform:

```powershell
terraform init
```

Review the planned changes:

```powershell
terraform plan
```

Apply the infrastructure:

```powershell
terraform apply
```

Destroy the infrastructure when no longer needed:

```powershell
terraform destroy
```

## Authentication

This project avoids interactive login prompts by passing service principal credentials directly into the AzureRM provider through Terraform variables.

For local usage, add the values once in `terraform.tfvars`.

For Azure DevOps, store credentials as secret variables in the `SimpleCloud_Variable_Group_Secrets` variable group.

## Security Notes

- Never commit `terraform.tfvars`.
- Never commit `.tfstate` files because they may contain sensitive information.
- Rotate the client secret if it is exposed.
- Prefer secret variables or secure variable groups in CI/CD systems.
- For production usage, consider remote Terraform state storage with state locking, such as Azure Storage with blob locking support.

## Current Infrastructure

At present, this project deploys:

- One Azure resource group:
  - Name: `my-resource-group`
  - Location: `East US`

More resources can be added to `main.tf` or split into additional `.tf` files as the project grows.
