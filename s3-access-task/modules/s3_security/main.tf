# Block public access
# 1 block per region -> if you have other regions, we should add other blocks
resource "aws_s3_bucket_public_access_block" "secure_us_east_1" {
  for_each = {
    for name, region in var.bucket_region_map : name => region
    if region == "us-east-1"
  }

  provider = aws.us-east-1

  bucket = each.key

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "secure_us_east_2" {
  for_each = {
    for name, region in var.bucket_region_map : name => region
    if region == "us-east-2"
  }

  provider = aws.us-east-2

  bucket                  = each.key
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# # Disable ACLs - TODO to uncomment after 3 to 7 days
# resource "aws_s3_bucket_ownership_controls" "disable_acls" {
#   for_each = toset(var.bucket_names)
#   bucket   = each.key

#   rule {
#     object_ownership = "BucketOwnerEnforced" # use "BucketOwnerPreferred" if you want to enable ACL back
#   }
# }

