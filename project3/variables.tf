variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name used for resource names"
  type        = string
  default     = "project3-cpu-monitor"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "cpu_threshold" {
  description = "CPU utilization percentage above which the alarm triggers"
  type        = number
  default     = 70
}

variable "load_delay_seconds" {
  description = "Seconds to wait after boot before the CPU load starts"
  type        = number
  default     = 300
}

variable "load_duration_seconds" {
  description = "How long the CPU load runs"
  type        = number
  default     = 1800
}

variable "alert_email" {
  description = "Optional email address for alarm notifications (leave empty to skip)"
  type        = string
  default     = ""
}
