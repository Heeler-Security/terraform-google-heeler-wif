terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

variable "project_id" {
  type = string
}

variable "org_id" {
  type = string
}

variable "project_name" {
  type = string
}

variable "billing_account" {
  type = string
}

resource "google_project" "heeler" {
  name            = var.project_name
  project_id      = var.project_id
  org_id          = var.org_id
  billing_account = var.billing_account
}
