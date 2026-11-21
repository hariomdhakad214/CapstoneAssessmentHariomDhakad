variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "hariom-project13-app"
}
