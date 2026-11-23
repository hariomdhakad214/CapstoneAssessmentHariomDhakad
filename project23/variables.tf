variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Name prefix for resources"
  type        = string
  default     = "hariom-project23"
}

variable "bucket_name" {
  description = "Globally unique name of the demo bucket"
  type        = string
  default     = "hariom-project23-role-demo-590507089733"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}
