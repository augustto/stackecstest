# Target group do NLB para porta 8081
resource "aws_lb_target_group" "nlb_backend_tg_8081" {
  name        = "tg-nlbback-8081"  # Nome mais específico indicando a porta
  port        = 8081
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "alb"

  health_check {
    enabled             = true
    protocol            = "HTTP"
    port                = 8081
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 10
    interval            = 30
    path                = "/health"
  }
}

# Listener do NLB para porta 8081
resource "aws_lb_listener" "nlb_backend_listener_8081" {
  load_balancer_arn = aws_lb.NLBBackend.arn
  port              = 8081
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_backend_tg_8081.arn
  }
}

# Attachment do ALB ao NLB para porta 8081
resource "aws_lb_target_group_attachment" "nlb_to_alb_attachment_8081" {
  target_group_arn = aws_lb_target_group.nlb_backend_tg_8081.arn
  target_id        = aws_lb.ALBBanckend.arn
  port             = 8081

  # Corrigindo a dependência para o novo nome do listener
  depends_on = [aws_lb_listener.alb_backend_listener_8081]
}