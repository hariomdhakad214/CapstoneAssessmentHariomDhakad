variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "iam_username" {
  description = "Name of the IAM user to create"
  type        = string
  default     = "terraform-s3-read-user"
}


variable "s3_read_policy" {
  description = "S3 read-only IAM policy"
  type        = string

  default = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListAllMyBuckets",
        "s3:ListBucket",
        "s3:GetObject"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
