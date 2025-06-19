# Network Infrastructure — Terraform

This project defines the **network infrastructure** for the environment, using the official [terraform-aws-modules/vpc/aws](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest) module and dynamic security group creation.

---

## Features

✅ VPC with CIDR `10.103.0.0/16`  
✅ 6 subnets:

- 3 public subnets
- 3 private subnets  
  ✅ Spread across **2 AZs** (`us-east-1a` and `us-east-1b`)

✅ NAT Gateways:

- 1 NAT Gateway per AZ (total: 2 NAT Gateways)
- Used for private subnet outbound traffic

✅ Internet Gateway:

- Automatically created and attached

✅ VPC Endpoint:

- S3 Gateway Endpoint created via the `vpc-endpoints` submodule

✅ Dynamic Security Groups:

- Security Groups and rules are fully defined via a variable (`security_groups`)
- Supports any number of SGs and rules (ingress / egress)

✅ Tags applied to all resources

---

## Structure

```
├── main.tf # VPC core configuration
├── variables.tf # Input variables
├── outputs.tf # Useful outputs
├── terraform.tfvars # Environment-specific values (CIDRs, tags, SGs, etc.)
├── providers.tf # AWS provider definition
└── README.md # This file
```
