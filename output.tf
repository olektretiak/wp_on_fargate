output "alb_dns_name" {
  description = "The DNS name of the ALB."
  value       = module.alb.lb_dns_name
}

output "alb_zone_id" {
  description = "The Zone ID of the ALB."
  value       = module.alb.lb_zone_id
}

output "certificate_arn" {
  description = "The ARN of the ACM certificate (either created or existing)"
  value       = var.create_certificate ? aws_acm_certificate.domain_certificate[0].arn : var.existing_certificate_arn
}

output "alb_module_outputs" {
  value = module.alb
}