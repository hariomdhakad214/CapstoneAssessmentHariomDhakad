resource "aws_iam_user" "s3_read_user" {
  name = var.iam_username

  tags = {
    Project     = "Project4"
    Environment = "Learning"
  }
}

resource "aws_iam_user_policy" "s3_read_policy" {
  name   = "S3ReadOnlyPolicy"
  user   = aws_iam_user.s3_read_user.name
  policy = var.s3_read_policy
}
