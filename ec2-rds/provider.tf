# provider.tf
provider "aws" {
  region = "eu-north-1"
}

# variables.tf
variable "region" {
  default = "eu-north-1"
}

variable "vpc_cidr" {
  default = "30.0.0.0/16"
}

variable "public_subnet_cidrs" {
  default = ["30.0.1.0/24", "30.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  default = ["30.0.10.0/24", "30.0.11.0/24"]
}

variable "availability_zones" {
  default = ["eu-north-1a", "eu-north-1b"]
}

variable "key_name" {
  default = "RahulKeyPair"
}

variable "db_username" {
  default = "admin"
}

variable "db_password" {
  default = "Admin@123"
}

# outputs.tf
output "vpc_id" {
  value = aws_vpc.main.id
}

output "ec2_public_ip" {
  value = aws_instance.web.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.db.endpoint
}

# ec2.tf
resource "aws_instance" "web" {
  ami                    = "ami-07caf09b362be10b8"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = var.key_name

  tags = {
    Name = "PublicEC2Server"
  }
}

# rds.tf
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  tags = {
    Name = "RDSSubnetGroup"
  }
}

resource "aws_db_instance" "db" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  name                   = "mydb"
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  tags = {
    Name = "PrivateRDS"
  }
}
