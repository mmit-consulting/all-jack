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
    aws_config_configuration_recorder.this
  ]
}

##########################
# Organization Managed Rules
##########################

resource "aws_config_organization_managed_rule" "s3_block_public" {
  name                        = "org-s3-block-public-read-prohibited"
  rule_identifier             = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  maximum_execution_frequency = "Six_Hours"
  resource_types_scope        = ["AWS::S3::Bucket"]
  depends_on = [
    aws_config_delivery_channel.this
  ]
}

resource "aws_config_organization_managed_rule" "s3_acl_prohibited" {
  name                        = "org-s3-acl-prohibited"
  rule_identifier             = "S3_BUCKET_ACL_PROHIBITED"
  maximum_execution_frequency = "Six_Hours"
  resource_types_scope        = ["AWS::S3::Bucket"]
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
# Avent Bridge rules
##########################

resource "aws_cloudwatch_event_rule" "config_compliance_change" {
  name        = "ConfigComplianceChangeRule"
  description = "Trigger when AWS Config rule compliance state changes for specific S3 rules"

  event_pattern = jsonencode({
    source = ["aws.config"],
    "detail-type" : ["Config Rules Compliance Change"],
    detail = {
      complianceType = ["NON_COMPLIANT"],
      configRuleName = [
        "org-s3-block-public-read-prohibited",
        "org-s3-acl-prohibited"
      ]
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
