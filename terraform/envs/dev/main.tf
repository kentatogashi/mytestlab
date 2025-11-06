# ============================================================
# IAM Module
# ============================================================
module "iam" {
  source = "./iam"

  environment     = var.environment
  mgmt_account_id = var.mgmt_account_id
}

# ============================================================
# VPC Module
# ============================================================
module "vpc" {
  source = "../../modules/vpc"

  environment     = var.environment
  cidr_block      = var.vpc_cidr_block
  public_subnets  = var.vpc_public_subnets
  private_subnets = var.vpc_private_subnets
  azs             = var.vpc_azs
}

########################
# S3: static-web (5個)
########################

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "static" {
  count  = 5
  bucket = "${var.environment}-static-web-${substr(data.aws_caller_identity.current.account_id, length(data.aws_caller_identity.current.account_id) - 4, 4)}-${format("%02d", count.index + 1)}"
  tags = {
    Environment = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "static" {
  count  = 5
  bucket = aws_s3_bucket.static[count.index].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

########################
# S3: backup (5個)
########################

resource "aws_s3_bucket" "backup" {
  count  = 5
  bucket = "${var.environment}-backup-${substr(data.aws_caller_identity.current.account_id, length(data.aws_caller_identity.current.account_id) - 4, 4)}-${format("%02d", count.index + 1)}"
  tags = {
    Environment = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "backup" {
  count  = 5
  bucket = aws_s3_bucket.backup[count.index].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

########################
# EC2 Instances (5種類)
########################

# EC2用途ごとの設定
locals {
  ec2_instances = {
    web = {
      name_prefix = "web"
      instance_type = "t3.micro"
      subnet_index = 0
      enable_http = true  # Apache用にHTTPを許可
    }
    # app = {
    #   name_prefix = "app"
    #   instance_type = "t3.medium"
    #   subnet_index = 0
    # }
    # db = {
    #   name_prefix = "db"
    #   instance_type = "t3.large"
    #   subnet_index = 0
    # }
    # cache = {
    #   name_prefix = "cache"
    #   instance_type = "t3.micro"
    #   subnet_index = 1
    # }
    # worker = {
    #   name_prefix = "worker"
    #   instance_type = "t3.small"
    #   subnet_index = 1
    # }
  }
}

########################
# CloudWatch Logs for EC2
########################

# CloudWatch Log Group for EC2 logs
resource "aws_cloudwatch_log_group" "ec2_logs" {
  name              = "${var.environment}-ec2-logs"
  retention_in_days = 7  # 無料枠内で使用（7日間保持）

  tags = {
    Name        = "${var.environment}-ec2-logs"
    Environment = var.environment
  }
}

# 用途ごとのEC2インスタンスを作成
module "ec2" {
  for_each = local.ec2_instances
  source   = "../../modules/ec2"

  environment         = var.environment
  name_prefix         = each.value.name_prefix
  vpc_id              = module.vpc.vpc_id
  subnet_id           = module.vpc.public_subnet_ids[each.value.subnet_index]
  instance_type       = each.value.instance_type
  key_name            = var.ec2_key_name
  allowed_ssh_cidr_blocks = var.ec2_allowed_ssh_cidr_blocks
  enable_http             = lookup(each.value, "enable_http", false)
  enable_https            = lookup(each.value, "enable_https", false)
  cloudwatch_log_group_name = aws_cloudwatch_log_group.ec2_logs.name
}

########################
# EC2 Status Check Monitoring (PINGダウン検知)
########################

# SNS Topic for EC2 status check notifications
resource "aws_sns_topic" "ec2_status_check" {
  name = "${var.environment}-ec2-status-check"
  
  tags = {
    Name        = "${var.environment}-ec2-status-check"
    Environment = var.environment
  }
}

# SNS Subscription (Email)
resource "aws_sns_topic_subscription" "ec2_status_check_email" {
  count     = var.sns_notification_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.ec2_status_check.arn
  protocol  = "email"
  endpoint  = var.sns_notification_email
}

# CloudWatch Alarm for EC2 Instance Status Check Failed
resource "aws_cloudwatch_metric_alarm" "ec2_status_check_failed" {
  for_each = module.ec2

  alarm_name          = "${var.environment}-${each.key}-status-check-failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed_Instance"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Minimum"
  threshold           = 0
  alarm_description   = "This metric monitors EC2 instance status check failure (PING down detection)"
  alarm_actions       = [aws_sns_topic.ec2_status_check.arn]
  treat_missing_data  = "breaching"

  dimensions = {
    InstanceId = each.value.instance_id
  }

  tags = {
    Name        = "${var.environment}-${each.key}-status-check-failed"
    Environment = var.environment
    Instance    = each.key
  }
}

# CloudWatch Alarm for EC2 System Status Check Failed
resource "aws_cloudwatch_metric_alarm" "ec2_system_status_check_failed" {
  for_each = module.ec2

  alarm_name          = "${var.environment}-${each.key}-system-status-check-failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed_System"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Minimum"
  threshold           = 0
  alarm_description   = "This metric monitors EC2 system status check failure"
  alarm_actions       = [aws_sns_topic.ec2_status_check.arn]
  treat_missing_data  = "breaching"

  dimensions = {
    InstanceId = each.value.instance_id
  }

  tags = {
    Name        = "${var.environment}-${each.key}-system-status-check-failed"
    Environment = var.environment
    Instance    = each.key
  }
}
