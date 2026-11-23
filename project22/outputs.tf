output "bucket_name" {
  description = "Name of the log archive bucket"
  value       = aws_s3_bucket.archive.bucket
}

output "uploaded_logs" {
  description = "Keys of the uploaded log files"
  value       = sort([for o in aws_s3_object.logs : o.key])
}

output "lifecycle_rule_id" {
  description = "ID of the lifecycle rule"
  value       = one(aws_s3_bucket_lifecycle_configuration.archive.rule[*].id)
}
