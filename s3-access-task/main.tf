# enforce security to s3

module "s3_security" {
  source            = "./modules/s3_security"
  bucket_region_map = var.bucket_region_map

  providers = {
    aws.us-east-1 = aws.us-east-1
    aws.us-east-2 = aws.us-east-2
  }
}

# Real-time alerting (when event happens that change the filter, the email is sent within the next 5mn)
module "cloudtrail_monitoring" {
  source = "./modules/cloudtrail_monitoring"

  cloudtrail_logs_bucket = var.cloudtrail_logs_bucket
  cloudwatch_log_group   = var.cloudwatch_log_group
  sns_email_list         = var.emails
  bucket_region_map      = var.bucket_region_map
}

# Continuous compliance & auditing
module "aws_config" {
  source             = "./modules/aws_config"
  config_logs_bucket = var.cloudtrail_logs_bucket

  bucket_region_map = var.bucket_region_map

  providers = {
    aws.us-east-1 = aws.us-east-1
    aws.us-east-2 = aws.us-east-2
  }
}
