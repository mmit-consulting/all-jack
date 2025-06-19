# main.tf
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = var.tags["name"]
  })
}

resource "aws_main_route_table_association" "disable" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.custom["serverless-public"].id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.tags["name"]}-igw"
  })
}

resource "aws_eip" "nat" {
  count = 2
  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.tags["name"]}-nat-eip-${count.index}"
  })
}

resource "aws_nat_gateway" "nat" {
  count         = 2
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = element([for name in var.public_subnet_names : local.public_subnet_map[name]], count.index)

  tags = merge(var.tags, {
    Name = "${var.tags["name"]}-nat-${count.index}"
  })

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_subnet" "public" {
  for_each = { for idx, name in var.public_subnet_names : name => {
    cidr = var.public_subnets[idx]
    az   = regex("(us-east-1[a-z])$", name)[0]
  }}

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = each.key
  })
}

resource "aws_subnet" "private" {
  for_each = { for idx, name in var.private_subnet_names : name => {
    cidr = var.private_subnets[idx]
    az   = regex("(us-east-1[a-z])$", name)[0]
  }}

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(var.tags, {
    Name = each.key
  })
}
locals {
  public_subnet_map = {
    for name in var.public_subnet_names : name => aws_subnet.public[name].id
  }

  private_subnet_map = {
    for name in var.private_subnet_names : name => aws_subnet.private[name].id
  }
}

resource "aws_route_table" "custom" {
  for_each = var.route_tables

  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = each.value.name
  })
}

resource "aws_route" "default_route" {
  for_each = {
    for key, rt in var.route_tables :
    key => rt if rt.type == "public" || rt.type == "private"
  }

  route_table_id         = aws_route_table.custom[each.key].id
  destination_cidr_block = "0.0.0.0/0"

  gateway_id      = each.value.type == "public" ? aws_internet_gateway.igw.id : null
  nat_gateway_id  = each.value.type == "private" ? aws_nat_gateway.nat[each.value.nat_gateway_index].id : null
}

locals {
  route_table_associations = merge([
    for rt_key, rt in var.route_tables : {
      for subnet_name in rt.subnet_names :
      "${rt_key}-${subnet_name}" => {
        route_table_key = rt_key
        type            = rt.type
        subnet_name     = subnet_name
      }
    }
  ]...)
}

resource "aws_route_table_association" "custom" {
  for_each = local.route_table_associations

  subnet_id = lookup(
    each.value.type == "public" ? local.public_subnet_map : local.private_subnet_map,
    each.value.subnet_name,
    null
  )

  route_table_id = aws_route_table.custom[each.value.route_table_key].id
}

module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "5.21.0"

  vpc_id             = aws_vpc.main.id
  security_group_ids = [] # not used for Gateway endpoints
  subnet_ids         = [] # not needed for Gateway endpoints

  endpoints = {
    s3 = {
      service             = "s3"
      service_type        = "Gateway"
      route_table_ids     = [for rt in aws_route_table.custom : rt.id]
      tags                = var.tags
    }
  }
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  for_each = { for sg in var.security_groups : sg.name => sg }

  name        = each.value.name
  description = each.value.description
  vpc_id      = aws_vpc.main.id

  ingress_with_cidr_blocks = flatten([
    for rule in each.value.ingress : [
      for cidr in rule.cidr_blocks : {
        from_port   = rule.from_port
        to_port     = rule.to_port
        protocol    = rule.protocol
        description = "Managed by Terraform"
        cidr_blocks = cidr
      }
    ]
  ])

  egress_with_cidr_blocks = flatten([
    for rule in each.value.egress : [
      for cidr in rule.cidr_blocks : {
        from_port   = rule.from_port
        to_port     = rule.to_port
        protocol    = rule.protocol
        description = "Managed by Terraform"
        cidr_blocks = cidr
      }
    ]
  ])

  tags = merge(var.tags, {
    Name = each.value.name
  })
}
