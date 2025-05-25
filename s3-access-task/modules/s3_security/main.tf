# Block public access
resource "aws_s3_bucket_public_access_block" "secure" {
  for_each = toset(var.bucket_names)
  bucket   = each.key

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

