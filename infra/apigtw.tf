# API Gateway para Backend
resource "aws_api_gateway_rest_api" "backend_api" {
  name        = "backend-api"
  description = "API para o backend"
}

# Método para o recurso raiz
resource "aws_api_gateway_method" "root_method" {
  rest_api_id   = aws_api_gateway_rest_api.backend_api.id
  resource_id   = aws_api_gateway_rest_api.backend_api.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "root_integration" {
  rest_api_id = aws_api_gateway_rest_api.backend_api.id
  resource_id = aws_api_gateway_rest_api.backend_api.root_resource_id
  http_method = aws_api_gateway_method.root_method.http_method
  
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = "http://${aws_lb.NLBBackend.dns_name}:8081/"  # Especifica a porta
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.VPCLinkBackend.id
}

# # Integração para o recurso raiz
# resource "aws_api_gateway_integration" "root_integration" {
#   rest_api_id = aws_api_gateway_rest_api.backend_api.id
#   resource_id = aws_api_gateway_rest_api.backend_api.root_resource_id
#   http_method = aws_api_gateway_method.root_method.http_method
  
#   type                    = "HTTP_PROXY"
#   integration_http_method = "ANY"
#   uri                     = "http://${aws_lb.NLBBackend.dns_name}"
#   connection_type         = "VPC_LINK"
#   connection_id           = aws_api_gateway_vpc_link.VPCLinkBackend.id
# }

# Deployment da API
resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    aws_api_gateway_integration.root_integration
  ]
  
  rest_api_id = aws_api_gateway_rest_api.backend_api.id
  stage_name  = "dev"
  
  lifecycle {
    create_before_destroy = true
  }
    # Adicione isso para forçar um novo deployment
  triggers = {
    redeployment = "${timestamp()}"
  }
}

# Output da URL da API
output "api_url_gateway" {
  value = aws_api_gateway_deployment.api_deployment.invoke_url
  description = "URL da API Gateway"
}
