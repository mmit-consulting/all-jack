aws_config_org ={
  config_logs_bucket = "my-org-config-logs-bucket-us-east-1"
  notification_emails = [
    "admin@example.com"
  ]
  excluded_accounts = [ "111122223333", "444455556666" ] 
  organization_id = "o-xxxxxxx"
}

org_root_account_id = "xxxxxx"