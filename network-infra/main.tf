module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.21.0"

  name = var.tags["name"]
  cidr = var.vpc_cidr_block

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway        = true
  single_nat_gateway        = false
  one_nat_gateway_per_az    = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = var.tags
}

module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "5.21.0"

  vpc_id          = module.vpc.vpc_id
  security_group_ids = [] # optional, can be empty
  subnet_ids      = [] # Gateway endpoints do not need subnet_ids

  endpoints = {
    s3 = {
      service      = "s3"
      service_type = "Gateway"
      tags         = var.tags
    }
  }
}

#### Security Groups ####

# Create Security Groups
resource "aws_security_group" "dynamic_sg" {
  for_each = { for sg in var.security_groups : sg.name => sg }

  name        = each.value.name
  description = each.value.description
  vpc_id      = module.vpc.vpc_id

  tags = merge(var.tags, {
    Name = each.value.name
  })
}

# Create Ingress Rules
resource "aws_security_group_rule" "dynamic_ingress" {
  for_each = {
    for pair in flatten([
      for sg in var.security_groups : [
        for i, rule in sg.ingress : {
          key   = "${sg.name}-ingress-${i}"
          value = {
            security_group_id = aws_security_group.dynamic_sg[sg.name].id
            from_port         = rule.from_port
            to_port           = rule.to_port
            protocol          = rule.protocol
            cidr_blocks       = rule.cidr_blocks
          }
        }
      ]
    ]) : pair.key => pair.value
  }

  type              = "ingress"
  security_group_id = each.value.security_group_id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
}

# Create Egress Rules
resource "aws_security_group_rule" "dynamic_egress" {
  for_each = {
    for pair in flatten([
      for sg in var.security_groups : [
        for i, rule in sg.egress : {
          key   = "${sg.name}-egress-${i}"
          value = {
            security_group_id = aws_security_group.dynamic_sg[sg.name].id
            from_port         = rule.from_port
            to_port           = rule.to_port
            protocol          = rule.protocol
            cidr_blocks       = rule.cidr_blocks
          }
        }
      ]
    ]) : pair.key => pair.value
  }

  type              = "egress"
  security_group_id = each.value.security_group_id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
}
