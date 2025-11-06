output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "static_bucket_names" {
  description = "Static web S3 bucket names"
  value       = [for b in aws_s3_bucket.static : b.id]
}

output "backup_bucket_names" {
  description = "Backup S3 bucket names"
  value       = [for b in aws_s3_bucket.backup : b.id]
}

output "ec2_instances" {
  description = "EC2 instances information"
  value = {
    for k, v in module.ec2 : k => {
      instance_id     = v.instance_id
      public_ip       = v.instance_public_ip
      public_dns      = v.instance_public_dns
      security_group_id = v.security_group_id
    }
  }
}

# 個別の出力も提供（後方互換性のため）
output "ec2_instance_id" {
  description = "EC2 instance ID (first instance)"
  value       = module.ec2["web"].instance_id
}

output "ec2_instance_public_ip" {
  description = "EC2 instance public IP address (first instance)"
  value       = module.ec2["web"].instance_public_ip
}

output "ec2_instance_public_dns" {
  description = "EC2 instance public DNS name (first instance)"
  value       = module.ec2["web"].instance_public_dns
}

