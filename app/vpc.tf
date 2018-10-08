resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
}

resource "aws_internet_gateway" "vpc_gateway" {
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_route_table" "route_table" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.vpc_gateway.id}"
  }
}

resource "aws_main_route_table_association" "route_table_assoc" {
  vpc_id         = "${aws_vpc.vpc.id}"
  route_table_id = "${aws_route_table.route_table.id}"
}

resource "aws_subnet" "subnet" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.0.0/24"
}

