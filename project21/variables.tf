variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Name prefix for resources"
  type        = string
  default     = "hariom-project21"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "cpu_threshold" {
  description = "CPU percentage drawn as a reference line on the dashboard"
  type        = number
  default     = 70
}
