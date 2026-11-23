output "alb_url" {
  description = "Public address of the load balancer"
  value       = "http://${aws_lb.main.dns_name}"
}

output "instance_ids" {
  description = "IDs of the web servers"
  value       = aws_instance.web[*].id
}

output "target_group_arn" {
  description = "ARN of the target group with the health checks"
  value       = aws_lb_target_group.web.arn
}
