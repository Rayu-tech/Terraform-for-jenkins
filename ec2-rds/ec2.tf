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
