data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public" {
  count = min(length(data.aws_availability_zones.available.names), 3)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.cidr_block, 4, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = format("%s-public-%s", local.resource_name, data.aws_availability_zones.available.names[count.index])
  }

  depends_on = [aws_vpc.this]
}

resource "aws_subnet" "private" {
  count = min(length(data.aws_availability_zones.available.names), 3)

  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.cidr_block, 4, count.index + 3)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = format("%s-private-%s", local.resource_name, data.aws_availability_zones.available.names[count.index])
  }

  depends_on = [aws_vpc.this]
}
