provider "aws" { # Este archivo sube una VPC desde Terraform Cloud
  region = "us-east-1"
}

resource "aws_vpc" "mi_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "VPC-Terraform-Test"
  }
}
