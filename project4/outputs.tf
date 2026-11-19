output "iam_username" {
  description = "Created IAM username"
  value       = aws_iam_user.s3_read_user.name
}

output "iam_user_arn" {
  description = "Created IAM user ARN"
  value       = aws_iam_user.s3_read_user.arn
}
