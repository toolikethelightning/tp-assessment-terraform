data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "hello_vpc" {
  cidr_block = "192.0.0.0/16"
  tags = {
    Name = "hello_vpc"
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id = aws_vpc.hello_vpc.id
  cidr_block = "192.0.0.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id = aws_vpc.hello_vpc.id
  cidr_block = "192.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.hello_vpc.id

  route {
    cidr_block = "0.0.0.0/0" # validate tthis
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.hello_vpc.id
}

resource "aws_route_table_association" "public_subnet_a" {
  subnet_id = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_b" {
  subnet_id = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_eip" "nat_gateway_ip" {
    vpc = true
}
resource "aws_nat_gateway" "nat_gateway" {
    allocation_id = aws_eip.nat_gateway_ip.id
    subnet_id     = "${aws_subnet.public_subnet_a.id}"

    # To ensure proper ordering, add Internet Gateway as dependency - I need to validate understanding here.
    depends_on = [aws_internet_gateway.internet_gateway]
}

resource "aws_route_table" "private_route_table" {
    vpc_id = aws_vpc.hello_vpc.id
    
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = "${aws_nat_gateway.nat_gateway.id}" 
    }
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id = aws_vpc.hello_vpc.id
  cidr_block = "192.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id = aws_vpc.hello_vpc.id
  cidr_block = "192.0.3.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "private-subnet-2"
  }
} 

resource "aws_route_table_association" "private_subnet_a" {
  subnet_id = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_b" {
  subnet_id = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_security_group" "load_balancer" {
  vpc_id = aws_vpc.hello_vpc.id
}

resource "aws_security_group" "ecs_task" {
  vpc_id = aws_vpc.hello_vpc.id
}

resource "aws_security_group_rule" "ingress_load_balancer_http" {
  from_port = 80
  protocol = "tcp"
  security_group_id = aws_security_group.load_balancer.id
  to_port = 80
  cidr_blocks = ["0.0.0.0/0"]
  type = "ingress"
}

resource "aws_security_group_rule" "ingress_ecs_task_elb" {
  from_port = 5001 
  protocol = "tcp"
  security_group_id = aws_security_group.ecs_task.id
  to_port = 5001
  source_security_group_id = aws_security_group.load_balancer.id
  type = "ingress"
}

resource "aws_security_group_rule" "egress_load_balancer" {
  type = "egress"
  from_port = 0
  to_port = 65535
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.load_balancer.id
}

resource "aws_security_group_rule" "egress_ecs_task" {
  type = "egress"
  from_port = 0
  to_port = 65535
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs_task.id
}

# If we wanted ingress for HTTPS, we could enable this.
# resource "aws_security_group_rule" "ingress_load_balancer_https" {
#   from_port = 443
#   protocol = "tcp"
#   security_group_id = aws_security_group.load_balancer.id
#   to_port = 443
#   cidr_blocks = ["0.0.0.0/0"]
#   type = "ingress"
# }
