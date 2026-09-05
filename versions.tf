terraform {
  required_version = ">= 1.7.5, < 2.0.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.22.0, < 9.0.0"
    }
  }
}
