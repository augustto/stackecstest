# Template para a definição de tarefa
resource "local_file" "taskdef_template" {
  content = jsonencode({
    executionRoleArn = aws_iam_role.ecs_execution_role.arn,
    containerDefinitions = [
      {
        name = "backend-container",
        image =  var.container_image_test,
        essential = true,
        portMappings = [
          {
            containerPort = 8081,
            hostPort = 8081,
            protocol = "tcp"
          }
        ],
        logConfiguration = {
          logDriver = "awslogs",
          options = {
            "awslogs-group" = "/ecs/backend-service",
            "awslogs-region" = "us-east-1",
            "awslogs-stream-prefix" = "ecs"
          }
        },
        environment = [
          {
            name = "app",
            value = "static-flaskapi-json"
          }
        ]
      }
    ],
    family = "backend-service",
    networkMode = "awsvpc",
    requiresCompatibilities = ["FARGATE"],
    cpu = "256",
    memory = "512",
    taskRoleArn = aws_iam_role.ecs_task_role.arn
  })
  filename = "${path.module}/taskdef.json"
}