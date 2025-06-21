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
}
