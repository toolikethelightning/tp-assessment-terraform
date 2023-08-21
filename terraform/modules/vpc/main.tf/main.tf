data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "hello_vpc" {
  cidr_block = "192.0.0.0/16"
}