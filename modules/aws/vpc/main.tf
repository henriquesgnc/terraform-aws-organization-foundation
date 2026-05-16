locals {
  vpc_name              = local.resource_name
  nat_gateway_count     = min(var.nat_gateway_count, length(aws_subnet.public))
  internet_gateway_name = format("%s-internet-gateway", local.resource_name)
}

resource "aws_vpc" "this" {
  cidr_block                       = var.cidr_block
  instance_tenancy                 = "default"
  enable_dns_hostnames             = true
  enable_dns_support               = true
  assign_generated_ipv6_cidr_block = false

  tags = {
    Name = local.vpc_name
  }
}

resource "aws_eip" "this" {
  count      = local.nat_gateway_count
  domain     = "vpc"
  depends_on = [aws_vpc.this]

  tags = {
    Name = format("%s-elastic-ip-%s", local.resource_name, data.aws_availability_zones.available.names[count.index])
  }
}

resource "aws_nat_gateway" "this" {
  count         = local.nat_gateway_count
  allocation_id = aws_eip.this[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = format("%s-nat-gateway-%s", local.resource_name, data.aws_availability_zones.available.names[count.index])
  }

  depends_on = [aws_subnet.public]
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = local.internet_gateway_name
  }

  depends_on = [aws_vpc.this]
}
