# Heeler GCP Setup

This Terraform module configures Workload Identity Federation for a Heeler GCP organization connection and enables the supported 11-API baseline in its dedicated project. Manually configured single-project connections use the same API baseline, but this module's IAM grants are organization-scoped.

## Requirements

- Terraform `>= 1.7.5, < 2.0.0`
- HashiCorp Google provider `>= 6.22.0, < 9.0.0`

The tested compatibility matrix is:

| Terraform | Google provider |
| --- | --- |
| 1.7.5 | 6.22.0 |
| 1.16.1 | 8.1.0 |

## Providers

| Name                                                      | Version |
| --------------------------------------------------------- | ------- |
| <a name="provider_google"></a> [google](#provider_google) | >= 6.22.0, < 9.0.0 |

## Modules

No modules.

## Resources

| Name                                                                                                                                                                                 | Type     |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------- |
| [google_iam_workload_identity_pool.heeler-wif-pool](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool)                       | resource |
| [google_iam_workload_identity_pool_provider.heeler-wif-provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool_provider) | resource |
| [google_organization_iam_member.artifactregistryReader](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_member)                      | resource |
| [google_organization_iam_member.folderViewer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_member)                                | resource |
| [google_organization_iam_member.organizationViewer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_member)                          | resource |
| [google_organization_iam_member.securityReviewer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_member)                            | resource |
| [google_project.heeler](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project)                                                                      | resource |
| [google_project_iam_member.workloadIdentityUser](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member)                                  | resource |
| [google_project_service (11 baseline APIs)](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service)                                        | resource |
| [google_service_account.heeler_collector](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account)                                            | resource |

## Inputs

| Name                                                            | Description                                                | Type     | Default              | Required |
| --------------------------------------------------------------- | ---------------------------------------------------------- | -------- | -------------------- | :------: |
| <a name="input_org_id"></a> [org_id](#input_org_id)             | The ID of the organization where the new project will live | `string` | n/a                  |   yes    |
| <a name="input_project_id"></a> [project_id](#input_project_id) | The ID of the project where WIF will be configured         | `string` | `"heeler-collector"` |    no    |

## Outputs

| Name | Description |
| --- | --- |
| `collector_service_account_email` | Email of the Heeler collector service account. |
| `enabled_apis` | Sorted baseline API set enabled by the module. |
| `workload_identity_config` | External-account credential JSON to paste into Heeler. |
| `workload_identity_pool` | Full resource name of the WIF pool. |
| `workload_identity_provider` | Full resource name of the WIF provider. |

## Enabled API baseline

Project and organization connections use the same per-project baseline. Organization scope changes IAM grants and project discovery, not the APIs needed in each harvested project. This module implements the organization-scoped setup; use the documented manual setup for a project-scoped connection.

The module enables `artifactregistry.googleapis.com`, `cloudresourcemanager.googleapis.com`, `compute.googleapis.com`, `container.googleapis.com`, `iam.googleapis.com`, `iamcredentials.googleapis.com`, `pubsub.googleapis.com`, `serviceusage.googleapis.com`, `sqladmin.googleapis.com`, `storage.googleapis.com`, and `sts.googleapis.com`.

These services cover WIF, connection preflight, API visibility checks, and the core inventory paths. Heeler can collect additional resource types when their service APIs are already enabled; the module does not enable every Google Cloud service. APIs remain enabled when the module is destroyed to avoid disrupting other workloads in the project.

## Upgrading Terraform or the provider

Keep Terraform and the Google provider within the supported ranges above, run `terraform init -upgrade`, and review `terraform plan` before applying. Do not move to Google provider 9.x or Terraform 2.x until the module publishes a compatible tested range. CI runs the module contract suite at both ends of the tested matrix.
