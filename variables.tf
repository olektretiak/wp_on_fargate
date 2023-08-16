# AWS Tags to add to all resources created (where possible); see https://aws.amazon.com/answers/account-management/aws-tagging-strategies/
variable "tags" {
  description = "AWS Tags to add to all resources created (where possible)"
  type        = map
  default     = {
    Project = "WordPress"
  }
}

# Prefix for all the resources to be created. Please note that only lowercase alphanumeric characters and hyphen are allowed.
variable "prefix" {
  description = "Prefix for all the resources to be created. Please note that only lowercase alphanumeric characters and hyphen are allowed."
  default     = "wordpress"
}

# The primary domain name of the website
variable "site_domain" {
  description = "The primary domain name of the website"
}

# The public domain name of the ALB
variable "public_alb_domain" {
  description = "The public domain name of the ALB"
}

# Whether to create the AWS ACM wildcard certificate
variable "create_certificate" {
  description = "Whether to create the AWS ACM wildcard certificate"
  type        = bool
  #default     = true
}

# Existing ACM certificate ARN, if not creating a new one
variable "existing_certificate_arn" {
  description = "Existing ACM certificate ARN, if not creating a new one"
  type        = string
  # default     = ""
}

# The price class for this distribution. One of PriceClass_All, PriceClass_200, PriceClass_100
variable "cf_price_class" {
  description = "The price class for this distribution. One of PriceClass_All, PriceClass_200, PriceClass_100"
  default     = "PriceClass_100"
}

# The minimum amount of time (in seconds) that CloudFront caches an HTTP error code.
variable "error_ttl" {
  description = "The minimum amount of time (in seconds) that CloudFront caches an HTTP error code."
  default     = "30"
}

# The number of instances of Fargate tasks to keep running
variable "desired_count" {
  description = "The number of instances of Fargate tasks to keep running"
  default     = "1"
}

# The number of days to retain CloudWatch logs
variable "log_retention_in_days" {
  description = "The number of days to retain CloudWatch logs"
  default     = "1"
}

# The CIDR block for the VPC
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

# List of CIDR blocks for public subnets
variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  default     = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}

# List of CIDR blocks for private subnets
variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  default     = ["10.0.100.0/24", "10.0.101.0/24", "10.0.102.0/24"]
}

# Name of the application environment. e.g. dev, prod, test, staging
variable "environment" {
  description = "Name of the application environment. e.g. dev, prod, test, staging"
  default     = "dev"
}

# Number of days to retain DB backups
variable "db_backup_retention_days" {
  description = "Number of days to retain DB backups"
  default     = "1"
}

# The daily time range during which automated backups for RDS are created if automated backups are enabled using the BackupRetentionPeriod parameter. Time in UTC.
variable "db_backup_window" {
  description = "The daily time range during which automated backups for RDS are created if automated backups are enabled using the BackupRetentionPeriod parameter. Time in UTC."
  default     = "07:00-09:00"
}

# The maximum Aurora capacity unit of the DB.
variable "db_max_capacity" {
  description = "The maximum Aurora capacity unit of the DB"
  default     = "1"
}

# The minimum Aurora capacity unit of the DB.
variable "db_min_capacity" {
  description = "The minimum Aurora capacity unit of the DB"
  default     = "1"
}

# Master username of the DB
variable "db_master_username" {
  description = "Master username of the DB"
}

# Master password of the DB
variable "db_master_password" {
  description = "Master password of the DB"
}

# The database engine version
variable "db_engine_version" {
  description = "The database engine version"
  default     = "5.7.mysql_aurora.2.08.3"
}

# Whether to enable auto pause for the DB
variable "db_auto_pause" {
  description = "Whether to enable auto pause for the DB"
  default     = true
}

# The time in seconds before Aurora DB is paused
variable "db_seconds_until_auto_pause" {
  description = "The time in seconds before Aurora DB is paused"
  default     = 300
}

# The amount (in MiB) of memory used by the task
variable "task_memory" {
  description = "The amount (in MiB) of memory used by the task"
  default     = 2048
}

# The number of CPU units used by the task
variable "task_cpu" {
  description = "The number of CPU units used by the task"
  default     = 1024
}

# The amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start (upscaling)
variable "scaling_up_cooldown" {
  description = "The amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start (upscaling)"
  default     = "60"
}

# The amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start (downscaling)
variable "scaling_down_cooldown" {
  description = "The amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start (downscaling)"
  default     = "300"
}

# The number of tasks by which to scale, when the upscaling parameters are breached
variable "scaling_up_adjustment" {
  description = "The number of tasks by which to scale, when the upscaling parameters are breached"
  default     = "1"
}

# The number of tasks by which to scale (negative for downscaling), when the downscaling parameters are breached
variable "scaling_down_adjustment" {
  description = "The number of tasks by which to scale (negative for downscaling), when the downscaling parameters are breached"
  default     = "-1"
}

# The CPU value below which downscaling kicks in
variable "task_cpu_low_threshold" {
  description = "The CPU value below which downscaling kicks in"
  default     = "30"
}

# The CPU value above which upscaling kicks in
variable "task_cpu_high_threshold" {
  description = "The CPU value above which upscaling kicks in"
  default     = "75"
}

# Maximum number of tasks should the service scale to
variable "max_task" {
  description = "Maximum number of tasks should the service scale to"
  default     = "2"
}

# Minimum number of tasks should the service always maintain
variable "min_task" {
  description = "Minimum number of tasks should the service always maintain"
  default     = "1"
}
