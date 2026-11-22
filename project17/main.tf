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

# IAM role that lets the instance send logs to CloudWatch
resource "aws_iam_role" "agent" {
  name = "${var.project_name}-agent-role"

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
}

resource "aws_iam_role_policy_attachment" "agent" {
  role       = aws_iam_role.agent.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "agent" {
  name = "${var.project_name}-agent-profile"
  role = aws_iam_role.agent.name
}

# No inbound rules: the agent only sends data out, so no ports are opened
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

resource "aws_cloudwatch_log_group" "app" {
  name              = var.log_group_name
  retention_in_days = var.log_retention_days

  tags = {
    Project = "Project17"
  }
}

resource "aws_instance" "app" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = sort(data.aws_subnets.default.ids)[0]
  vpc_security_group_ids      = [aws_security_group.instance.id]
  iam_instance_profile        = aws_iam_instance_profile.agent.name
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/userdata.sh", {
    region         = var.aws_region
    log_group_name = var.log_group_name
  })

  user_data_replace_on_change = true

  tags = {
    Name = "${var.project_name}-ec2"
  }

  depends_on = [
    aws_iam_role_policy_attachment.agent,
    aws_cloudwatch_log_group.app,
  ]
}

# Dashboard with recent log lines and an error count from Logs Insights
resource "aws_cloudwatch_dashboard" "logs" {
  dashboard_name = "${var.project_name}-logs"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "log"
        x      = 0
        y      = 0
        width  = 24
        height = 8
        properties = {
          title  = "Recent application logs"
          region = var.aws_region
          view   = "table"
          query  = "SOURCE '${var.log_group_name}' | fields @timestamp, @logStream, @message | filter @logStream like /app.log/ | sort @timestamp desc | limit 50"
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 8
        width  = 12
        height = 6
        properties = {
          title  = "Log lines by level"
          region = var.aws_region
          view   = "bar"
          query  = "SOURCE '${var.log_group_name}' | filter @logStream like /app.log/ | parse @message ' * ' as level | stats count(*) as lines by level"
        }
      },
      {
        type   = "log"
        x      = 12
        y      = 8
        width  = 12
        height = 6
        properties = {
          title  = "ERROR lines over time"
          region = var.aws_region
          view   = "timeSeries"
          query  = "SOURCE '${var.log_group_name}' | filter @message like /ERROR/ | stats count(*) as errors by bin(1m)"
        }
      }
    ]
  })
}
