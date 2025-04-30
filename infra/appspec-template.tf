# In a new file called appspec-template.tf
resource "local_file" "appspec_template" {
  content = jsonencode({
    version = 0.0,
    Resources = [{
      TargetService = {
        Type = "AWS::ECS::Service",
        Properties = {
          TaskDefinition = "<TASK_DEFINITION>",
          LoadBalancerInfo = {
            ContainerName = "backend-container",
            ContainerPort = 8081
          }
        }
      }
    }]
  })
  filename = "${path.module}/appspec.json"
}