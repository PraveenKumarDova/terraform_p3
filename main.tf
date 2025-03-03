terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "tf-state-bkt1"
    key = "terraform.tfstate" #terraform actual state file
    region = "eu-west-2"
    dynamodb_table = "aws-table" #to store lockid's
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-2"
}

data "aws_ami" "myami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon"]
}

resource "aws_instance" "web_server" {
  #   count         = 2
  ami           = data.aws_ami.myami.id
  instance_type = var.instance_type

  tags = {
    # Name = "web_server-${count.index}"
    Name = "web_server"
  }
}