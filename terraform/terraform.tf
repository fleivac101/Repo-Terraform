terraform {
  backend "remote" {
    organization = "GBM-HA-TEST"

    workspaces {
      name = "proyecto-TEST-vpc-ec2"
    }
  }
}
