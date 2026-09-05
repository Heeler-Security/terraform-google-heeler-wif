provider "google" {
  project = var.project_id
}

data "google_project" "existing" {
  count = var.create_project ? 0 : 1

  project_id = var.project_id
}

data "google_project_ancestry" "existing" {
  count = var.create_project ? 0 : 1

  project = var.project_id
}

locals {
  # Workload Identity Federation evaluates the STS assumed-role ARN
  # (arn:aws:sts::<account>:assumed-role/<role-name>/<session>), not the IAM role
  # ARN. Derive the assumed-role prefix from the supplied IAM role ARN so the
  # attribute condition matches the exact role for any session name.
  heeler_role_name           = regex(":role/(.+)$", var.heeler_aws_iam_role)[0]
  heeler_assumed_role_prefix = "arn:aws:sts::${var.heeler_aws_account_id}:assumed-role/${local.heeler_role_name}/"
  target_org_id              = var.create_project ? var.org_id : data.google_project_ancestry.existing[0].org_id
}

resource "terraform_data" "target_organization" {
  input = local.target_org_id

  lifecycle {
    precondition {
      condition     = try(trimspace(local.target_org_id) != "", false)
      error_message = "The target project must belong to a GCP organization."
    }
  }
}

removed {
  from = google_project.heeler

  lifecycle {
    destroy = false
  }
}

resource "google_project" "created" {
  count = var.create_project ? 1 : 0

  name            = var.project_name
  project_id      = var.project_id
  org_id          = var.org_id
  billing_account = var.billing_account
  deletion_policy = "ABANDON"

  lifecycle {
    precondition {
      condition     = try(trimspace(var.org_id) != "", false)
      error_message = "org_id is required when create_project is true."
    }

    precondition {
      condition     = try(trimspace(var.billing_account) != "", false)
      error_message = "billing_account is required when create_project is true."
    }
  }
}

resource "google_iam_workload_identity_pool" "heeler-wif-pool" {
  workload_identity_pool_id = "heeler-aws-access"
  display_name              = "Heeler AWS"
  description               = "Identity pool to allow access from Heeler Security"
  disabled                  = false

  depends_on = [google_project_service.iam]
}

resource "google_iam_workload_identity_pool_provider" "heeler-wif-provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.heeler-wif-pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "heeler-prod"
  display_name                       = "Heeler Production Access"
  description                        = "AWS identity pool provider for Heeler Production"
  disabled                           = false
  attribute_mapping = {
    "google.subject"        = "assertion.arn"
    "attribute.aws_account" = "assertion.account"
    "attribute.arn"         = "assertion.arn"
  }
  attribute_condition = "assertion.arn.startsWith('${local.heeler_assumed_role_prefix}')"
  aws {
    account_id = var.heeler_aws_account_id
  }
}
