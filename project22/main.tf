resource "aws_s3_bucket" "archive" {
  bucket = var.bucket_name

  # Lets terraform destroy remove the archived logs too
  force_destroy = true

  tags = {
    Name    = "Project22 Log Archive"
    Project = "Project22"
  }
}

resource "aws_s3_bucket_public_access_block" "archive" {
  bucket = aws_s3_bucket.archive.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Upload the sample log files under logs/
resource "aws_s3_object" "logs" {
  for_each = fileset("${path.module}/sample-logs", "*.log")

  bucket = aws_s3_bucket.archive.id
  key    = "logs/${each.value}"
  source = "${path.module}/sample-logs/${each.value}"
  etag   = filemd5("${path.module}/sample-logs/${each.value}")
}

# Lower storage cost: move logs to cheaper classes as they age, then delete them
resource "aws_s3_bucket_lifecycle_configuration" "archive" {
  bucket = aws_s3_bucket.archive.id

  rule {
    id     = "archive-and-expire-logs"
    status = "Enabled"

    filter {
      prefix = "logs/"
    }

    transition {
      days          = var.ia_after_days
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = var.glacier_after_days
      storage_class = "GLACIER"
    }

    expiration {
      days = var.expire_after_days
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}
