provider "aws" {
  region = "eu-north-1"
}

resource "aws_s3_bucket" "mybucket" {
  bucket = "rahul-jenkins-terraform-demo"
  acl    = "private"
}
