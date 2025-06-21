##########################
# AWS S3 bucket policies
##########################
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_policy" "config_logs_bucket_policy" {
  bucket = var.config_logs_bucket

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AWSConfigBucketPermissionsCheck",
        Effect = "Allow",
        Principal = {
          Service = "config.amazonaws.com"
        },
        Action   = "s3:GetBucketAcl",
        Resource = "arn:aws:s3:::${var.config_logs_bucket}"
      },
      {
        Sid    = "AWSConfigBucketDelivery",
        Effect = "Allow",
        Principal = {
          Service = "config.amazonaws.com"
        },
        Action   = "s3:PutObject",
        Resource = "arn:aws:s3:::${var.config_logs_bucket}/AWSLogs/${data.aws_caller_identity.current.account_id}/Config/*",
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}


##########################
# AWS Config Recorder
##########################

resource "aws_iam_role" "config_recorder_role" {
  name = "AWSConfigRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "config.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "config_recorder_policy_attach" {
  role       = aws_iam_role.config_recorder_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_config_configuration_recorder" "this" {
  name     = "org-config-recorder"
  role_arn = aws_iam_role.config_recorder_role.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

##########################
# AWS Config Delivery Channel
##########################

resource "aws_config_delivery_channel" "this" {
  name           = "org-config-delivery-channel"
  s3_bucket_name = var.config_logs_bucket

  depends_on = [
    aws_config_configuration_recorder.this,
    aws_s3_bucket_policy.config_logs_bucket_policy
  ]
}

##########################
# Organization Managed Rules
##########################

resource "aws_config_organization_managed_rule" "s3_block_public" {
  name                 = "org-s3-block-public-read-prohibited"
  rule_identifier      = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  resource_types_scope = ["AWS::S3::Bucket"]
  excluded_accounts    = var.excluded_accounts
  depends_on = [
    aws_config_delivery_channel.this
  ]
}

resource "aws_config_organization_managed_rule" "s3_acl_prohibited" {
  name                 = "org-s3-acl-prohibited"
  rule_identifier      = "S3_BUCKET_ACL_PROHIBITED"
  resource_types_scope = ["AWS::S3::Bucket"]
  excluded_accounts    = var.excluded_accounts
  depends_on = [
    aws_config_delivery_channel.this
  ]
}

##########################
# SNS Topic + Subscription
##########################

resource "aws_sns_topic" "config_rule_notifications" {
  name = "aws-config-rule-notifications"
}

resource "aws_sns_topic_subscription" "email_subscriptions" {
  for_each = toset(var.notification_emails)

  topic_arn = aws_sns_topic.config_rule_notifications.arn
  protocol  = "email"
  endpoint  = each.value
}

##########################
# Event Bridge rules
##########################

resource "aws_cloudwatch_event_rule" "config_compliance_change" {
  name        = "ConfigComplianceChangeRule"
  description = "Trigger when AWS Config rule compliance state changes for specific S3 rules"

  event_pattern = jsonencode({
    source      = ["aws.config"]
    detail-type = ["Config Rules Compliance Change"]
    detail = {
      messageType  = ["ComplianceChangeNotification"]
      resourceType = ["AWS::S3::Bucket"]
      configRuleName = [
        "ec2-security-group-attached-to-eni",
        "ec2-security-group-attached-to-eni2"
      ]
      newEvaluationResult = {
        complianceType = ["NON_COMPLIANT"]
      }
    }
  })

}

resource "aws_cloudwatch_event_target" "sns_target" {
  rule      = aws_cloudwatch_event_rule.config_compliance_change.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.config_rule_notifications.arn
}

resource "aws_sns_topic_policy" "allow_eventbridge_publish" {
  arn = aws_sns_topic.config_rule_notifications.arn

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid    = "Allow_EventBridge_Publish",
      Effect = "Allow",
      Principal = {
        Service = "events.amazonaws.com"
      },
      Action   = "sns:Publish",
      Resource = aws_sns_topic.config_rule_notifications.arn
    }]
  })
}
