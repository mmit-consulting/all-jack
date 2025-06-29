variable "aws_config_org" {
  type = object({
    config_logs_bucket  = string
    notification_emails = list(string)
    excluded_accounts   = list(string)
    organization_id     = string
  })
}

variable "org_root_account_id" {
  type = string
}
