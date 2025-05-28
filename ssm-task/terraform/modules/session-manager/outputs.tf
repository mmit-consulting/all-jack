output "ssm_role_name" {
  value = aws_iam_role.ssm_instance_role.name
}

output "ssm_instance_profile" {
  value = aws_iam_instance_profile.ssm_profile.name
}
