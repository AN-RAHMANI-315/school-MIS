# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${local.name_prefix}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Additional policy for Secrets Manager and CloudWatch
resource "aws_iam_role_policy" "ecs_task_execution_policy" {
  name = "${local.name_prefix}-ecs-task-execution-policy"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          aws_secretsmanager_secret.mongo_url.arn,
          aws_secretsmanager_secret.db_name.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          aws_cloudwatch_log_group.backend.arn,
          aws_cloudwatch_log_group.frontend.arn,
          "${aws_cloudwatch_log_group.backend.arn}:*",
          "${aws_cloudwatch_log_group.frontend.arn}:*"
        ]
      }
    ]
  })
}

# ECS Task Role
resource "aws_iam_role" "ecs_task_role" {
  name = "${local.name_prefix}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags

  lifecycle {
    ignore_changes = [name]
    prevent_destroy = true
  }
}

# Policy for ECS Task Role (application-specific permissions)
resource "aws_iam_role_policy" "ecs_task_policy" {
  name = "${local.name_prefix}-ecs-task-policy"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}

# Secrets Manager Secrets
resource "aws_secretsmanager_secret" "mongo_url" {
  name                    = "${local.name_prefix}-mongo-url"
  description            = "MongoDB connection URL for School MIS"
  recovery_window_in_days = 7

  tags = local.common_tags

  lifecycle {
    ignore_changes = [name]
    prevent_destroy = true
  }
}

resource "aws_secretsmanager_secret_version" "mongo_url" {
  secret_id     = aws_secretsmanager_secret.mongo_url.id
  secret_string = "mongodb://admin:password123@localhost:27017/school_mis?authSource=admin"
}

resource "aws_secretsmanager_secret" "db_name" {
  name                    = "${local.name_prefix}-db-name"
  description            = "Database name for School MIS"
  recovery_window_in_days = 7

  tags = local.common_tags

  lifecycle {
    ignore_changes = [name]
    prevent_destroy = true
  }
}

resource "aws_secretsmanager_secret_version" "db_name" {
  secret_id     = aws_secretsmanager_secret.db_name.id
  secret_string = "school_mis"
}

# Auto Scaling Role
resource "aws_iam_role" "ecs_auto_scaling_role" {
  count = var.enable_auto_scaling ? 1 : 0
  name  = "${local.name_prefix}-ecs-auto-scaling-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "application-autoscaling.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags

  lifecycle {
    ignore_changes = [name]
  }
}

resource "aws_iam_role_policy_attachment" "ecs_auto_scaling_role" {
  count      = var.enable_auto_scaling ? 1 : 0
  role       = aws_iam_role.ecs_auto_scaling_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/ApplicationAutoScalingECSServicePolicy"
}
