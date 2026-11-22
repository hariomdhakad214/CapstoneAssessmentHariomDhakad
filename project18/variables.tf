variable "app_version" {
  description = "Version recorded in the release manifest"
  type        = string
  default     = "1.0.0"
}

variable "environment" {
  description = "Environment name recorded in the release manifest"
  type        = string
  default     = "production"
}
