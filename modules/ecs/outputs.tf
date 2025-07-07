# modules/ecs/outputs.tf

output "ecs_cluster_id" {
  value = aws_ecs_cluster.this.id
}

output "ecs_service_names" {
  value = [for service in aws_ecs_service.this : service.name]
}

output "ecs_security_group_id" {
  value = aws_security_group.ecs_security_group.id
  description = "The security group ID for the ECS service"
}
