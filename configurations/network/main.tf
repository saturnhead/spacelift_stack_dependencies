provider "aws" {
  region = "eu-central-1"
}

resource "aws_vpc" "this" {
  for_each = var.vpcs

  cidr_block           = each.value.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    {
      "Name" : each.key
    },
    each.value.tags
  )
}

resource "aws_subnet" "this" {
  for_each = var.subnets

  vpc_id                  = aws_vpc.this[each.value.vpc_key].id
  cidr_block              = each.value.cidr_block
  map_public_ip_on_launch = each.value.map_public_ip_on_launch

  tags = merge(
    {
      "Name" : each.key
    },
    each.value.tags
  )
}

resource "aws_internet_gateway" "this" {
  for_each = var.vpcs

  vpc_id = aws_vpc.this[each.key].id

  tags = merge(
    {
      "Name" : "${each.key}-igw"
    },
    each.value.tags
  )
}

resource "aws_route_table" "public" {
  for_each = var.vpcs

  vpc_id = aws_vpc.this[each.key].id

  tags = merge(
    {
      "Name" : "${each.key}-public-rt"
    },
    each.value.tags
  )
}

resource "aws_route" "public_internet_gateway" {
  for_each = var.vpcs

  route_table_id         = aws_route_table.public[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[each.key].id
}

resource "aws_route_table_association" "public" {
  for_each = {
    for k, v in var.subnets : k => v if v.map_public_ip_on_launch
  }

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.public[each.value.vpc_key].id
}
