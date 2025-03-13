variable project_id {
  description = "The ID of the project where Workload Identity Federation will be configured"
  type = string
}

variable org_id {
  description = "The ID of the organization where the new project will live"
  type = string
}

variable heeler_aws_iam_role {
  description = "The Heeler AWS IAM role."
  type = string
}

variable heeler_aws_account_id {
  description = "The Heeler AWS Account ID."
  type = string
}
