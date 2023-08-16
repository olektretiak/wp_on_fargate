resource "aws_security_group" "alb" {
  name        = "${var.prefix}-alb-${var.environment}"
  description = "Allow HTTPS inbound traffc"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  tags = var.tags
}


module "alb" {
  source             = "terraform-aws-modules/alb/aws"
  version            = "~> 8.0"
  name               = "${var.prefix}-${var.environment}"
  load_balancer_type = "application"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.alb.id]

  https_listeners = [
    {
      "certificate_arn" = var.create_certificate ? aws_acm_certificate.domain_certificate[0].arn : var.existing_certificate_arn
      "port"            = 443
      "ssl_policy"      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
    },
  ]

  target_groups = [
    {
      name             = "${var.prefix}-default-${var.environment}"
      backend_protocol = "HTTP"
      backend_port     = 80
    }
  ]
  tags = var.tags
}
