module "ssm" {
  source     = "./modules/session-manager"
  vpc_id     = var.ssm.vpc_id
  subnet_ids = var.ssm.subnet_ids
  region     = var.ssm.region
  ec2_cidr   = var.ssm.ec2_cidr
}

