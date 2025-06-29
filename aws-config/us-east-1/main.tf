# root account
module "aws_config_us_east_1" {
  source              = "../modules/aws_config_org"
  providers           = { aws = aws.us-east-1 }
  config_logs_bucket  = var.aws_config_org.config_logs_bucket
  excluded_accounts   = var.aws_config_org.excluded_accounts
  notification_emails = var.aws_config_org.notification_emails
  organization_id     = var.aws_config_org.organization_id
}

# sub account
module "aws_config_subaccount" {
  source              = "../modules/aws_config_subaccounts"
  org_root_account_id = var.org_root_account_id
}
