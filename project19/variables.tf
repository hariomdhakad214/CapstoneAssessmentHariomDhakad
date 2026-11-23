variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "bucket_name" {
  description = "Globally unique name of the backup bucket"
  type        = string
  default     = "hariom-project19-backup-590507089733"
}

variable "retention_days" {
  description = "Days after which backups under logs/ expire"
  type        = number
  default     = 7
}
