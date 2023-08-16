# Create an IAM role for ECS task execution with required permissions
resource "aws_iam_role" "task_execution_role" {
  name = "${var.prefix}-task-execution-role-${var.environment}"
  tags = var.tags

  # Define the permissions for assuming the role
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = ["ecs-tasks.amazonaws.com"]
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach a policy to the ECS task execution role
resource "aws_iam_role_policy_attachment" "task_execution_policy_attach" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = aws_iam_policy.task_execution_policy.arn
}

# Define an IAM policy for the ECS task execution role
resource "aws_iam_policy" "task_execution_policy" {
  name = "${var.prefix}-task-execution-policy-${var.environment}"

  # Specify permissions for the policy
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "ssm:GetParameters",
          "kms:Decrypt"
        ],
        Resource = "*"
      }
    ]
  })
}

# Create an IAM role for ECS tasks with necessary permissions
resource "aws_iam_role" "task_role" {
  name = "${var.prefix}-task-role-${var.environment}"
  tags = var.tags

  # Define the permissions for assuming the role
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = ["ecs-tasks.amazonaws.com"]
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach a policy to the ECS task role
resource "aws_iam_role_policy_attachment" "task_policy_attach" {
  role       = aws_iam_role.task_role.name
  policy_arn = aws_iam_policy.task_policy.arn
}

# Define an IAM policy for the ECS task role
resource "aws_iam_policy" "task_policy" {
  name = "${var.prefix}-task-policy-${var.environment}"

  # Specify permissions for the policy
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite"
        ],
        Resource = "*"
      }
    ]
  })
}

# Create an ECS cluster
resource "aws_ecs_cluster" "this" {
  name = "${var.prefix}-${var.environment}"
}

# Define a security group for the WordPress Fargate tasks
resource "aws_security_group" "wordpress" {
  name        = "${var.prefix}-wordpress-${var.environment}"
  description = "Fargate WordPress"
  vpc_id      = module.vpc.vpc_id

  # Define egress and ingress rules for the security group
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id, aws_security_group.efs.id]
  }

  tags = var.tags
}

# Create an ECS service
resource "aws_ecs_service" "this" {
  name             = "${var.prefix}-${var.environment}"
  cluster          = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count    = var.desired_count
  launch_type      = "FARGATE"
  platform_version = "1.4.0" # required for mounting EFS

  # Configure network settings for the service
  network_configuration {
    security_groups = [aws_security_group.alb.id, aws_security_group.db.id, aws_security_group.efs.id]
    subnets         = module.vpc.private_subnets
  }

  # Configure load balancing for the service
  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = "wordpress"
    container_port   = 80
  }

  # Ignore changes to desired count during lifecycle updates
  lifecycle {
    ignore_changes = [desired_count]
  }
}

# Create an ECS task definition
resource "aws_ecs_task_definition" "this" {
  family                   = "${var.prefix}-${var.environment}"
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  task_role_arn            = aws_iam_role.task_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory

  # Define container definitions for the task
  container_definitions    = jsonencode([
    {
      secrets = [
        {
          name      = "WORDPRESS_DB_USER"
          valueFrom = aws_ssm_parameter.db_master_user.arn
        },
        {
          name      = "WORDPRESS_DB_PASSWORD"
          valueFrom = aws_ssm_parameter.db_master_password.arn
        }
      ]
      environment = [
        {
          name  = "WORDPRESS_DB_HOST"
          value = aws_rds_cluster.this.endpoint
        },
        {
          name  = "WORDPRESS_DB_NAME"
          value = "wordpress"
        }
      ]
      essential = true
      image     = "wordpress"
      name      = "wordpress"
      portMappings = [
        {
          containerPort = 80
        }
      ]
      mountPoints = [
        {
          containerPath = "/var/www/html"
          sourceVolume  = "efs"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"  = aws_cloudwatch_log_group.wordpress.name
          "awslogs-region" = data.aws_region.current.name
          "awslogs-stream-prefix" = "app"
        }
      }
    }
  ])

  # Define a volume configuration for EFS
  volume {
    name = "efs"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.this.id
    }
  }
}

# Create a CloudWatch log group for WordPress logs
resource "aws_cloudwatch_log_group" "wordpress" {
  name              = "/${var.prefix}/${var.environment}/fg-task"
  tags              = var.tags
  retention_in_days = var.log_retention_in_days
}

# Create a target group for the load balancer
resource "aws_lb_target_group" "this" {
  name        = "${var.prefix}-${var

.environment}"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"

  # Configure stickiness settings
  stickiness {
    type            = "lb_cookie"
    enabled         = true
    cookie_duration = 86400 # Stickiness duration in seconds (e.g., 1 day)
  }

  # Configure health check settings
  health_check {
    path    = "/"
    matcher = "200,302"
  }

  vpc_id = module.vpc.vpc_id
}

# Create a listener rule for the load balancer
resource "aws_lb_listener_rule" "wordpress" {
  listener_arn = module.alb.https_listener_arns[0]
  priority     = 100

  # Configure the action for the rule
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  # Configure the condition for the rule
  condition {
    host_header {
      values = [var.site_domain, var.public_alb_domain]
    }
  }
}

# Create an HTTP listener for the load balancer
resource "aws_lb_listener" "http" {
  load_balancer_arn = module.alb.lb_arn
  port              = 80
  protocol          = "HTTP"

  # Configure a default action to redirect to HTTPS
  default_action {
    type             = "redirect"
    redirect {
      protocol      = "HTTPS"
      port          = "443"
      status_code   = "HTTP_301"
    }
  }
}

# Create CloudWatch alarms for high CPU utilization
resource "aws_cloudwatch_metric_alarm" "cpu_utilization_high" {
  alarm_name          = "${var.prefix}-high-CPU-utilization-ecs-${var.environment}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = var.task_cpu_high_threshold

  dimensions = {
    ClusterName = aws_ecs_cluster.this.name
    ServiceName = aws_ecs_service.this.name
  }

  alarm_actions = [aws_appautoscaling_policy.scale_up.arn]
}

# Create CloudWatch alarms for low CPU utilization
resource "aws_cloudwatch_metric_alarm" "cpu_utilization_low" {
  alarm_name          = "${var.prefix}-low-CPU-utilization-ecs-${var.environment}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = var.task_cpu_low_threshold

  dimensions = {
    ClusterName = aws_ecs_cluster.this.name
    ServiceName = aws_ecs_service.this.name
  }

  alarm_actions = [aws_appautoscaling_policy.scale_down.arn]
}

# Create an App Auto Scaling target for the ECS service
resource "aws_appautoscaling_target" "this" {
  max_capacity       = var.max_task
  min_capacity       = var.min_task
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Create an App Auto Scaling policy for scaling up
resource "aws_appautoscaling_policy" "scale_up" {
  name               = "${var.prefix}-ecs-scale-up-${var.environment}"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.this.resource_id
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
  service_namespace  = aws_appautoscaling_target.this.service_namespace

  # Configure step scaling policy for scaling up
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = var.scaling_up_cooldown
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = var.scaling_up_adjustment
    }
  }
}

# Create an App Auto Scaling policy for scaling down
resource "aws_appautoscaling_policy" "scale_down" {
  name               = "${var.prefix}-ecs-scale-down-${var.environment}"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.this.resource_id
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
  service_namespace  = aws_appautoscaling_target.this.service_namespace

  # Configure step scaling policy for scaling down
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = var.scaling_down_cooldown
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = var.scaling_down_adjustment
    }
  }
}

# Create a Route 53 record for the WordPress application
resource "aws_route53_record" "wordpress" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.public_alb_domain
  type    = "A"

  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = true
  }
}
