resource "google_service_account" "heeler_collector" {
  account_id                   = "heeler-collector"
  display_name                 = "Heeler Security Collector"
  description                  = "Service account used to collect inventory across GCP"
  create_ignore_already_exists = true
}

# Grant IAM access to the new service account at the organization level to pull inventory
resource "google_organization_iam_member" "artifactregistryReader" {
  org_id = var.org_id
  role   = "roles/artifactregistry.reader"
  member = "serviceAccount:${google_service_account.heeler_collector.email}"
}

resource "google_organization_iam_member" "securityReviewer" {
  org_id = var.org_id
  role   = "roles/iam.securityReviewer"
  member = "serviceAccount:${google_service_account.heeler_collector.email}"
}

resource "google_organization_iam_member" "folderViewer" {
  org_id = var.org_id
  role   = "roles/resourcemanager.folderViewer"
  member = "serviceAccount:${google_service_account.heeler_collector.email}"
}

resource "google_organization_iam_member" "organizationViewer" {
  org_id = var.org_id
  role   = "roles/resourcemanager.organizationViewer"
  member = "serviceAccount:${google_service_account.heeler_collector.email}"
}

# Allow Heeler's federated AWS principal to impersonate the collector service
# account so it can mint access tokens for it. Entry into the pool is gated by the
# provider's attribute_condition (a prefix match on assertion.arn), and this binding
# scopes impersonation to Heeler's AWS account.
resource "google_service_account_iam_member" "heeler_wif_user" {
  service_account_id = google_service_account.heeler_collector.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.heeler-wif-pool.name}/attribute.aws_account/${var.heeler_aws_account_id}"
}
