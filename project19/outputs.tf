output "bucket_name" {
  description = "Name of the backup bucket"
  value       = aws_s3_bucket.backup.bucket
}

output "list_backups_command" {
  description = "Command that lists the backup files"
  value       = "aws s3 ls s3://${aws_s3_bucket.backup.bucket}/logs/ --recursive --region ${var.aws_region}"
}
