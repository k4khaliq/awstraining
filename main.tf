provider "aws" {
  region = "eu-west-3"
}

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix {}
variable instance_type {}

resource "aws_vpc" "test_vpc" {
  cidr_block =var.vpc_cidr_block
  tags = {
    Name: "${var.env_prefix}-vpc"
  }  
}

resource "aws_subnet" "test_vpc_snet1" {
  vpc_id = aws_vpc.test_vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name: "${var.env_prefix}-subnet-1"
  }  
}

resource "aws_route_table" "test_route_table" {
  vpc_id = aws_vpc.test_vpc.id
  tags = {
    Name = "${var.env_prefix}-rtb"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test_gw.id
  }
}

resource "aws_internet_gateway" "test_gw" {
     vpc_id = aws_vpc.test_vpc.id
     tags = {
      Name = "${var.env_prefix}-igw"
  }
}

resource "aws_route_table_association" "rtb_ass_test_snet" {
  subnet_id = aws_subnet.test_vpc_snet1.id
  route_table_id = aws_route_table.test_route_table.id

}

resource "aws_security_group" "test-sg" {
  name = "test-sg"
  vpc_id = aws_vpc.test_vpc.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
  tags = {
      Name = "${var.env_prefix}-nsg"

    }
}

data "aws_ami" "amz_lin_ami" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["al2023-ami-*-kernel-6.1-x86_64"]
  }
  
}
/*output "awm_id" {
  value = data.aws_ami.amz_lin_ami.id

}*/
resource "aws_instance" "my_ec2_inst" {
  ami = data.aws_ami.amz_lin_ami.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.test_vpc_snet1.id
  vpc_security_group_ids = [aws_security_group.test-sg.id]
  availability_zone = var.avail_zone

  associate_public_ip_address = true
  key_name = "Server-Key-Pair"

  tags = {
      Name = "${var.env_prefix}-server"

    }
}