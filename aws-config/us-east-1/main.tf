# root account
module "aws_config_us_east_1" {
  source              = "../modules/aws_config_org"
  providers           = { aws = aws.us-east-1 }
  config_logs_bucket  = var.config_logs_bucket
  excluded_accounts   = var.excluded_accounts
  notification_emails = var.notification_emails
  organization_id     = var.organization_id
}

# sub account
module "aws_config_subaccount" {
  source              = "../modules/aws_config_subaccounts"
  org_root_account_id = "xxxxxx"
}
