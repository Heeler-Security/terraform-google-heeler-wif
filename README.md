# Heeler GCP Workload Identity Federation

This module configures a GCP project for Heeler inventory collection with Workload Identity Federation (WIF). Version 2 separates existing-project adoption from new-project creation so Terraform never needs to own a customer project just to configure Heeler.

## Requirements

- Terraform 1.7 or newer
- HashiCorp Google provider 6.22 or newer, below the next major version 9

## Use an existing project (default)

Existing-project mode reads the project to verify it exists and derives its organization for IAM grants. It does not add the project to Terraform state or manage its name, organization placement, billing association, or deletion lifecycle. Terraform also leaves the APIs enabled by this module active when the module is destroyed.

```hcl
module "heeler" {
  source  = "Heeler-Security/heeler-wif/google"
  version = "~> 2.0"

  project_id            = "existing-heeler-project"
  heeler_aws_iam_role   = "arn:aws:iam::168777450829:role/heeler-gcp-wif"
  heeler_aws_account_id = "168777450829"
}
```

Run `terraform plan` and confirm that there is no `google_project` resource in the planned changes. No project import is required in version 2.

## Create a project

Creation is opt-in and requires an explicit billing account:

```hcl
module "heeler" {
  source  = "Heeler-Security/heeler-wif/google"
  version = "~> 2.0"

  project_id            = "new-heeler-project"
  org_id                = "123456789012"
  heeler_aws_iam_role   = "arn:aws:iam::168777450829:role/heeler-gcp-wif"
  heeler_aws_account_id = "168777450829"

  create_project  = true
  project_name    = "Heeler Security"
  billing_account = "ABCDEF-123456-ABCDEF"
}
```

The created project uses `deletion_policy = "ABANDON"`. Destroying the module removes the project from Terraform state but does not delete it. Delete the project separately only when that is your explicit intent.

## Upgrade from 1.0.2

Version 2 is a major release because version 1 always managed `google_project.heeler`.

The safe default is adoption. When upgrading without `create_project = true`, the module's Terraform `removed` block removes the old `google_project.heeler` address from state with `destroy = false`. The real GCP project is retained and becomes customer-managed. Review the plan for this message before applying:

```text
google_project.heeler will no longer be managed by Terraform, but will not be destroyed
```

To continue managing a project that version 1 created:

1. Add `create_project = true`, the project's current `project_name`, and its current `billing_account` to the module block.
2. Upgrade the module and initialize it.
3. Move the existing state address before planning:

   ```bash
   terraform state mv \
     'module.heeler.google_project.heeler' \
     'module.heeler.google_project.created[0]'
   ```

4. Run `terraform plan` and review every project change before applying.

If the module is used directly rather than through `module "heeler"`, omit the `module.heeler.` prefix from both state addresses.

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|:---:|
| `project_id` | Project where WIF and the collector are configured. | `string` | — | yes |
| `org_id` | Organization where a new project will be created; derived from an existing project. | `string` | `null` | no |
| `heeler_aws_iam_role` | Heeler IAM role ARN used by WIF. | `string` | — | yes |
| `heeler_aws_account_id` | AWS account containing the Heeler IAM role. | `string` | — | yes |
| `create_project` | Create and manage `project_id`; leave false to use an existing project without managing it. | `bool` | `false` | no |
| `project_name` | Display name for a project created by the module. | `string` | `"Heeler Security"` | no |
| `billing_account` | Billing account required for a project created by the module. | `string` | `null` | no |

## Outputs

| Name | Description |
|---|---|
| `collector_service_account_email` | Heeler collector service-account email. |
| `workload_identity_pool` | Full Workload Identity Pool resource name. |
| `workload_identity_provider` | Full Workload Identity Provider resource name. |
| `workload_identity_config` | External-account JSON to paste into Heeler. |

After apply, copy the connection configuration with:

```bash
terraform output -raw workload_identity_config
```

## Validate the module

```bash
terraform fmt -check -recursive
terraform init
terraform validate
terraform test
./tests/assert-clean-upgrade-plan.sh
```
