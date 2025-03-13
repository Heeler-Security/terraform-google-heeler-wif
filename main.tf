provider "google" {
  project = var.project_id
}

resource "google_project" "heeler" {
  name       = "Heeler Security"
  project_id = var.project_id
  org_id     = var.org_id
}

resource "google_iam_workload_identity_pool" "heeler-wif-pool" {
  workload_identity_pool_id = "heeler-aws-access"
  display_name              = "Heeler AWS"
  description               = "Identity pool to allow access from Heeler Security"
  disabled                  = false
}

resource "google_iam_workload_identity_pool_provider" "heeler-wif-provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.heeler-wif-pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "heeler-prod"
  display_name                       = "Heeler Production Access"
  description                        = "AWS identity pool provider for Heeler Production"
  disabled                           = false
  attribute_mapping                  = {
    "google.subject"        = "assertion.arn"
    "attribute.aws_account" = "assertion.account"
    "attribute.arn"         = "assertion.arn"
  }
  attribute_condition = "assertion.arn.startsWith('${var.heeler_aws_iam_role}')"
  aws {
    account_id = ${var.heeler_aws_account_id}
  }
}

