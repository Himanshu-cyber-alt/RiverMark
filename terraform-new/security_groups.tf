resource "aws_security_group" "backend" {
  name        = "rivermark-backend-sg"
  description = "Security group for Rivermark backend EC2"
  vpc_id      = aws_vpc.rivermark.id

  # Public API traffic
  ingress {
    description = "Allow HTTP API traffic"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound traffic
  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rivermark-backend-sg"
  }
}

resource "aws_security_group" "rds" {
  name        = "rivermark-rds-sg"
  description = "Security group for Rivermark PostgreSQL RDS"
  vpc_id      = aws_vpc.rivermark.id

  # PostgreSQL only from backend EC2
  ingress {
    description     = "Allow PostgreSQL from backend EC2"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.backend.id]
  }

  # Outbound traffic
  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rivermark-rds-sg"
  }
}