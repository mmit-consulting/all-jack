# AWS Config Forwarder Module (Sub-Accounts)

This module is designed to be deployed in **AWS sub-accounts** of an organization (internal, ecom, hopla, ...). It captures AWS Config compliance changes and forwards them to the root/master account’s EventBridge bus.

---

## 📌 Features

- Captures AWS Config non-compliant events (e.g., S3 rules)
- Forwards events to the root account via EventBridge
- Uses a cross-account IAM role to allow `PutEvents` to root

---

## 📊 Architecture

![Architecture](./diagram.png)

---

## ⚙️ Module Inputs

| Name                    | Type   | Description                                  | Required |
|-------------------------|--------|----------------------------------------------|----------|
| `org_root_account_id`   | string | AWS Account ID of the root/master account    | ✅ Yes   |

---

## 🛠️ Resources Created

- IAM Role to allow EventBridge cross-account `PutEvents`
- EventBridge rule to capture AWS Config changes
- EventBridge target pointing to the root account default bus

---

## 🔐 Permissions

The IAM role and policy allow `events.amazonaws.com` to assume the role and `PutEvents` to the root account EventBridge default event bus.

---

## 📎 Example Usage

```hcl
module "aws_confieventbridge_forwarder" {
  source = "PATH_TO/aws_config_eventbridge_forwarder"

  org_root_account_id = "111122223333"
}
```
