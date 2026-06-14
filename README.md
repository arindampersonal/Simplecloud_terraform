# Simplecloud Terraform

A compact Terraform project for managing Azure infrastructure with the
HashiCorp AzureRM provider and an Azure DevOps pipeline.

The current configuration manages two Azure resource groups in `East US`, stores
Terraform state in an Azure Storage backend, and uses standard Azure service
principal environment variables for non-interactive authentication.

## What This Project Does

- Uses Terraform with the `hashicorp/azurerm` provider.
- Authenticates through `ARM_*` environment variables instead of hardcoded
  credentials.
- Stores Terraform state remotely in an Azure Storage Account backend.
- Creates and manages two Azure resource groups.
- Includes an Azure DevOps pipeline with separate apply and destroy flows.
- Saves Terraform plan files as pipeline artifacts so apply/destroy runs the
  reviewed plan.
- Uses manual approval gates before changing or destroying infrastructure.
- Sends a failure notification through a configurable webhook.

## Repository Structure

```text
.
|-- main.tf
|-- backend.tf
|-- variables.tf
|-- azure-pipelines.yml
|-- .gitignore
|-- .terraform.lock.hcl
|-- README.md
```

### `main.tf`

Defines the AzureRM provider and the Azure resources managed by this project.

Current resources:

```hcl
resource "azurerm_resource_group" "example" {
  name     = "my-resource-group"
  location = "East US"
}

resource "azurerm_resource_group" "vnet-resource" {
  name     = "my-vnet-resource-group"
  location = "East US"
}
```

The provider block does not contain credentials. Terraform automatically reads
Azure authentication values from environment variables such as
`ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_SUBSCRIPTION_ID`, and
`ARM_TENANT_ID`.

### `backend.tf`

Configures remote Terraform state using the AzureRM backend:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstatesimplecloud"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
```

The backend resources must already exist before running `terraform init`.

### `variables.tf`

This file is currently empty because the active configuration does not define
custom input variables. Authentication is handled through environment variables.

### `azure-pipelines.yml`

Defines the Azure DevOps CI/CD flow.

Pipeline highlights:

- Runs on changes to the `main` branch.
- Accepts a runtime `action` parameter:
  - `apply`
  - `destroy`
- Uses Terraform `1.7.5`.
- Caches the Terraform binary between stages.
- Uses the variable group `SimpleCloud_Variable_Group_Secrets`.
- Publishes binary plan files as pipeline artifacts.
- Applies the exact plan that was reviewed and approved.
- Requires manual confirmation before either action.
- Requires an additional approval before apply or destroy.
- Sends a failure notification through `NOTIFY_WEBHOOK_URL`.

Pipeline stages:

| Stage | Runs For | Purpose |
| --- | --- | --- |
| `ConfirmAction` | apply, destroy | Manual confirmation of selected action |
| `Plan` | apply | Runs `terraform plan` and publishes `tfplan` |
| `Approval` | apply | Manual approval after reviewing the plan |
| `Apply` | apply | Applies the saved plan artifact |
| `DestroyPlan` | destroy | Creates and publishes a destroy preview |
| `DestroyApproval` | destroy | Final manual approval before destruction |
| `Destroy` | destroy | Applies the saved destroy plan |
| `NotifyFailure` | failures | Sends a webhook notification if plan/apply/destroy fails |

## Managed Infrastructure

At the moment, this project manages:

| Terraform Resource | Azure Name | Location |
| --- | --- | --- |
| `azurerm_resource_group.example` | `my-resource-group` | `East US` |
| `azurerm_resource_group.vnet-resource` | `my-vnet-resource-group` | `East US` |

## Prerequisites

- Terraform installed locally, preferably the same version used by the pipeline:
  `1.7.5`.
- An Azure subscription.
- An Azure service principal with permission to manage the target resources.
- Existing Azure Storage backend resources:
  - Resource group: `tfstate-rg`
  - Storage account: `tfstatesimplecloud`
  - Blob container: `tfstate`
- Azure DevOps variable group: `SimpleCloud_Variable_Group_Secrets`.

Required Azure authentication variables:

```text
ARM_CLIENT_ID
ARM_CLIENT_SECRET
ARM_SUBSCRIPTION_ID
ARM_TENANT_ID
```

Optional notification variable:

```text
NOTIFY_WEBHOOK_URL
```

## Local Usage

Set the Azure service principal environment variables before running Terraform.

PowerShell example:

```powershell
$env:ARM_CLIENT_ID = "<client-id>"
$env:ARM_CLIENT_SECRET = "<client-secret>"
$env:ARM_SUBSCRIPTION_ID = "<subscription-id>"
$env:ARM_TENANT_ID = "<tenant-id>"
```

Initialize Terraform and connect to the remote backend:

```powershell
terraform init
```

Preview changes:

```powershell
terraform plan
```

Apply changes:

```powershell
terraform apply
```

Destroy managed infrastructure:

```powershell
terraform destroy
```

## Azure DevOps Usage

1. Create or update the `SimpleCloud_Variable_Group_Secrets` variable group.
2. Add the required `ARM_*` variables as secrets.
3. Add `NOTIFY_WEBHOOK_URL` if failure notifications should be sent.
4. Run the pipeline from Azure DevOps.
5. Choose the desired `action`: `apply` or `destroy`.
6. Review the generated Terraform plan.
7. Approve the manual validation step only when the plan is correct.

## Security Notes

- Do not hardcode Azure credentials in Terraform files.
- Keep service principal secrets in Azure DevOps secret variables.
- Do not commit local `.tfvars` files containing credentials.
- Do not commit local `.tfstate` files because state can contain sensitive data.
- Rotate the service principal secret immediately if it is exposed.
- Prefer remote state with locking for shared environments.
- Review destroy plans carefully before approving the final destroy stage.

## Notes For Future Changes

- Add new Azure resources in `main.tf` or split them into separate `.tf` files as
  the project grows.
- Add variables to `variables.tf` when values need to differ across
  environments.
- Keep the pipeline Terraform version and local Terraform version aligned.
- If backend settings change, run `terraform init -reconfigure`.
