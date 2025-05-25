module "s3_security" {
  source       = "./modules/s3_security"
  bucket_names = var.bucket_names
}

module "cloudtrail_monitoring" {
  source = "./modules/cloudtrail_monitoring"

  cloudtrail_logs_bucket  = var.cloudtrail_logs_bucket
  cloudwatch_log_group    = var.cloudwatch_log_group
  sns_email_list          = var.emails
  bucket_names_to_monitor = var.bucket_names
}
