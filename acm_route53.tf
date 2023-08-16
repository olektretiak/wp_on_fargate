# ACM
# Define a data source to retrieve information about the AWS Route 53 hosted zone corresponding to the specified site domain.
data "aws_route53_zone" "this" {
  name = replace(var.site_domain, "/.*\\b(\\w+\\.\\w+)\\.?$/", "$1") # Extract main domain from potential subdomain
}

# Define an AWS ACM (Amazon Certificate Manager) certificate resource for the domain.
resource "aws_acm_certificate" "domain_certificate" {
  count = var.create_certificate ? 1 : 0

  domain_name       = "*.${data.aws_route53_zone.this.name}" # Wildcard domain
  validation_method = "DNS"
  subject_alternative_names = [data.aws_route53_zone.this.name] # Also include the base domain

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

# Define an AWS ACM certificate validation resource to validate the certificate using DNS records.
resource "aws_acm_certificate_validation" "domain_certificate" {
  count = var.create_certificate ? 1 : 0

  certificate_arn         = aws_acm_certificate.domain_certificate[0].arn
  validation_record_fqdns = [for record in aws_acm_certificate.domain_certificate[0].domain_validation_options : record.resource_record_name]
}

## Route53
# Define an AWS Route 53 DNS record for the IPv4 address, pointing to the associated CloudFront distribution.
resource "aws_route53_record" "ipv4" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.site_domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = false
  }
}

# Define an AWS Route 53 DNS record for the IPv6 address, pointing to the associated CloudFront distribution.
resource "aws_route53_record" "ipv6" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.site_domain
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = false
  }
}