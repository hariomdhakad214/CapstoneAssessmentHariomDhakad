resource "aws_s3_bucket" "demo" {
  bucket = var.bucket_name

  tags = {
    Name        = "Project6 Version Control Demo"
    Project     = "Project6"
    Environment = "Learning"
  }
}

resource "aws_s3_bucket_versioning" "demo" {
  bucket = aws_s3_bucket.demo.id

  versioning_configuration {
    status = "Enabled"
  }
}
