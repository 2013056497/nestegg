resource "aws_security_group" "api" {
  name   = "${local.name}-api-sg"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_ecs_task_definition" "backend" {
  family                   = "${local.name}-api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.exec.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([{
    name = "api",
    # This placeholder will be overwritten by deploy-ecs.yml with a digest
    image        = "${local.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${local.name}-backend:latest",
    essential    = true,
    portMappings = [{ containerPort = 8000, protocol = "tcp" }],
    logConfiguration = {
      logDriver = "awslogs",
      options = {
        awslogs-group         = aws_cloudwatch_log_group.api.name,
        awslogs-region        = var.aws_region,
        awslogs-stream-prefix = "api"
      }
    },
    # Add a container health check for your FastAPI /healthz route
    healthCheck = {
      command     = ["CMD-SHELL", "curl -f http://localhost:8000/healthz || exit 1"]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 10
    }
  }])

  tags = local.tags
}

resource "aws_ecs_service" "backend" {
  name            = "${local.name}-api"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.all.ids
    security_groups  = [aws_security_group.api.id]
    assign_public_ip = true
  }

  tags = local.tags
}

