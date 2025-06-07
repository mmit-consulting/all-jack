module "aws_config_us_east_1" {
  source              = "../modules/aws_config_org"
  providers           = { aws = aws.us-east-1 }
  config_logs_bucket  = var.config_logs_bucket
  notification_emails = var.notification_emails
}
