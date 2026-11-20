resource "aws_s3_bucket" "demo" {
  bucket = var.bucket_name

  tags = {
    Name    = "Project6 Version Control Demo"
    Project = "Project6"
  }
}
