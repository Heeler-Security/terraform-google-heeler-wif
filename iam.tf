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

# Project level permissions
resource "google_project_iam_member" "workloadIdentityUser" {
  project = var.project_id
  role    = "roles/iam.workloadIdentityUser"
  member = "serviceAccount:${google_service_account.heeler_collector.email}"
}
