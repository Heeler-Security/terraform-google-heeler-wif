mock_provider "google" {
  mock_resource "google_service_account" {
    defaults = {
      email = "heeler-collector@heeler-security-test.iam.gserviceaccount.com"
      name  = "projects/heeler-security-test/serviceAccounts/heeler-collector@heeler-security-test.iam.gserviceaccount.com"
    }
  }
}

run "baseline_api_contract" {
  command = apply

  variables {
    heeler_aws_account_id = "123456789012"
    heeler_aws_iam_role   = "arn:aws:iam::123456789012:role/heeler-gcp-wif"
    org_id                = "123456789012"
    project_id            = "heeler-security-test"
  }

  assert {
    condition = toset(output.enabled_apis) == toset([
      "artifactregistry.googleapis.com",
      "cloudresourcemanager.googleapis.com",
      "compute.googleapis.com",
      "container.googleapis.com",
      "iam.googleapis.com",
      "iamcredentials.googleapis.com",
      "pubsub.googleapis.com",
      "serviceusage.googleapis.com",
      "sqladmin.googleapis.com",
      "storage.googleapis.com",
      "sts.googleapis.com",
    ])
    error_message = "The public module must enable the supported 11-API baseline."
  }
}
