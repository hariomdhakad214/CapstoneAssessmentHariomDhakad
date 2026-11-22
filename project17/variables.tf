variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Name prefix for resources"
  type        = string
  default     = "hariom-project17"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "log_group_name" {
  description = "CloudWatch log group that receives the application logs"
  type        = string
  default     = "/hariom/project17/app"
}

variable "log_retention_days" {
  description = "How long CloudWatch keeps the logs"
  type        = number
  default     = 1
}
