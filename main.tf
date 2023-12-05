# We start with configuring the AWS provider
provider "aws" {
  region = "us-west-2"
}

# Our VPC
resource "aws_vpc" "Savannah_terraform_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "Savannah-terraform-vpc"
  }
}
# Internet Gateway
resource "aws_internet_gateway" "Savannah_terraform_igw" {
  vpc_id = aws_vpc.Savannah_terraform_vpc.id

  tags = {
    Name = "Savannah-terraform-igw"
  }
}
# Subnet associated with our VPC
resource "aws_subnet" "Savannah_terraform_subnet" {
  vpc_id                  = aws_vpc.Savannah_terraform_vpc.id
  cidr_block             = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Savannah-terraform-subnet"
  }
}
# Route Table
resource "aws_route_table" "Savannah_terraform_rt" {
  vpc_id = aws_vpc.Savannah_terraform_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Savannah_terraform_igw.id
  }

  tags = {
    Name = "Savannah-terraform-rt"
  }
}

# Subnet Association
resource "aws_route_table_association" "Savannah_terraform_subnet_assoc" {
  subnet_id      = aws_subnet.Savannah_terraform_subnet.id
  route_table_id = aws_route_table.Savannah_terraform_rt.id
}

# Simple example of Security group
resource "aws_security_group" "Savannah_security_group" {
  vpc_id = aws_vpc.Savannah_terraform_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Savannah-security-group"
  }
}

# We will create one EC2 instance
resource "aws_instance" "savannah_terraform_instance" {
  ami           = "ami-03878b1b5deaa0f3e"
  instance_type = "t2.micro"
  key_name      = "Savannah-key"
  subnet_id                    = aws_subnet.Savannah_terraform_subnet.id
  vpc_security_group_ids       = [aws_security_group.Savannah_security_group.id]
  associate_public_ip_address  = true

  tags = {
    Name = "savannah-terraform-instance"
  }
}
