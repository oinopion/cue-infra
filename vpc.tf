/*
VPC and subnets

We're create a VPC with two subnets, each in a different Availability
Zone to provide some level of redundancy.

VPC uses netmask of /16 giving it 65,536 IP address. Subnets use
netmask of /20 giving them 4,096 IP addresses each and leaving enough
unassigned space if in the future more subnets are needed for additional AZs
or public/private split.

Tip: Use https://cidr.xyz to visualise IP ranges.
*/


locals {
  vpc_cidr_block      = "10.0.0.0/16"  # IP range: 10.0.0.1 - 10.0.255.254
  subnet_a_cidr_block = "10.0.0.0/20"  # IP range: 10.0.0.1 - 10.0.15.254
  subnet_b_cidr_block = "10.0.16.0/20" # IP range: 10.0.16.1 - 10.0.31.254
}

resource "aws_vpc" "cue_vpc" {
  cidr_block = local.vpc_cidr_block
  tags = {
    Name    = "cue-vpc"
    Project = "cue"
    Env     = "prod"
  }
}

resource "aws_subnet" "cue_vpc_public_subnet_a" {
  vpc_id            = aws_vpc.cue_vpc.id
  cidr_block        = local.subnet_a_cidr_block
  availability_zone = "eu-west-2a"
  tags = {
    Name    = "cue-subnet-a"
    Project = "cue"
    Env     = "prod"
  }
}

resource "aws_subnet" "cue_vpc_public_subnet_b" {
  vpc_id            = aws_vpc.cue_vpc.id
  cidr_block        = local.subnet_b_cidr_block
  availability_zone = "eu-west-2b"
  tags = {
    Name    = "cue-subnet-b"
    Project = "cue"
    Env     = "prod"
  }
}

resource "aws_internet_gateway" "cue_vpc_gateway" {
  vpc_id = aws_vpc.cue_vpc.id
  tags = {
    Name    = "cue-vpc-gateway"
    Project = "cue"
    Env     = "prod"
  }
}

resource "aws_route_table" "cue_vpc_public_subnet_route" {
  vpc_id = aws_vpc.cue_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cue_vpc_gateway.id
  }
  tags = {
    Name    = "cue-vpc-route-table"
    Project = "cue"
    Env     = "prod"
  }
}

resource "aws_route_table_association" "cue_vpc_public_subnet_route_assoc_a" {
  subnet_id      = aws_subnet.cue_vpc_public_subnet_a.id
  route_table_id = aws_route_table.cue_vpc_public_subnet_route.id
}

resource "aws_route_table_association" "cue_vpc_public_subnet_route_assoc_b" {
  subnet_id      = aws_subnet.cue_vpc_public_subnet_b.id
  route_table_id = aws_route_table.cue_vpc_public_subnet_route.id
}
