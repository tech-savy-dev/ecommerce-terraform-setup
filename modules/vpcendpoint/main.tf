resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.subnet_ids
  security_group_ids  = [var.security_group_id]
  private_dns_enabled = true
  tags = {
    Name = "ecommerce-api-endpoint"
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.subnet_ids
  security_group_ids  = [var.security_group_id]
  private_dns_enabled = true
   tags = {
    Name = "ecommerce-dkr-endpoint"
  }
}

resource "aws_vpc_endpoint" "ecs_sts" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.sts"
  vpc_endpoint_type = "Interface"
  subnet_ids        = var.subnet_ids
  security_group_ids = [var.security_group_id]

  private_dns_enabled = true

  tags = {
    Name = "ecommerce-sts-endpoint"
  }
}

resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id             = var.vpc_id
  service_name       = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type  = "Gateway"
  route_table_ids    = var.route_table_ids

  tags = {
    Name = "ecommerce-s3-gateway-endpoint"
  }
}

# ================= ECS-RELATED ENDPOINTS ================= #

resource "aws_vpc_endpoint" "ecs" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ecs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.subnet_ids
  security_group_ids  = [var.security_group_id]
  private_dns_enabled = true

  tags = {
    Name = "ecommerce-ecs-endpoint"
  }
}

resource "aws_vpc_endpoint" "ecs_agent" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ecs-agent"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.subnet_ids
  security_group_ids  = [var.security_group_id]
  private_dns_enabled = true

  tags = {
    Name = "ecommerce-ecs-agent-endpoint"
  }
}

resource "aws_vpc_endpoint" "ecs_telemetry" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ecs-telemetry"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.subnet_ids
  security_group_ids  = [var.security_group_id]
  private_dns_enabled = true

  tags = {
    Name = "ecommerce-ecs-telemetry-endpoint"
  }
}

resource "aws_vpc_endpoint" "cloudwatch_logs" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.subnet_ids
  security_group_ids  = [var.security_group_id]
  private_dns_enabled = true

  tags = {
    Name = "ecommerce-cloudwatch-logs-endpoint"
  }
}