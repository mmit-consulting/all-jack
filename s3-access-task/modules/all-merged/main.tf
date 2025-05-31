locals {
  bucket_names = keys(var.bucket_region_map)

  buckets_us_east_1 = {
    for name, region in var.bucket_region_map : name => region
    if region == "us-east-1"
  }

  buckets_us_west_2 = {
    for name, region in var.bucket_region_map : name => region
    if region == "us-west-2"
  }

}

############### Enforce S3 Security ###############
# Block public access
# 1 block per region -> if you have other regions, we should add other blocks
resource "aws_s3_bucket_public_access_block" "secure_us_east_1" {
  for_each = local.buckets_us_east_1

  provider = aws.us-east-1

  bucket = each.key

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "secure_us_west_2" {
  for_each = local.buckets_us_west_2

  provider = aws.us-west-2

  bucket                  = each.key
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# Disable ACLs - TODO to uncomment after 3 to 7 days
# resource "aws_s3_bucket_ownership_controls" "disable_acls_us_east_1" {
#   for_each = local.buckets_us_east_1
#   bucket   = each.key

#   rule {
#     object_ownership = "BucketOwnerEnforced" # use "BucketOwnerPreferred" if you want to enable ACL back
#   }
# }

# resource "aws_s3_bucket_ownership_controls" "disable_acls_us_west_2" {
#   for_each = local.buckets_us_west_2
#   bucket   = each.key

#   rule {
#     object_ownership = "BucketOwnerEnforced" # use "BucketOwnerPreferred" if you want to enable ACL back
#   }
# }



############### CloudTrail monitoring ###############

# Prepare the required policies for s3 bucket used by cloudtrail and config
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_policy" "config_policy" {
  bucket = var.cloudtrail_logs_bucket

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
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

# Create a CloudWatch Log Group to receive CloudTrail logs
resource "aws_cloudwatch_log_group" "trail_logs" {
  name              = var.cloudwatch_log_group
  retention_in_days = 90
}


# IAM role that allows CloudTrail to send logs to CloudWatch
resource "aws_iam_role" "cloudtrail_logs" {
  name = "CloudTrail_CloudWatchS3Logs_Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "cloudtrail.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach permission policy to CloudTrail role to write logs
resource "aws_iam_role_policy" "cloudtrail_logs_policy" {
  name = "AllowCWLogs"
  role = aws_iam_role.cloudtrail_logs.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      Resource = "${aws_cloudwatch_log_group.trail_logs.arn}:*"
    }]
  })
}

resource "aws_cloudtrail" "s3_trail" {
  name                          = "s3-security-trail"
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_logs.arn
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.trail_logs.arn}:*"
  s3_bucket_name                = var.cloudtrail_logs_bucket
  is_organization_trail         = false

  event_selector {
    read_write_type           = "WriteOnly"
    include_management_events = true
  }
}

# Filtering events
# Filter only PutBucketAcl events on specified buckets
resource "aws_cloudwatch_log_metric_filter" "acl_change" {
  for_each       = toset(local.bucket_names)
  name           = "S3AclChange-${each.key}"
  log_group_name = aws_cloudwatch_log_group.trail_logs.name
  pattern        = "{ ($.eventName = \"PutBucketAcl\") && ($.requestParameters.bucketName = \"${each.key}\") }"

  metric_transformation {
    name      = "S3AclChange-${each.key}"
    namespace = "S3Security"
    value     = "1"
  }
}

# Filter only PutBucketPublicAccessBlock events on specified buckets
resource "aws_cloudwatch_log_metric_filter" "block_public_change" {
  for_each       = toset(local.bucket_names)
  name           = "S3BlockPublicAccessChange-${each.key}"
  log_group_name = aws_cloudwatch_log_group.trail_logs.name
  pattern        = "{ ($.eventName = \"PutBucketPublicAccessBlock\") && ($.requestParameters.bucketName = \"${each.key}\") }"

  metric_transformation {
    name      = "S3BlockPublicAccessChange-${each.key}"
    namespace = "S3Security"
    value     = "1"
  }
}


# Setup email based notification
resource "aws_sns_topic" "s3_alerts" {
  name = "s3-security-alerts"
}

resource "aws_sns_topic_subscription" "email_alerts" {
  for_each = toset(var.sns_email_list)

  topic_arn = aws_sns_topic.s3_alerts.arn
  protocol  = "email"
  endpoint  = each.value
}

# Alamr for ACL changes 
resource "aws_cloudwatch_metric_alarm" "acl_alarm" {
  for_each            = toset(local.bucket_names)
  alarm_name          = "S3AclChangeAlarm-${each.key}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "S3AclChange-${each.key}"
  namespace           = "S3Security"
  period              = 180
  statistic           = "Sum"
  threshold           = 1
  alarm_actions       = [aws_sns_topic.s3_alerts.arn]
  alarm_description   = "ACL was modified on bucket: ${each.key}"
}

# Alarm for Block Public Access changes
resource "aws_cloudwatch_metric_alarm" "block_public_alarm" {
  for_each            = toset(local.bucket_names)
  alarm_name          = "S3BlockPublicAccessChangeAlarm-${each.key}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "S3BlockPublicAccessChange-${each.key}"
  namespace           = "S3Security"
  period              = 180
  statistic           = "Sum"
  threshold           = 1
  alarm_actions       = [aws_sns_topic.s3_alerts.arn]
  alarm_description   = "Block Public Access setting was modified on bucket: ${each.key}"
}





############### AWS Config ###############

# Define the compliance policies to enforce.
resource "aws_config_config_rule" "s3_block_public_useast1" {
  for_each = local.buckets_us_east_1

  provider = aws.us-east-1

  name = "s3-bucket-public-read-prohibited-${replace(each.key, ".", "-")}"
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }

  scope {
    compliance_resource_types = ["AWS::S3::Bucket"]
    compliance_resource_id    = each.key
  }
}

resource "aws_config_config_rule" "s3_block_public_useast2" {
  for_each = local.buckets_us_west_2

  provider = aws.us-west-2

  name = "s3-bucket-public-read-prohibited-${replace(each.key, ".", "-")}"
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }

  scope {
    compliance_resource_types = ["AWS::S3::Bucket"]
    compliance_resource_id    = each.key
  }
}

resource "aws_config_config_rule" "s3_acl_prohibited_useast1" {
  for_each = local.buckets_us_east_1

  provider = aws.us-east-1

  name = "s3-bucket-acl-prohibited-${replace(each.key, ".", "-")}"
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_ACL_PROHIBITED"
  }

  scope {
    compliance_resource_types = ["AWS::S3::Bucket"]
    compliance_resource_id    = each.key
  }
}

resource "aws_config_config_rule" "s3_acl_prohibited_useast2" {
  for_each = local.buckets_us_west_2

  provider = aws.us-west-2

  name = "s3-bucket-acl-prohibited-${replace(each.key, ".", "-")}"
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_ACL_PROHIBITED"
  }

  scope {
    compliance_resource_types = ["AWS::S3::Bucket"]
    compliance_resource_id    = each.key
  }
}
