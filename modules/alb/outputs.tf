output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.alb.dns_name
}

output "alb_arn" {
  description = "ARN of the ALB"
  value       = aws_lb.alb.arn
}

output "alb_sg_id" {
  description = "ALB Security Group ID"
  value       = aws_security_group.alb_sg.id
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener"
  value       = aws_lb_listener.https.arn
}

output "target_group_blue_arn" {
  description = "ARN of the Blue Target Group"
  value       = aws_lb_target_group.blue.arn
}

output "target_group_blue_name" {
  description = "Name of the Blue Target Group"
  value       = aws_lb_target_group.blue.name
}

output "target_group_green_arn" {
  description = "ARN of the Green Target Group"
  value       = aws_lb_target_group.green.arn
}

output "target_group_green_name" {
  description = "Name of the Green Target Group"
  value       = aws_lb_target_group.green.name
}
