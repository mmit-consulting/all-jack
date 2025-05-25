module "s3_security" {
  source           = "./modules/s3_security"
  bucket_names     = var.bucket_names
  config_s3_bucket = "jack-infra-bucket"
}

module "cloudtrail_monitoring" {
  source = "./modules/cloudtrail_monitoring"

  cloudtrail_logs_bucket = "jack-infra-bucket"
  cloudwatch_log_group   = "/aws/cloudtrail/s3-security-monitoring"
  sns_email_list         = ["mahdiibouaziz@gmail.com"]
}
