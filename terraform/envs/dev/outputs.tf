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

