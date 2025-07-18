output "blue_target_group_arns" {
  value = {
    for svc, tg in aws_lb_target_group.blue : svc => tg.arn
  }
}

output "green_target_group_arns" {
  value = {
    for svc, tg in aws_lb_target_group.green : svc => tg.arn
  }
}

output "blue_target_group_names" {
  value = {
    for svc, tg in aws_lb_target_group.blue : svc => tg.name
  }
}

output "green_target_group_names" {
  value = {
    for svc, tg in aws_lb_target_group.green : svc => tg.name
  }
}
