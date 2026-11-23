output "ec2_instance_id" {
  description = "ID of the monitored instance"
  value       = aws_instance.monitored.id
}

output "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.metrics.dashboard_name
}

output "dashboard_url" {
  description = "Console link to the dashboard"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards/dashboard/${aws_cloudwatch_dashboard.metrics.dashboard_name}"
}
