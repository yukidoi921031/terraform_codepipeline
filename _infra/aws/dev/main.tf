resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_vpc" "sub" {
  cidr_block = "10.1.0.0/16"
}

# test