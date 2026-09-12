resource "aws_vpc" "rivermark" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "rivermark-vpc"
  }
}

resource "aws_internet_gateway" "rivermark" {
  vpc_id = aws_vpc.rivermark.id

  tags = {
    Name = "rivermark-igw"
  }
}

#az-1

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.rivermark.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "rivermark-public-subnet-a"
  }
}

# az-2

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.rivermark.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "rivermark-public-subnet-b"
  }
}

# private az-1
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.rivermark.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "rivermark-private-subnet-a"
  }
}

# private az-2

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.rivermark.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "rivermark-private-subnet-b"
  }
}

# route table

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.rivermark.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.rivermark.id
  }

  tags = {
    Name = "rivermark-public-rt"
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}



resource "aws_route_table" "private" {
  vpc_id = aws_vpc.rivermark.id

  tags = {
    Name = "rivermark-private-rt"
  }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}