resource "aws_s3_bucket" "demo" {
  bucket = var.bucket_name

  tags = {
    Name    = "Project11 Branching Policy Demo"
    Project = "Project11"
  }
}
