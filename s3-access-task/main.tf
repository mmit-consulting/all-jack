


# enforce security to s3
module "s3_security" {
  source       = "./modules/s3_security"
  bucket_names = var.bucket_names
}

# Real-time alerting (when event happens that change the filter, the email is sent within the next 5mn)
module "cloudtrail_monitoring" {
  source = "./modules/cloudtrail_monitoring"

  cloudtrail_logs_bucket  = var.cloudtrail_logs_bucket
  cloudwatch_log_group    = var.cloudwatch_log_group
  sns_email_list          = var.emails
  bucket_names_to_monitor = var.bucket_names
}

# Continuous compliance & auditing
module "aws_config" {
  source             = "./modules/aws_config"
  config_logs_bucket = var.cloudtrail_logs_bucket
  bucket_names       = var.bucket_names
}
