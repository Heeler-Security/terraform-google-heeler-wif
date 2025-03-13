# Heeler GCP Setup

This terraform module enables all required services and configures Workload Identity Federation that allows Heeler to connect to the GCP projects.

## Requirements

No requirements.

## Providers

| Name                                                      | Version |
| --------------------------------------------------------- | ------- |
| <a name="provider_google"></a> [google](#provider_google) | 6.21.0  |

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
| [google_project_service.cloudresourcemanager](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service)                                        | resource |
| [google_project_service.iam](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service)                                                         | resource |
| [google_project_service.iamcredentials](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service)                                              | resource |
| [google_project_service.pubsub](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service)                                                      | resource |
| [google_project_service.sqladmin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service)                                                    | resource |
| [google_project_service.sts](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service)                                                         | resource |
| [google_service_account.heeler_collector](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account)                                            | resource |

## Inputs

| Name                                                            | Description                                                | Type     | Default              | Required |
| --------------------------------------------------------------- | ---------------------------------------------------------- | -------- | -------------------- | :------: |
| <a name="input_org_id"></a> [org_id](#input_org_id)             | The ID of the organization where the new project will live | `string` | n/a                  |   yes    |
| <a name="input_project_id"></a> [project_id](#input_project_id) | The ID of the project where WIF will be configured         | `string` | `"heeler-collector"` |    no    |

## Outputs

No outputs.
