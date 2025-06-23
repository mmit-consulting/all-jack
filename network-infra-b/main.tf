module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.21.0"

  name = var.tags["name"]
  cidr = var.vpc_cidr_block

  azs             = var.azs
  public_subnet_names  = var.public_subnet_names
  private_subnet_names = var.private_subnet_names
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway        = true
  single_nat_gateway        = false
  one_nat_gateway_per_az    = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = var.tags
}

### Customization not possible through module ###
resource "aws_route_table" "private_dev_1a" {
  vpc_id = module.vpc.vpc_id

  tags = merge(var.tags, {
    Name = "ecom-serverless-private-dev-us-east-1a"
    environment = "dev"
  })
}

resource "aws_route_table_association" "private_dev_1a_assoc" {
  subnet_id      = element([
    for i, name in var.private_subnet_names : 
    module.vpc.private_subnets[i] if name == "serverless-dev-private-us-east-1a"
  ], 0)

  route_table_id = aws_route_table.private_dev_1a.id
}
### end ###
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

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  for_each = { for sg in var.security_groups : sg.name => sg }

  name        = each.value.name
  description = each.value.description
  vpc_id      = module.vpc.vpc_id

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