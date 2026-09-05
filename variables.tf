variable "project_id" {
  description = "The ID of the project where Workload Identity Federation will be configured"
  type        = string
}

variable "create_project" {
  description = "Create and manage project_id when true. Leave false to use an existing project without managing it."
  type        = bool
  default     = false
}

variable "project_name" {
  description = "Display name for a newly created project. Ignored when create_project is false."
  type        = string
  default     = "Heeler Security"
}

variable "billing_account" {
  description = "Billing account for a newly created project. Required when create_project is true and never managed in existing-project mode."
  type        = string
  default     = null
  nullable    = true
}

variable "org_id" {
  description = "Organization where a new project will be created. Existing-project mode derives this from the project."
  type        = string
  default     = null
  nullable    = true
}

variable "heeler_aws_iam_role" {
  description = "The Heeler AWS IAM role ARN, e.g. arn:aws:iam::<account-id>:role/<role-name>. Federation matches the corresponding STS assumed-role identity."
  type        = string

  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]+:role/.+$", var.heeler_aws_iam_role))
    error_message = "heeler_aws_iam_role must be an IAM role ARN of the form arn:aws:iam::<account-id>:role/<role-name>."
  }
}

variable "heeler_aws_account_id" {
  description = "The Heeler AWS Account ID."
  type        = string
}
