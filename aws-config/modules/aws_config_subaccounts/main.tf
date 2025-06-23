# Prepare required event rule
resource "aws_iam_role" "eventbridge_cross_account" {
  name = "EventBridgePutEventsToRoot"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "events.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "eventbridge_put_policy" {
  name = "AllowPutEventsToRootBus"
  role = aws_iam_role.eventbridge_cross_account.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = "events:PutEvents",
      Resource = "arn:aws:events:us-east-1:${var.org_root_account_id}:event-bus/default"
    }]
  })
}

resource "aws_cloudwatch_event_rule" "forward_config_compliance" {
  name        = "ForwardConfigComplianceToRoot"
  description = "Forwards Config NON_COMPLIANT S3 events to root account"
  event_pattern = jsonencode({
    source      = ["aws.config"],
    detail-type = ["Config Rules Compliance Change"],
    detail = {
      messageType  = ["ComplianceChangeNotification"],
      resourceType = ["AWS::S3::Bucket"],
      newEvaluationResult = {
        complianceType = ["NON_COMPLIANT"]
      }
    }
  })
}


resource "aws_cloudwatch_event_target" "send_to_root_account" {
  rule      = aws_cloudwatch_event_rule.forward_config_compliance.name
  target_id = "ForwardToRoot"
  arn       = "arn:aws:events:us-east-1:${var.org_root_account_id}:event-bus/default"
  role_arn  = aws_iam_role.eventbridge_cross_account.arn
}
