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
