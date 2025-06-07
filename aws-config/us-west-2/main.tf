module "aws_config_us_west_2" {
  source              = "../modules/aws_config_org"
  providers           = { aws = aws.us-west-2 }
  config_logs_bucket  = var.config_logs_bucket
  notification_emails = var.notification_emails
}
