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
    # Placeholder; Phase 3 deploy workflow will replace with your ECR digest
    image        = "public.ecr.aws/docker/library/python:3.12-alpine",
    essential    = true,
    command      = ["python", "-m", "http.server", "8000"],
    portMappings = [{ containerPort = 8000, protocol = "tcp" }],
    logConfiguration = { logDriver = "awslogs", options = {
      awslogs-group = aws_cloudwatch_log_group.api.name,
    awslogs-region = var.aws_region, awslogs-stream-prefix = "api" } }
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

