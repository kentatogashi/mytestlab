output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.main.id
}

output "instance_public_ip" {
  description = "EC2 instance public IP address"
  value       = aws_instance.main.public_ip
}

output "instance_public_dns" {
  description = "EC2 instance public DNS name"
  value       = aws_instance.main.public_dns
}

output "security_group_id" {
  description = "Security group ID for EC2 instance"
  value       = aws_security_group.ec2.id
}

