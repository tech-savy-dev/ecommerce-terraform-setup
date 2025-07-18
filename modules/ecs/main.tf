
resource "aws_ecs_cluster" "this" {
  name = var.cluster_name
}

resource "aws_ecs_task_definition" "this" {
  for_each = { for task in var.ecs_tasks : task.task_name => task }

  family                   = each.value.task_family
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = each.value.cpu
  memory                   = each.value.memory
  execution_role_arn       = var.ecs_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = each.value.container_name
      image     = each.value.image_url
      portMappings = [
        {
          containerPort = each.value.container_port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${each.value.service_name}"
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_security_group" "ecs_security_group" {
  name        = "${var.service_name}-ecs-sg"
  description = "Security group for ECS services"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]  # Allow traffic from ALB security group
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"   # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.service_name}-ecs-sg"
  }
}

resource "aws_ecs_service" "this" {
  for_each = { for task in var.ecs_tasks : task.service_name => task }

  name            = each.value.service_name
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this[each.key].arn
  desired_count   = each.value.desired_count
  launch_type     = "FARGATE"

  deployment_controller {
    type = each.value.use_codedeploy ? "CODE_DEPLOY" : "ECS"
  }

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.ecs_security_group.id]
    assign_public_ip = each.value.assign_public_ip
  }

   dynamic "load_balancer" {
    for_each = each.value.use_codedeploy ? [1] : []
    content {
      target_group_arn = var.blue_target_group_arns[each.key]
      container_name   = each.value.container_name
      container_port   = each.value.container_port
    }
  }


  lifecycle {
    ignore_changes = [
      task_definition,
      desired_count
    ]
  }
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  for_each = { for task in var.ecs_tasks : task.service_name => task }

  name              = "/ecs/${each.value.service_name}"
  retention_in_days = 7

  tags = {
    Name = "ecs-${each.value.service_name}-logs"
  }
}
