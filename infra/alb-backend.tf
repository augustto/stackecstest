# Application Load Balancer para Backend
resource "aws_lb" "ALBBanckend" {
  name               = "${var.alb_name_backend}"
  load_balancer_type = "application"
  internal           = false
  subnets            = [
    var.subnet_backend_one,
    var.subnet_backend_two,
    var.subnet_backend_three
  ]
  security_groups    = [aws_security_group.alb_backend_sg.id]
  
  enable_deletion_protection = false
  
  tags = {
    "team-email" = var.team-email 
  }
}

# Security group para o ALB
resource "aws_security_group" "alb_backend_sg" {
  name        = "alb-backend-sg"
  description = "Security group for backend ALB"
  vpc_id      = var.vpc_id

  # ingress {
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   cidr_blocks = [var.vpc_cidr] 
  # }
  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "team-email" = var.team-email,
  }
}


# ALB CONFIG 8081
# Target Group Blue para a porta 8081
resource "aws_lb_target_group" "alb_backend_tg_8081-blue" {
  name        = "tg-albback-8081-blue"
  port        = 8081
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    path                = "/health"
    port                = "traffic-port"
    healthy_threshold   = 6
    unhealthy_threshold = 6
    timeout             = 20
    interval            = 60
    matcher             = "200"
  }
}

# Target Group Green para a porta 8081
resource "aws_lb_target_group" "alb_backend_tg_8081-green" {
  name        = "tg-albback-8081-green"
  port        = 8081
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    path                = "/health"
    port                = "traffic-port"
    healthy_threshold   = 6
    unhealthy_threshold = 6
    timeout             = 20
    interval            = 60
    matcher             = "200"
  }
}

# Listener para a porta 8081 com suporte a Blue/Green
resource "aws_lb_listener" "alb_backend_listener_8081" {
  load_balancer_arn = aws_lb.ALBBanckend.arn
  port              = 8081
  protocol          = "HTTP"

  default_action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.alb_backend_tg_8081-blue.arn
        weight = var.blue_weight_8081
      }
      
      target_group {
        arn    = aws_lb_target_group.alb_backend_tg_8081-green.arn
        weight = var.green_weight_8081
      }
      
      stickiness {
        enabled  = true
        duration = 600  # 10 minutos
      }
    }
  }
}

# Variáveis para controlar a distribuição de tráfego
variable "blue_weight_8081" {
  description = "Peso para distribuição de tráfego para o ambiente blue na porta 8081 (0-100)"
  type        = number
  default     = 100  # Inicialmente 100% para blue
}

variable "green_weight_8081" {
  description = "Peso para distribuição de tráfego para o ambiente green na porta 8081 (0-100)"
  type        = number
  default     = 0    # Inicialmente 0% para green
}