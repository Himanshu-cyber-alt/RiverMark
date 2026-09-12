resource "aws_ssm_parameter" "db_password" {
  name        = "/rivermark/db/password"
  description = "Rivermark PostgreSQL database password"
  type        = "SecureString"
  value       = var.db_password

  tags = {
    Name = "rivermark-db-password"
  }
}