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

# Security Group for EC2 (SSH access from internet)
resource "aws_security_group" "ec2_ssh" {
  name        = "${var.environment}-${var.name_prefix}-ec2-ssh"
  description = "Security group for ${var.name_prefix} EC2 instance with SSH access"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr_blocks
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-${var.name_prefix}-ec2-ssh"
  }
}

# EC2 Instance
resource "aws_instance" "main" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.ec2_ssh.id]
  key_name               = var.key_name != "" ? var.key_name : null

  associate_public_ip_address = true

  tags = merge(
    {
      Name        = "${var.environment}-${var.name_prefix}-ec2"
      Purpose     = var.name_prefix
      Environment = var.environment
    },
    var.additional_tags
  )
}

