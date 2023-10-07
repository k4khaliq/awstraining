provider "aws" {
  region     = "eu-west-1"
  #access_key = "AKIAVFV7KWOXWZKOXGMK"
 #secret_key = "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"
}

resource "aws_vpc" "test_vpc" {
  cidr_block = "10.1.0.0/16"
  
  
}

resource "aws_subnet" "test_vpc_snet1" {
  vpc_id = aws_vpc.test_vpc.id
  cidr_block = "10.1.1.0/24"  
}