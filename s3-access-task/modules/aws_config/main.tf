# Prepare the required policies for s3 bucket used by cloudtrail and config
# data "aws_caller_identity" "current" {}

# resource "aws_s3_bucket_policy" "config_policy" {
#   bucket = var.config_logs_bucket

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       # AWS Config Part
#       {
#         Sid    = "AWSConfigPutObject",
#         Effect = "Allow",
#         Principal = {
#           Service = "config.amazonaws.com"
#         },
#         Action   = "s3:PutObject",
#         Resource = "arn:aws:s3:::${var.config_logs_bucket}/AWSLogs/${data.aws_caller_identity.current.account_id}/Config/*",
#         Condition = {
#           StringEquals = {
#             "s3:x-amz-acl" = "bucket-owner-full-control"
#           }
#         }
#       },
#       {
#         Sid    = "AWSConfigGetBucketAcl",
#         Effect = "Allow",
#         Principal = {
#           Service = "config.amazonaws.com"
#         },
#         Action   = "s3:GetBucketAcl",
#         Resource = "arn:aws:s3:::${var.config_logs_bucket}"
#       }
#     ]
#   })
# }


# # Preapre IAM role for config
# resource "aws_iam_role" "config" {
#   name = "AWSConfigRole"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Action = "sts:AssumeRole",
#       Effect = "Allow",
#       Principal = {
#         Service = "config.amazonaws.com"
#       }
#     }]
#   })
# }

# resource "aws_iam_role_policy_attachment" "config_policy" {
#   role       = aws_iam_role.config.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
# }

# # Create a recorder that records resource config changes (s3 in this case)
# resource "aws_config_configuration_recorder" "main" {
#   name     = "default"
#   role_arn = aws_iam_role.config.arn

#   recording_group {
#     all_supported                 = false
#     resource_types                = ["AWS::S3::Bucket"]
#     include_global_resource_types = false
#   }
# }

# # Create a channel to store logs in S3 for auditing.
# resource "aws_config_delivery_channel" "main" {
#   name           = "default"
#   s3_bucket_name = var.config_logs_bucket
#   depends_on     = [aws_config_configuration_recorder.main]
# }


# Define the compliance policies to enforce.
resource "aws_config_config_rule" "s3_block_public" {
  for_each = toset(var.bucket_names)

  name = "s3-bucket-public-read-prohibited-${replace(each.key, ".", "-")}"
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }

  scope {
    compliance_resource_types = ["AWS::S3::Bucket"]
    compliance_resource_id    = each.key
  }
  # depends_on = [aws_config_delivery_channel.main]
}

resource "aws_config_config_rule" "s3_acl_prohibited" {
  for_each = toset(var.bucket_names)

  name = "s3-bucket-acl-prohibited-${replace(each.key, ".", "-")}"
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_ACL_PROHIBITED"
  }

  scope {
    compliance_resource_types = ["AWS::S3::Bucket"]
    compliance_resource_id    = each.key
  }
  # depends_on = [aws_config_delivery_channel.main]
}
