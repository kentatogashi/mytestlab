output "infra_user_name" {
  description = "Name of the infra user"
  value       = aws_iam_user.infra_user.name
}

output "readonly_user_name" {
  description = "Name of the readonly user"
  value       = aws_iam_user.readonly_user.name
}

output "infra_admin_role_arn" {
  description = "ARN of the infra admin role"
  value       = aws_iam_role.infra_admin_role.arn
}

output "readonly_role_arn" {
  description = "ARN of the readonly role"
  value       = aws_iam_role.readonly_role.arn
}

