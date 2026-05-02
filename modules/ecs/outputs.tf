output "ecs_service_arns" {
  description = "Map of ECS service ARNs"
  value       = { for k, v in aws_ecs_service.this : k => v.arn }
}

output "ecs_task_definition_arns" {
  description = "Map of ECS task definition ARNs"
  value       = { for k, v in aws_ecs_task_definition.this : k => v.arn }
}

output "ecs_security_group_id" {
  description = "Security group ID used for ECS services in this module instance"
  value       = aws_security_group.ecs_security_group.id
}
