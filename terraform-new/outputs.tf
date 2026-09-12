output "ecr_repository_url" {
  description = "ECR repository URL for the backend"
  value       = aws_ecr_repository.backend.repository_url
}

output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = aws_db_instance.rivermark.address
}

output "rds_port" {
  description = "RDS PostgreSQL port"
  value       = aws_db_instance.rivermark.port
}

output "frontend_bucket_name" {
  description = "S3 bucket name for the React frontend"
  value       = aws_s3_bucket.frontend.bucket
}

output "frontend_website_endpoint" {
  description = "S3 website endpoint for the React frontend"
  value       = aws_s3_bucket_website_configuration.frontend.website_endpoint
}

output "backend_blue_instance_id" {
  description = "Blue backend EC2 instance ID"
  value       = aws_instance.backend_blue.id
}

output "backend_green_instance_id" {
  description = "Green backend EC2 instance ID"
  value       = aws_instance.backend_green.id
}

output "backend_elastic_ip" {
  description = "Elastic IP used as the backend endpoint"
  value       = aws_eip.backend.public_ip
}

output "github_actions_role_arn" {
  description = "IAM role ARN used by GitHub Actions through OIDC"
  value       = aws_iam_role.github_actions.arn
}