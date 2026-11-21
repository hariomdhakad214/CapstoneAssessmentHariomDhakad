resource "aws_s3_bucket" "demo" {
  bucket = var.bucket_name

  tags = {
    Name    = "Project11 Branching Policy Demo"
    Project = "Project11"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "demo" {
  bucket = aws_s3_bucket.demo.id

  rule {
    id     = "abort-incomplete-uploads"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}
