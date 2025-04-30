variable "team-email" {
  description = "Tag Owner e-mail"
  default     = "devteam@mailer.com"
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC onde os recursos serão criados"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR da VPC para regras de ingress"
  type        = string
  default     = "172.12.0.0/22"
}

variable "container_image_test" {
  description = "Imagem do container para o serviço ECS"
  type        = string
}


variable "cluster_name_backend" {
  description = "Nome do cluster do backend"
  default     = "cluster-mainstack-backend"
  type        = string
}

variable "nlb_name_backend" {
  description = "Nome do NetworkLoadBalancer do backend"
  default     = "nlb-mainstack-backend"
  type        = string
}

variable "alb_name_backend" {
  description = "Nome do NetworkLoadBalancer do backend"
  default     = "alb-mainstack-backend"
  type        = string
}

variable "vpclink_name_backend" {
  description = "Nome do NetworkLoadBalancer do backend"
  default     = "vpclink-mainstack-backend"
  type        = string
}

variable "vpclink_description" {
  default = "Permite a conexão do API Gateway com o Network Load Balancer de Backend/Frontend"
  type    = string
}

variable "container_insights" {
  description = "Valores validos enabled/disabled para o container_insights"
  default     = "enabled"
}

variable "subnet_backend_one" {
  description = "Subnet privada do backend AZ-A"
  type        = string
}

variable "subnet_backend_two" {
  description = "Subnet privada do backend AZ-B"
  type        = string
}

variable "subnet_backend_three" {
  description = "Subnet privada do backend AZ-C"
  type        = string
}

variable "capacity_provider" {
  default     = "FARGATE_SPOT"
  type        = string
  description = "Tipo de Capacidade que será utilizada no Cluster Amazon ECS"
}
