# AWS Config Organization Module (Master Account)

This module sets up AWS Config rules, EventBridge rules, and an SNS topic to notify via email/Slack when non-compliance is detected across AWS sub-accounts. It is meant to be deployed in the **master account** of the AWS Organization.

---

## 📌 Features

- Enables AWS Config with global resource recording
- Stores AWS Config logs in a central S3 bucket
- Defines managed AWS Config rules
- Creates EventBridge rules that catch compliance changes (e.g., S3 public access)
- Forwards critical compliance changes to an SNS topic
- Allows notifications to be sent to email and Slack
- Allows sub-accounts to forward events to the root EventBridge

---

## 📊 Architecture

![Architecture](./diagram.png)

---

## ⚙️ Module Inputs

| Name                   | Type    | Description                                 | Required |
|------------------------|---------|---------------------------------------------|----------|
| `config_logs_bucket`   | string  | Name of the central S3 bucket               | ✅ Yes   |
| `notification_emails` | list    | List of email endpoints (emails and/or Slack webhook emails) | ✅ Yes   |
| `excluded_accounts`    | list    | List of AWS account IDs to exclude from rules | ✅ Yes   |
| `organization_id`      | string  | AWS Organization ID                         | ✅ Yes   |

---

## 🛠️ Resources Created

- S3 Bucket Policy for AWS Config
- IAM Role for AWS Config Recorder
- AWS Config Configuration Recorder
- AWS Config Delivery Channel
- Managed Config Rules:
  - `S3_BUCKET_PUBLIC_READ_PROHIBITED`
  - `S3_BUCKET_ACL_PROHIBITED`
- SNS Topic and subscriptions
- EventBridge Rule for non-compliant changes
- EventBridge permission to allow `PutEvents` from org accounts

---

## 📤 Notifications

- Emails (via SNS)
- Slack (if Slack email gateway is used)

---

## 🔐 Permissions

This module grants the `events.amazonaws.com` service permission to publish to SNS and allows other org accounts to send events to the default event bus.

---

## 📎 Example Usage

```hcl
module "aws_config_org" {
  source = "PATH_TO/aws_config_org"

  config_logs_bucket   = "my-central-config-bucket"
  notification_emails  = ["compliance@domain.com", "slack-webhook@workspace.slack.com"]
  excluded_accounts    = ["123456789012"]
  organization_id      = "o-xxxxxxxxxx"
}
