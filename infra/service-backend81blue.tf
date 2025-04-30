# Task Definition para o Backend
resource "aws_ecs_task_definition" "backend_task" {
  family                   = "backend-service"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "backend-container"
      image     = var.container_image_test
      essential = true
      
      portMappings = [
        {
          containerPort = 8081
          hostPort      = 8081
          protocol      = "tcp"
        }
      ]
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/backend-service"
          "awslogs-region"        = "us-east-1" 
          "awslogs-stream-prefix" = "ecs"
        }
      }
      
      environment = [
        # variáveis de ambiente - API
        {
          name  = "app"
          value = "static-flaskapi-json"
        }
      ]
    }
  ])

  tags = {
    "servicegroup" = "test infra container",
  }
}

# IAM Role para execução de tarefas ECS
resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs-execution-role-backend"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    "servicegroup" = "test infra container",
  }
}

# Anexar política para o role de execução ECS
resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# IAM Role para as tarefas ECS
resource "aws_iam_role" "ecs_task_role" {
  name = "ecs-task-role-backend"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    "servicegroup" = "test infra container",
  }
}

# Grupo de logs CloudWatch para o serviço
resource "aws_cloudwatch_log_group" "backend_logs" {
  name              = "/ecs/backend-service"
  retention_in_days = 14

  tags = {
    "servicegroup" = "test infra container",
  }
}

# Serviço ECS para o Backend (modificado para CodeDeploy)
resource "aws_ecs_service" "backend_service" {
  name            = "backend-service"  # Nome genérico para o CodeDeploy
  cluster         = aws_ecs_cluster.ClusterECSBackend.id
  task_definition = aws_ecs_task_definition.backend_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  
  # Controlador de implantação CodeDeploy
  deployment_controller {
    type = "CODE_DEPLOY"  # Essencial para integração com CodeDeploy
  }

  network_configuration {
    subnets          = [
      var.subnet_backend_one,
      var.subnet_backend_two,
      var.subnet_backend_three
    ]
    security_groups  = [aws_security_group.ecs_tasks_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.alb_backend_tg_8081-blue.arn
    container_name   = "backend-container"
    container_port   = 8081
  }

  depends_on = [
    aws_lb_listener.alb_backend_listener_8081
  ]

  tags = {
    "servicegroup" = "test infra container",
    "environment"  = "production"
  }

  # Impede que o Terraform tente gerenciar a task definition após a criação
  lifecycle {
    ignore_changes = [task_definition, load_balancer]
  }
}

# Security Group para as tarefas ECS
resource "aws_security_group" "ecs_tasks_sg" {
  name        = "ecs-tasks-sg"
  description = "Security group for ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 8081
    to_port         = 8081
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_backend_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "servicegroup" = "test infra container",
  }
}