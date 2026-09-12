# -------------------------
# RDS subnet group
# -------------------------

resource "aws_db_subnet_group" "rivermark" {
  name = "rivermark-db-subnet-group"

  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  tags = {
    Name = "rivermark-db-subnet-group"
  }
}

# -------------------------
# RDS PostgreSQL
# -------------------------

resource "aws_db_instance" "rivermark" {
  identifier = "rivermark-postgres"

  engine         = "postgres"
  engine_version = "16"

  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = "rivermark"
  username = "rivermark_admin"
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.rivermark.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible = false

  backup_retention_period = 1

  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name = "rivermark-postgres"
  }
}