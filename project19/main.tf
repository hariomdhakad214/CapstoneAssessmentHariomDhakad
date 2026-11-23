resource "aws_s3_bucket" "backup" {
  bucket = var.bucket_name

  # Lets terraform destroy remove the backup files too
  force_destroy = true

  tags = {
    Name    = "Project19 Scheduled Backup"
    Project = "Project19"
  }
}

resource "aws_s3_bucket_public_access_block" "backup" {
  bucket = aws_s3_bucket.backup.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "backup" {
  bucket = aws_s3_bucket.backup.id

  rule {
    id     = "expire-old-log-backups"
    status = "Enabled"

    filter {
      prefix = "logs/"
    }

    expiration {
      days = var.retention_days
    }
  }
}
