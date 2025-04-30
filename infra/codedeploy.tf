# CodeDeploy para implantações Blue/Green
resource "aws_codedeploy_app" "backend_app" {
  name             = "backend-deployment-app"
  compute_platform = "ECS"
}

# IAM Role para o CodeDeploy
resource "aws_iam_role" "codedeploy_role" {
  name = "codedeploy-backend-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      }
    ]
  })
}

# Anexar políticas necessárias para o CodeDeploy
resource "aws_iam_role_policy_attachment" "codedeploy_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
  role       = aws_iam_role.codedeploy_role.name
}

# Grupo de Implantação do CodeDeploy
resource "aws_codedeploy_deployment_group" "backend_deployment_group" {
  app_name               = aws_codedeploy_app.backend_app.name
  deployment_group_name  = "backend-deployment-group"
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"  # Opção mais econômica
  service_role_arn       = aws_iam_role.codedeploy_role.arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.ClusterECSBackend.name
    service_name = aws_ecs_service.backend_service.name
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.alb_backend_listener_8081.arn]
      }

      target_group {
        name = aws_lb_target_group.alb_backend_tg_8081-blue.name
      }

      target_group {
        name = aws_lb_target_group.alb_backend_tg_8081-green.name
      }
    }
  }
}

# Criação de um bucket S3 para artefatos
resource "aws_s3_bucket" "artifact_bucket" {
  bucket = "backend-deployment-artifacts-${data.aws_caller_identity.current.account_id}"
  force_destroy = true  # Para facilitar a limpeza em ambientes de teste
}

resource "aws_s3_bucket_ownership_controls" "artifact_bucket_ownership" {
  bucket = aws_s3_bucket.artifact_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "artifact_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.artifact_bucket_ownership]
  bucket = aws_s3_bucket.artifact_bucket.id
  acl    = "private"
}

data "aws_caller_identity" "current" {}