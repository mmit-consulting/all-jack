
locals {
  buckets_us_east_1 = {
    for name, region in var.bucket_region_map : name => region
    if region == "us-east-1"
  }

  buckets_us_east_2 = {
    for name, region in var.bucket_region_map : name => region
    if region == "us-west-2"
  }
}

# Define the compliance policies to enforce.
resource "aws_config_config_rule" "s3_block_public_useast1" {
  for_each = local.buckets_us_east_1

  provider = aws.us-east-1

  name = "s3-bucket-public-read-prohibited-${replace(each.key, ".", "-")}"
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }

  scope {
    compliance_resource_types = ["AWS::S3::Bucket"]
    compliance_resource_id    = each.key
  }
}

resource "aws_config_config_rule" "s3_block_public_useast2" {
  for_each = local.buckets_us_east_2

  provider = aws.us-west-2

  name = "s3-bucket-public-read-prohibited-${replace(each.key, ".", "-")}"
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }

  scope {
    compliance_resource_types = ["AWS::S3::Bucket"]
    compliance_resource_id    = each.key
  }
}

resource "aws_config_config_rule" "s3_acl_prohibited_useast1" {
  for_each = local.buckets_us_east_1

  provider = aws.us-east-1

  name = "s3-bucket-acl-prohibited-${replace(each.key, ".", "-")}"
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_ACL_PROHIBITED"
  }

  scope {
    compliance_resource_types = ["AWS::S3::Bucket"]
    compliance_resource_id    = each.key
  }
}

resource "aws_config_config_rule" "s3_acl_prohibited_useast2" {
  for_each = local.buckets_us_east_2

  provider = aws.us-west-2

  name = "s3-bucket-acl-prohibited-${replace(each.key, ".", "-")}"
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_ACL_PROHIBITED"
  }

  scope {
    compliance_resource_types = ["AWS::S3::Bucket"]
    compliance_resource_id    = each.key
  }
}
