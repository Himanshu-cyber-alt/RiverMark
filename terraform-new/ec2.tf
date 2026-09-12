data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_instance" "backend_blue" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_a.id
  vpc_security_group_ids      = [aws_security_group.backend.id]
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.ec2.name

  user_data_base64 = base64encode(<<-EOF
  #!/bin/bash

  dnf update -y

  dnf install -y docker amazon-ssm-agent

  systemctl enable docker
  systemctl start docker

  usermod -aG docker ec2-user

  systemctl enable amazon-ssm-agent
  systemctl start amazon-ssm-agent
EOF
  )

  tags = {
    Name        = "rivermark-backend-blue"
    Environment = "dev"
    Deployment  = "blue"
  }
}

resource "aws_instance" "backend_green" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_b.id
  vpc_security_group_ids      = [aws_security_group.backend.id]
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.ec2.name

 user_data_base64 = base64encode(<<-EOF
  #!/bin/bash

  dnf update -y

  dnf install -y docker amazon-ssm-agent

  systemctl enable docker
  systemctl start docker

  usermod -aG docker ec2-user

  systemctl enable amazon-ssm-agent
  systemctl start amazon-ssm-agent
EOF
)

  tags = {
    Name        = "rivermark-backend-green"
    Environment = "dev"
    Deployment  = "green"
  }
}

resource "aws_eip" "backend" {
  domain = "vpc"

  tags = {
    Name = "rivermark-backend-eip"
  }
}

resource "aws_eip_association" "backend_blue" {
  instance_id   = aws_instance.backend_blue.id
  allocation_id = aws_eip.backend.id

  lifecycle {
    ignore_changes = [
      instance_id
    ]
  }
}