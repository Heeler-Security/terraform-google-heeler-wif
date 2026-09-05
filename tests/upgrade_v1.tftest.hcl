mock_provider "google" {
  mock_data "google_project" {
    defaults = {
      name = "Existing v1 Project"
    }
  }

  mock_data "google_project_ancestry" {
    defaults = {
      org_id      = "123456789012"
      parent_id   = "123456789012"
      parent_type = "organization"
    }
  }

  mock_resource "google_service_account" {
    defaults = {
      email = "heeler-collector@heeler-v1-project.iam.gserviceaccount.com"
      name  = "projects/heeler-v1-project/serviceAccounts/heeler-collector@heeler-v1-project.iam.gserviceaccount.com"
    }
  }

  mock_resource "google_iam_workload_identity_pool" {
    defaults = {
      name = "projects/123456789012/locations/global/workloadIdentityPools/heeler-aws-access"
    }
  }

  mock_resource "google_iam_workload_identity_pool_provider" {
    defaults = {
      name = "projects/123456789012/locations/global/workloadIdentityPools/heeler-aws-access/providers/heeler-prod"
    }
  }
}

variables {
  project_id            = "heeler-v1-project"
  org_id                = "123456789012"
  heeler_aws_iam_role   = "arn:aws:iam::168777450829:role/heeler-gcp-wif"
  heeler_aws_account_id = "168777450829"
}

run "seed_v1_project_state" {
  command = apply

  module {
    source = "./tests/fixtures/v1"
  }

  variables {
    project_name    = "Existing v1 Project"
    billing_account = "ABCDEF-123456-ABCDEF"
  }
}

run "upgrade_v1_to_safe_adopt_mode" {
  command = apply

  variables {
    create_project = false
  }

  assert {
    condition     = length(google_project.created) == 0
    error_message = "The safe v2 upgrade must not replace the v1 customer project."
  }
}

run "second_upgrade_plan_is_clean" {
  command = plan

  variables {
    create_project = false
  }
}
