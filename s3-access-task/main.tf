# Prepare the required policies for s3 bucket used by cloudtrail and config
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_policy" "config_policy" {
  bucket = var.cloudtrail_logs_bucket

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # AWS Config Part
      {
        Sid    = "AWSConfigPutObject",
        Effect = "Allow",
        Principal = {
          Service = "config.amazonaws.com"
        },
        Action   = "s3:PutObject",
        Resource = "arn:aws:s3:::${var.cloudtrail_logs_bucket}/AWSLogs/${data.aws_caller_identity.current.account_id}/Config/*",
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
      {
        Sid    = "AWSConfigGetBucketAcl",
        Effect = "Allow",
        Principal = {
          Service = "config.amazonaws.com"
        },
        Action   = "s3:GetBucketAcl",
        Resource = "arn:aws:s3:::${var.cloudtrail_logs_bucket}"
      },

      # AWS Cloud Trail Part

      {
        Sid    = "AWSCloudTrailAclCheck",
        Effect = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action   = "s3:GetBucketAcl",
        Resource = "arn:aws:s3:::${var.cloudtrail_logs_bucket}"
      },
      {
        Sid    = "AWSCloudTrailWrite",
        Effect = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action   = "s3:PutObject",
        Resource = "arn:aws:s3:::${var.cloudtrail_logs_bucket}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}


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
