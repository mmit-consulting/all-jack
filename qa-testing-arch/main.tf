#### ECR Repository ####
module "ecr_repository" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 1.0"

  repository_name = var.ecr_name

  repository_image_scan_on_push = var.image_scanning
  repository_image_tag_mutability = var.tag_immutability

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Expire untagged images older than ${var.lifecycle_expire_days} days",
        selection = {
          tagStatus     = "untagged",
          countType     = "sinceImagePushed",
          countUnit     = "days",
          countNumber   = var.lifecycle_expire_days
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}

#### ECS IAM Role ####
resource "aws_iam_role" "ecs_role" {
  name = var.ecs_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "ecs_full" {
  name        = var.ecs_custom_policy_name
  description = var.ecs_custom_policy_description

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = var.ecs_custom_policy_statements
  })
}

resource "aws_iam_role_policy_attachment" "ecs_full_attach" {
  role       = aws_iam_role.ecs_role.name
  policy_arn = aws_iam_policy.ecs_full.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_attach" {
  role       = aws_iam_role.ecs_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#### ECS Cluster & Task definition ####

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = var.ecs_log_group
  retention_in_days = 7
}

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 5.0"

  cluster_name = var.ecs_cluster_name

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 1
      }
    }
  }

  services = {
    "${var.ecs_service_name}" = {
      launch_type   = "FARGATE"
      cpu           = var.ecs_task_cpu
      memory        = var.ecs_task_memory
      desired_count = 1

      task_exec_iam_role_arn = aws_iam_role.ecs_role.arn
      task_role_arn          = aws_iam_role.ecs_role.arn

      runtime_platform = {
        operating_system_family = var.ecs_operating_system_family
        cpu_architecture        = var.ecs_cpu_architecture
      }

      container_definitions = {
        "${var.ecs_container_name}" = {
          name                = var.ecs_container_name
          image               = var.ecs_container_image
          essential           = true
          memory_reservation  = var.ecs_container_memory_reservation
          memory              = var.ecs_task_memory

          log_configuration = {
            logDriver = "awslogs"
            options = {
              awslogs-group         = var.ecs_log_group
              awslogs-region        = "eu-west-3"
              awslogs-stream-prefix = var.ecs_container_name
            }
          }

          port_mappings = [
            {
              containerPort = 80
              protocol      = "tcp"
            }
          ]
        }
      }

      subnet_ids = var.subnet_ids

      security_group_rules = {
        egress_all = {
          type        = "egress"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }
}
