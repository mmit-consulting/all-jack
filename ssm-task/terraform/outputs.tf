output "instance_profile" {
  value = module.ssm.ssm_instance_profile
}

output "role_name" {
  value = module.ssm.ssm_role_name
}
