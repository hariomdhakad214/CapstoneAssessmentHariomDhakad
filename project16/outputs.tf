output "https_url" {
  description = "HTTPS URL of the load balancer"
  value       = "https://${aws_lb.main.dns_name}"
}

output "http_url_should_fail" {
  description = "HTTP URL, which should not connect because port 80 is blocked"
  value       = "http://${aws_lb.main.dns_name}"
}

output "certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = aws_acm_certificate.cert.arn
}
