output "cloudtrail_alarm_arn" {
  value = aws_cloudwatch_metric_alarm.s3_change_alert.arn
}

output "cloudtrail_log_group" {
  value = aws_cloudwatch_log_group.trail_logs.name
}
