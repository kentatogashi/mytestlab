# Latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group for EC2 (SSH and HTTP/HTTPS access)
resource "aws_security_group" "ec2" {
  name        = "${var.environment}-${var.name_prefix}-ec2"
  description = "Security group for ${var.name_prefix} EC2 instance"
  vpc_id      = var.vpc_id

  # SSH access
  ingress {
    description = "SSH from internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr_blocks
  }

  # HTTP access (if enabled)
  dynamic "ingress" {
    for_each = var.enable_http ? [1] : []
    content {
      description = "HTTP from internet"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = var.allowed_http_cidr_blocks
    }
  }

  # HTTPS access (if enabled)
  dynamic "ingress" {
    for_each = var.enable_https ? [1] : []
    content {
      description = "HTTPS from internet"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = var.allowed_https_cidr_blocks
    }
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-${var.name_prefix}-ec2"
  }
}

# IAM Role for CloudWatch Logs Agent
resource "aws_iam_role" "cloudwatch_logs" {
  count = var.cloudwatch_log_group_name != "" ? 1 : 0

  name = "${var.environment}-${var.name_prefix}-cloudwatch-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-${var.name_prefix}-cloudwatch-logs-role"
    Environment = var.environment
  }
}

# IAM Policy for CloudWatch Logs
resource "aws_iam_role_policy" "cloudwatch_logs" {
  count = var.cloudwatch_log_group_name != "" ? 1 : 0

  name = "${var.environment}-${var.name_prefix}-cloudwatch-logs-policy"
  role = aws_iam_role.cloudwatch_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:*:*:log-group:${var.cloudwatch_log_group_name}*"
      }
    ]
  })
}

# Attach AWS Systems Manager managed instance core policy for SSM Agent
resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  count = var.cloudwatch_log_group_name != "" ? 1 : 0

  role       = aws_iam_role.cloudwatch_logs[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "cloudwatch_logs" {
  count = var.cloudwatch_log_group_name != "" ? 1 : 0

  name = "${var.environment}-${var.name_prefix}-cloudwatch-logs-profile"
  role = aws_iam_role.cloudwatch_logs[0].name

  tags = {
    Name        = "${var.environment}-${var.name_prefix}-cloudwatch-logs-profile"
    Environment = var.environment
  }
}

# CloudWatch Logs Agent configuration script
locals {
  user_data = var.cloudwatch_log_group_name != "" ? base64encode(templatefile("${path.module}/cloudwatch-logs-user-data.sh", {
    log_group_name = var.cloudwatch_log_group_name
    environment    = var.environment
    name_prefix    = var.name_prefix
  })) : null
}

# EC2 Instance
resource "aws_instance" "main" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.ec2.id]
  key_name               = var.key_name != "" ? var.key_name : null
  iam_instance_profile   = var.cloudwatch_log_group_name != "" ? aws_iam_instance_profile.cloudwatch_logs[0].name : null

  associate_public_ip_address = true

  user_data = local.user_data

  tags = merge(
    {
      Name        = "${var.environment}-${var.name_prefix}-ec2"
      Purpose     = var.name_prefix
      Environment = var.environment
    },
    var.additional_tags
  )
}

