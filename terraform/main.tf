provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "tf-demo-aws-ec2-instance-2" {
  ami           = "ami-058a8a5ab36292159"
  instance_type = "t2.micro"
  key_name      = "Ansible"  # <--- Agregalo aquí (nombre exacto del par creado)
  tags = {
    Name = "SOMOS_GBM"
  }
}
  resource "aws_s3_bucket" "simple_bucket" {
  bucket = "tf-simple-s3-bucket-123456" # Cambialo por un nombre único
  acl    = "private"
  tags = {
    Name = "SOMOS_GBM S3 41"
  }
}
