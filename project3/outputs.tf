output "ec2_instance_id" {
  description = "ID of the monitored EC2 instance"
  value       = aws_instance.monitored.id
}

output "alarm_name" {
  description = "Name of the CloudWatch CPU alarm"
  value       = aws_cloudwatch_metric_alarm.high_cpu.alarm_name
}

output "sns_topic_arn" {
  description = "SNS topic that receives alarm notifications"
  value       = aws_sns_topic.alerts.arn
}

output "check_alarm_command" {
  description = "Command to check the alarm state"
  value       = "aws cloudwatch describe-alarms --alarm-names ${aws_cloudwatch_metric_alarm.high_cpu.alarm_name} --region ${var.aws_region} --query MetricAlarms[0].StateValue"
}
