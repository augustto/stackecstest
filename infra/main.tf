resource "aws_ecs_cluster" "ClusterECSBackend" {
  name = var.cluster_name_backend
  tags = {
      "team-email" = var.team-email
  }
  setting {
      name  = "containerInsights"
      value = var.container_insights
    }
}
resource "aws_ecs_cluster_capacity_providers" "CapacityProviderClusterBackend" {
  cluster_name = aws_ecs_cluster.ClusterECSBackend.name
  capacity_providers = [var.capacity_provider]
  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = var.capacity_provider
  }
}
resource "aws_lb" "NLBBackend" {
  name               = var.nlb_name_backend
  load_balancer_type = "network"
  internal           = true
  subnets            = [
    var.subnet_backend_one,
    var.subnet_backend_two,
    var.subnet_backend_three
  ]
  enable_cross_zone_load_balancing = true
  enable_deletion_protection       = false
  tags                             = {
    "LoadBalancerType" = "VPCLink",
    "team-email" = var.team-email
  }
}
resource "aws_api_gateway_vpc_link" "VPCLinkBackend" {
  name        = var.vpclink_name_backend
  description = var.vpclink_description
  target_arns = [aws_lb.NLBBackend.arn]
}

