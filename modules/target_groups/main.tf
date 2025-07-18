resource "aws_lb_target_group" "blue" {
  for_each = { for svc in var.services : svc.service_name => svc }

  name        = each.value.blue_target_group_name
  port        = var.target_group_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = var.health_check_path
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  tags = {
    Name = "${var.alb_name}-${each.key}-blue-tg"
  }
}

resource "aws_lb_target_group" "green" {
  for_each = { for svc in var.services : svc.service_name => svc }

  name        = each.value.green_target_group_name
  port        = var.target_group_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = var.health_check_path
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  tags = {
    Name = "${var.alb_name}-${each.key}-green-tg"
  }
}


