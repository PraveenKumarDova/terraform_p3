terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # backend "s3" {
  #   bucket = "tf-state-bkt1"
  #   key = "terraform.tfstate" #terraform actual state file
  #   region = "eu-west-2"
  #   dynamodb_table = "aws-table" #to store lockid's
  # }
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

#VPC Creation

resource "aws_vpc" "myVPC" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "myVPC"
  }
}

#subnet creation

resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.myVPC.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-2a"
  tags = {
    Name = "subnet1"
  }
}

#igw creation

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = "igw"
  }
}

#route table creation

resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.myVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "rt1"
  }
}

#route table association with subnet

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rt1.id
}

#security group creation

resource "aws_security_group" "mySG" {
  name        = "mySG"
  description = "Allow TLS inbound rules"
  vpc_id      = aws_vpc.myVPC.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    name = "mySG"
  }
}

#EC2 instance creation

resource "aws_instance" "web_server" {
  ami                         = data.aws_ami.myami.id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.subnet1.id
  vpc_security_group_ids      = [aws_security_group.mySG.id]
  key_name                    = "london1"
  user_data                   = file("server-script.sh")

  tags = {
    Name = "web_server"
  }
}


# resource "aws_instance" "web_server" {
#   #   count         = 2
#   ami           = data.aws_ami.myami.id
#   instance_type = var.instance_type

#   tags = {
#     # Name = "web_server-${count.index}"
#     Name = "web_server-${terraform.workspace}"
#   }
# }

