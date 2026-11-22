variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Name prefix for resources"
  type        = string
  default     = "hariom-project16"
}

variable "certificate_domain" {
  description = "Common name placed in the self-signed certificate"
  type        = string
  default     = "project16.example.com"
}
