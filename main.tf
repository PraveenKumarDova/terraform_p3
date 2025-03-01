terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-2"
}

resource "aws_instance" "web_server" {
  #   count         = 2
  ami           = "ami-0cdb51c8064e24bbc"
  instance_type = var.instance_type

  tags = {
    # Name = "web_server-${count.index}"
    Name = "web_server"
  }
}