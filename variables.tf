variable "project_id" {
  description = "The ID of the project where Workload Identity Federation will be configured"
  type        = string
}

variable "org_id" {
  description = "The ID of the organization where the new project will live"
  type        = string
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
