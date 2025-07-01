#### Global ####
variable "region" {
  description = "AWS Region"
  type = string
  default = "eu-west-3"
}
#### ECR Repository ####
variable "ecr_name" {
  description = "Name of the ECR repository (can include slashes)"
  type        = string
}

variable "image_scanning" {
  description = "Enable image scanning on push"
  type        = bool
  default     = false
}

variable "tag_immutability" {
  description = "Image tag mutability setting"
  type        = string
  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.tag_immutability)
    error_message = "Must be either 'MUTABLE' or 'IMMUTABLE'."
  }
}

variable "lifecycle_expire_days" {
  description = "Days after which untagged images are expired"
  type        = number
}

#### ECS IAM Role ####

variable "ecs_role_name" {
  description = "Name of the ECS IAM Role"
  type        = string
}

variable "ecs_custom_policy_name" {
  description = "Name of the custom ECS policy"
  type        = string
}

variable "ecs_custom_policy_description" {
  description = "Description for the custom ECS policy"
  type        = string
}

variable "ecs_custom_policy_statements" {
  description = "List of IAM policy statements for the ECS.Full policy"
  type        = any
}

#### ECS Task definition ####
variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "ecs_service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "ecs_task_cpu" {
  description = "vCPU units for the ECS task (e.g., 2048 for 2 vCPU)"
  type        = number
}

variable "ecs_task_memory" {
  description = "Hard memory limit for the ECS task in MiB (e.g., 5120 for 5GB)"
  type        = number
}

variable "ecs_container_memory_reservation" {
  description = "Soft memory limit for the container (in MiB)"
  type        = number
}

variable "ecs_container_name" {
  description = "Name of the container"
  type        = string
}

variable "ecs_container_image" {
  description = "Full container image URI (e.g., from ECR)"
  type        = string
}

variable "ecs_log_group" {
  description = "CloudWatch log group for ECS logs"
  type        = string
}

variable "ecs_operating_system_family" {
  description = "ECS runtime OS (e.g., LINUX)"
  type        = string
}

variable "ecs_cpu_architecture" {
  description = "ECS CPU architecture (e.g., X86_64)"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for the ECS service"
  type        = list(string)
}

#### GHActions Role ####
variable "gha_role_name" {
  description = "Name of the GitHub Actions role"
  type        = string
}

variable "github_oidc_provider_arn" {
  description = "OIDC provider ARN for GitHub"
  type        = string
}

variable "github_oidc_sub" {
  description = "GitHub OIDC sub value (e.g., repo:org/repo:* )"
  type        = string
}
variable "passrole_policies" {
  description = "Map of policy name => role ARN for PassRole policies"
  type = map(string)
}

#### API Gateway ####
