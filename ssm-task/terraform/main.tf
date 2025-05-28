module "ssm" {
  source     = "./modules/session-manager"
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids
  region     = var.region
  ec2_cidr   = var.ec2_cidr
}

