resource "aws_s3_bucket" "demo" {
  bucket = var.bucket_name

  tags = {
    Name        = "Project12 CI Plan Demo"
    Environment = "Learning"
    Project     = "Project12"
  }
}

resource "aws_s3_bucket_versioning" "demo" {
  bucket = aws_s3_bucket.demo.id

  versioning_configuration {
    status = "Enabled"
  }
}
