output "collector_service_account_email" {
  description = "Email of the Heeler collector service account."
  value       = google_service_account.heeler_collector.email
}

output "workload_identity_pool" {
  description = "Full resource name of the Workload Identity Pool."
  value       = google_iam_workload_identity_pool.heeler-wif-pool.name
}

output "workload_identity_provider" {
  description = "Full resource name of the Workload Identity Pool Provider."
  value       = google_iam_workload_identity_pool_provider.heeler-wif-provider.name
}

output "enabled_apis" {
  description = "Sorted baseline API set enabled by this module for WIF, preflight, and core inventory collection."
  value = sort([
    google_project_service.artifactregistry.service,
    google_project_service.cloudresourcemanager.service,
    google_project_service.compute.service,
    google_project_service.container.service,
    google_project_service.iam.service,
    google_project_service.iamcredentials.service,
    google_project_service.pubsub.service,
    google_project_service.serviceusage.service,
    google_project_service.sqladmin.service,
    google_project_service.storage.service,
    google_project_service.sts.service,
  ])
}

# Assembled external_account credential JSON, equivalent to
# `gcloud iam workload-identity-pools create-cred-config ... --aws`. Paste this into
# the "Workload Identity Configuration" field when adding the org/project in Heeler:
#   terraform output -raw workload_identity_config
output "workload_identity_config" {
  description = "Workload Identity Configuration JSON to paste into the Heeler app."
  value = jsonencode({
    type               = "external_account"
    audience           = "//iam.googleapis.com/${google_iam_workload_identity_pool_provider.heeler-wif-provider.name}"
    subject_token_type = "urn:ietf:params:aws:token-type:aws4_request"
    token_url          = "https://sts.googleapis.com/v1/token"
    credential_source = {
      environment_id                 = "aws1"
      region_url                     = "http://169.254.169.254/latest/meta-data/placement/availability-zone"
      url                            = "http://169.254.169.254/latest/meta-data/iam/security-credentials"
      regional_cred_verification_url = "https://sts.{region}.amazonaws.com?Action=GetCallerIdentity&Version=2011-06-15"
    }
    service_account_impersonation_url = "https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/${google_service_account.heeler_collector.email}:generateAccessToken"
  })
}
