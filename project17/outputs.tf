output "ec2_instance_id" {
  description = "ID of the instance that forwards logs"
  value       = aws_instance.app.id
}

output "log_group_name" {
  description = "CloudWatch log group receiving the logs"
  value       = aws_cloudwatch_log_group.app.name
}

output "dashboard_name" {
  description = "CloudWatch dashboard showing the logs"
  value       = aws_cloudwatch_dashboard.logs.dashboard_name
}

output "dashboard_url" {
  description = "Console link to the dashboard"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards/dashboard/${aws_cloudwatch_dashboard.logs.dashboard_name}"
}
