variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "bucket_name" {
  description = "Name of the S3 bucket to plan"
  type        = string
  default     = "hariom-project12-ci-plan-demo"
}

variable "ci_mode" {
  description = "Skip AWS credential and account lookups (used by the CI pipeline for plan-only runs)"
  type        = bool
  default     = false
}
