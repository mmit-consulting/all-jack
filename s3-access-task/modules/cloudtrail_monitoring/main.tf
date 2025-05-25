# Create a CloudWatch Log Group to receive CloudTrail logs
resource "aws_cloudwatch_log_group" "trail_logs" {
  name              = var.cloudwatch_log_group
  retention_in_days = 90
}


# IAM role that allows CloudTrail to send logs to CloudWatch
resource "aws_iam_role" "cloudtrail_logs" {
  name = "CloudTrail_CloudWatchLogs_Role"

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

########## Filter only PutBucketAcl events on specified buckets
resource "aws_cloudwatch_log_metric_filter" "acl_change" {
  for_each       = toset(var.bucket_names_to_monitor)
  name           = "S3AclChange-${each.key}"
  log_group_name = aws_cloudwatch_log_group.trail_logs.name
  pattern        = "{ ($.eventName = \"PutBucketAcl\") && ($.requestParameters.bucketName = \"${each.key}\") }"

  metric_transformation {
    name      = "S3AclChange-${each.key}"
    namespace = "S3Security"
    value     = "1"
  }
}

########## Filter only PutBucketPublicAccessBlock events on specified buckets
resource "aws_cloudwatch_log_metric_filter" "block_public_change" {
  for_each       = toset(var.bucket_names_to_monitor)
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
  for_each            = toset(var.bucket_names_to_monitor)
  alarm_name          = "S3AclChangeAlarm-${each.key}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "S3AclChange-${each.key}"
  namespace           = "S3Security"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_actions       = [aws_sns_topic.s3_alerts.arn]
  alarm_description   = "ACL was modified on bucket: ${each.key}"
}

# Alarm for Block Public Access changes
resource "aws_cloudwatch_metric_alarm" "block_public_alarm" {
  for_each            = toset(var.bucket_names_to_monitor)
  alarm_name          = "S3BlockPublicAccessChangeAlarm-${each.key}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "S3BlockPublicAccessChange-${each.key}"
  namespace           = "S3Security"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_actions       = [aws_sns_topic.s3_alerts.arn]
  alarm_description   = "Block Public Access setting was modified on bucket: ${each.key}"
}
