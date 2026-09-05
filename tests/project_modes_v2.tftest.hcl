mock_provider "google" {
  mock_data "google_project" {
    defaults = {
      name      = "Customer Existing Project"
      folder_id = "987654321098"
    }
  }

  mock_data "google_project_ancestry" {
    defaults = {
      org_id      = "123456789012"
      parent_id   = "987654321098"
      parent_type = "folder"
    }
  }

  mock_resource "google_service_account" {
    defaults = {
      email = "heeler-collector@heeler-existing-project.iam.gserviceaccount.com"
      name  = "projects/heeler-existing-project/serviceAccounts/heeler-collector@heeler-existing-project.iam.gserviceaccount.com"
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
  project_id            = "heeler-existing-project"
  heeler_aws_iam_role   = "arn:aws:iam::168777450829:role/heeler-gcp-wif"
  heeler_aws_account_id = "168777450829"
}

run "adopt_does_not_manage_the_existing_project" {
  command = plan

  assert {
    condition     = length(google_project.created) == 0
    error_message = "Existing-project mode must not manage the customer project."
  }

  assert {
    condition     = data.google_project.existing[0].name == "Customer Existing Project"
    error_message = "Existing-project mode must verify the selected project exists."
  }

  assert {
    condition     = google_organization_iam_member.organizationViewer.org_id == "123456789012"
    error_message = "Existing-project mode must derive the IAM target organization through folder ancestry."
  }
}

run "create_requires_billing" {
  command = plan

  variables {
    create_project = true
    org_id         = "123456789012"
  }

  expect_failures = [google_project.created[0]]
}

run "create_a_billed_project" {
  command = apply

  variables {
    create_project  = true
    org_id          = "123456789012"
    project_name    = "Heeler Security"
    billing_account = "ABCDEF-123456-ABCDEF"
  }

  assert {
    condition     = google_project.created[0].billing_account == "ABCDEF-123456-ABCDEF"
    error_message = "Create mode must attach the explicitly supplied billing account."
  }

  assert {
    condition     = google_project.created[0].deletion_policy == "ABANDON"
    error_message = "Destroy must remove project state without deleting the GCP project."
  }
}

run "create_mode_manages_explicit_project_changes" {
  command = plan

  variables {
    create_project  = true
    project_name    = "Renamed Heeler Project"
    org_id          = "999999999999"
    billing_account = "FEDCBA-654321-FEDCBA"
  }

  assert {
    condition     = google_project.created[0].name == "Renamed Heeler Project"
    error_message = "Create mode must manage an explicitly changed project name."
  }

  assert {
    condition     = google_project.created[0].org_id == "999999999999"
    error_message = "Create mode must manage an explicitly changed organization."
  }

  assert {
    condition     = google_project.created[0].billing_account == "FEDCBA-654321-FEDCBA"
    error_message = "Create mode must manage an explicitly changed billing account."
  }
}

run "enabled_apis_are_configured_to_survive_destroy" {
  command = plan

  variables {
    create_project  = true
    org_id          = "123456789012"
    billing_account = "ABCDEF-123456-ABCDEF"
  }

  assert {
    condition = alltrue([
      google_project_service.iam.disable_on_destroy == false,
      google_project_service.iamcredentials.disable_on_destroy == false,
      google_project_service.cloudresourcemanager.disable_on_destroy == false,
      google_project_service.pubsub.disable_on_destroy == false,
      google_project_service.sqladmin.disable_on_destroy == false,
      google_project_service.sts.disable_on_destroy == false,
    ])
    error_message = "Destroy must not disable APIs in the target project."
  }
}
