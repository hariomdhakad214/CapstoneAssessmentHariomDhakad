output "bucket_name" {
  description = "Bucket the role can access"
  value       = aws_s3_bucket.demo.bucket
}

output "ec2_instance_id" {
  description = "Instance that uses the role"
  value       = aws_instance.app.id
}

output "role_name" {
  description = "IAM role attached to the instance"
  value       = aws_iam_role.s3_access.name
}

output "read_report_command" {
  description = "Command that prints the CLI test output saved by the instance"
  value       = "aws s3 cp s3://${aws_s3_bucket.demo.bucket}/reports/cli-test-output.txt - --region ${var.aws_region}"
}
