resource "aws_ecs_cluster" "container_cluster" {
  name = "${var.name_prefix}-cluster-${var.path}"

  tags = {
    Path = var.path
  }
}

resource "aws_cloudwatch_log_group" "cluster_logs"{
  name = "/ecs/${var.name_prefix}-app-${var.path}"
  retention_in_days = 14

  tags = {
    Path = var.path
  }
}


#IAM segment

data "aws_iam_policy_document" "ecs_tasks_execution_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task_execution_role" {
  name               = "${var.name_prefix}-task-execution-role-${var.path}"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_execution_assume_role.json

  tags = {
    Path = var.path
  }
}

data "aws_iam_policy_document" "task_execution_permissions" {

  statement {
    sid       = "AllowEcrAuth"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowImagePull"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    resources = [aws_ecr_repository.container_repo.arn]
  }

  statement {
    sid    = "AllowAppLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["${aws_cloudwatch_log_group.cluster_logs.arn}:*"]
  }
}

resource "aws_iam_role_policy" "task_execution_permissions" {
  name   = "${var.name_prefix}-task-execution-permissions-${var.path}"
  role   = aws_iam_role.task_execution_role.id
  policy = data.aws_iam_policy_document.task_execution_permissions.json
}


# Task Definition

resource "aws_ecs_task_definition" "task_definition" {
  family                   = "${var.name_prefix}-task-definition-${var.path}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = "${aws_ecr_repository.container_repo.repository_url}:manual-test" #targeting the container we pushed manually for testing
      essential = true

      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.cluster_logs.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "${var.name_prefix}-app"
        }
      }
    }
  ])

  tags = {
    Path = var.path
  }
}

# ECS Service

resource "aws_ecs_service" "service" {
  name            = "${var.name_prefix}-service-${var.path}"
  cluster         = aws_ecs_cluster.container_cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = var.task_desired_count
  launch_type     = "FARGATE"

  health_check_grace_period_seconds = 90

  network_configuration {
    subnets          = module.network.public_subnet_ids
    security_groups  = [aws_security_group.web_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "app"
    container_port   = 8080
  }

  depends_on = [aws_lb_listener.http]

  tags = {
    Path = var.path
  }
}