cloudtrail_logs_bucket="jack-infra-bucket"
cloudwatch_log_group="/aws/cloudtrail/s3-security-monitoring"
emails = ["mahdiibouaziz@gmail.com"]
bucket_names = [
    "mahdi-test-object-jack2", 
    "mahdi-test-jack-bucket",
    "mahdi-test-jack-bucket-useast2"    
]

bucket_region_map = {
  "mahdi-test-jack-bucket"         = "us-east-1"
  "mahdi-test-object-jack2"        = "us-east-1"
  "mahdi-test-jack-bucket-useast2" = "us-west-2"
}