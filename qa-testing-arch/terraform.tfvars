#### Global ####
region = "eu-west-3"
#### ECR Repository ####
ecr_name                = "qa/mobile/testing"
image_scanning          = false
tag_immutability        = "MUTABLE"
lifecycle_expire_days   = 90
#### ECS IAM Role ####
ecs_role_name                 = "qa.mobile.testing"
ecs_custom_policy_name        = "ECS.Full"
ecs_custom_policy_description = "Full access placeholder for ECS (to be updated)"
ecs_custom_policy_statements = [
  {
    Effect   = "Allow",
    Action   = ["ecs:*"],
    Resource = "*"
  }
]
#### ECS Task Definition ####
ecs_cluster_name                = "qa-mobile-testing-cluster"
ecs_service_name               = "qa-mobile-testing-service"
ecs_task_cpu                   = 2048
ecs_task_memory                = 5120
ecs_container_memory_reservation = 4096
ecs_container_name             = "qa-mobile-testing"
ecs_container_image            = "123456789012.dkr.ecr.eu-west-3.amazonaws.com/qa/mobile/testing:latest"
ecs_log_group                  = "/ecs/qa-mobile-testing"
ecs_operating_system_family    = "LINUX"
ecs_cpu_architecture           = "X86_64"
subnet_ids                     = ["subnet-091d4d7a7980a6a8d", "subnet-014817b95e367b258"]
#### GHActions Role ####
gha_role_name              = "GHActions-ECR"
github_oidc_provider_arn  = "arn:aws:iam::008270691738:oidc-provider/token.actions.githubusercontent.com"
github_oidc_sub           = "repo:midwest-tape/internal-epub-ingest:*"
passrole_policies = {
  "PassRole.dnet_AudioIngestRole" = "arn:aws:iam::YOUR_ACCOUNT_ID:role/dnet_AudioIngestRole"
  "PassRole.dnet_ComicIngestRole" = "arn:aws:iam::YOUR_ACCOUNT_ID:role/dnet_ComicIngestRole"
  "PassRole.dnet_EpubIngestRole"  = "arn:aws:iam::YOUR_ACCOUNT_ID:role/dnet_EpubIngestRole"
}