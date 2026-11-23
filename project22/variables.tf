variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "bucket_name" {
  description = "Globally unique name of the log archive bucket"
  type        = string
  default     = "hariom-project22-log-archive-590507089733"
}

variable "ia_after_days" {
  description = "Days before logs move to the cheaper Standard-IA storage class"
  type        = number
  default     = 30
}

variable "glacier_after_days" {
  description = "Days before logs move to Glacier Flexible Retrieval"
  type        = number
  default     = 90
}

variable "expire_after_days" {
  description = "Days after which logs are deleted"
  type        = number
  default     = 365
}
