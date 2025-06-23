# VPC Setup with 2 Public and 2 Private Subnets

provider "aws" {
  region = "eu-north-1"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "30.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "MyVPC"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "MyIGW"
  }
}

# Public Subnets
resource "aws_subnet" "public_a" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "30.0.1.0/24"
  availability_zone = "eu-north-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnetA"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "30.0.2.0/24"
  availability_zone = "eu-north-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnetB"
  }
}

# Private Subnets
resource "aws_subnet" "private_a" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "30.0.10.0/24"
  availability_zone = "eu-north-1a"
  tags = {
    Name = "PrivateSubnetA"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "30.0.11.0/24"
  availability_zone = "eu-north-1b"
  tags = {
    Name = "PrivateSubnetB"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "PublicRouteTable"
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

# Security Group
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "WebSG"
  }
}

# EC2 Instance in Public Subnet
resource "aws_instance" "web" {
  ami                    = "ami-07caf09b362be10b8" # Amazon Linux 2 AMI for eu-north-1
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = "RahulKeyPair" # Update this with your key name

  tags = {
    Name = "PublicEC2Server"
  }
}

# RDS Subnet Group
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  tags = {
    Name = "RDSSubnetGroup"
  }
}

# RDS Instance in Private Subnet
resource "aws_db_instance" "db" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  name                 = "mydb"
  username             = "admin"
  password             = "Admin12345"
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  skip_final_snapshot  = true
  publicly_accessible  = false
  tags = {
    Name = "PrivateRDS"
  }
}
