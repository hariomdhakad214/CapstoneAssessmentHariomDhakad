# Latest Ubuntu 24.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# The account is at its VPC limit, so use the default VPC and its public subnets
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

resource "aws_s3_bucket" "demo" {
  bucket = var.bucket_name

  # Lets terraform destroy remove the test files too
  force_destroy = true

  tags = {
    Project = "Project23"
  }
}

resource "aws_s3_bucket_public_access_block" "demo" {
  bucket = aws_s3_bucket.demo.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "hello" {
  bucket  = aws_s3_bucket.demo.id
  key     = "hello.txt"
  content = "Hello from S3. This object was read by an EC2 instance using an IAM role.\n"
}

# Role that EC2 can assume
resource "aws_iam_role" "s3_access" {
  name = "${var.project_name}-ec2-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project = "Project23"
  }
}

# Least privilege: list and read this one bucket, write only under uploads/ and reports/. No delete, no other buckets.
resource "aws_iam_role_policy" "s3_access" {
  name = "S3DemoBucketAccess"
  role = aws_iam_role.s3_access.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ListDemoBucket"
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = aws_s3_bucket.demo.arn
      },
      {
        Sid      = "ReadObjects"
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.demo.arn}/*"
      },
      {
        Sid      = "WriteUploadsAndReports"
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = ["${aws_s3_bucket.demo.arn}/uploads/*", "${aws_s3_bucket.demo.arn}/reports/*"]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "s3_access" {
  name = "${var.project_name}-ec2-s3-profile"
  role = aws_iam_role.s3_access.name
}

# No inbound rules, so no SSH or RDP
resource "aws_security_group" "instance" {
  name        = "${var.project_name}-sg"
  description = "No inbound access, all outbound"
  vpc_id      = data.aws_vpc.default.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

resource "aws_instance" "app" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = sort(data.aws_subnets.default.ids)[0]
  vpc_security_group_ids      = [aws_security_group.instance.id]
  iam_instance_profile        = aws_iam_instance_profile.s3_access.name
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/userdata.sh", {
    region = var.aws_region
    bucket = var.bucket_name
  })

  user_data_replace_on_change = true

  tags = {
    Name = "${var.project_name}-ec2"
  }

  depends_on = [
    aws_iam_role_policy.s3_access,
    aws_s3_object.hello,
  ]
}
