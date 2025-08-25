locals {
  # Decide number of NAT Gateways
  natgw_count = var.natgw_per_az ? length(var.azs) : 1

  # Decide route tables to use
  route_table_ids = length(var.private_route_table_ids) > 0 ?var.private_route_table_ids :(var.natgw_per_az ? [for i in range(length(var.private_subnet_ids)) : null] : [null])
}

# EIP(s)
resource "aws_eip" "nat" {
  count  = local.natgw_count
  domain = "vpc"

  tags = {
    Name = "${var.name}-nat-eip-${count.index}"
    Env  = var.env
  }
}

# NAT Gateway(s)
resource "aws_nat_gateway" "this" {
  count         = local.natgw_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = element(var.public_subnet_ids, count.index)
  tags = {
    Name = "${var.name}-natgw-${count.index}"
    Env  = var.env
  }
}

# Only create new route tables if private_route_table_ids is empty
resource "aws_route_table" "private" {
  count  = length(var.private_subnet_ids) > 0 && length(var.private_route_table_ids) == 0 ?(var.natgw_per_az ? length(var.private_subnet_ids) : 1) : 0
  vpc_id = var.vpc_id

  tags = {
    Name = var.natgw_per_az ? "${var.name}-private-rt-${count.index}" : "${var.name}-private-rt"
    Env  = var.env
  }
}

# Routes: add 0.0.0.0/0 to NAT Gateway
resource "aws_route" "private_nat_route" {
  count = length(var.private_route_table_ids) > 0 ? length(var.private_route_table_ids) :(var.natgw_per_az ? length(var.private_subnet_ids) : 1)

  route_table_id         = length(var.private_route_table_ids) > 0 ?element(var.private_route_table_ids, count.index) :aws_route_table.private[var.natgw_per_az ? count.index : 0].id

  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.natgw_per_az ?aws_nat_gateway.this[count.index % local.natgw_count].id :aws_nat_gateway.this[0].id
}

# Associate new route tables to subnets only if we created route tables
resource "aws_route_table_association" "private_assoc" {
  count = length(aws_route_table.private)

  subnet_id      = element(var.private_subnet_ids, count.index)
  route_table_id = aws_route_table.private[count.index].id
}
