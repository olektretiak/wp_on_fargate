# Define an AWS CloudFront Distribution resource.
resource "aws_cloudfront_distribution" "this" {
  # Define the origin configuration for the CloudFront Distribution.
  origin {
    domain_name = var.public_alb_domain
    origin_id   = "alb"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2", "TLSv1.1"]
    }
  }

  enabled         = true
  is_ipv6_enabled = true
  comment         = var.site_domain

  aliases = [var.site_domain]

  # Define the default cache behavior for the CloudFront Distribution.
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "alb"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
      headers = ["Host"]
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
  }

  # Define ordered cache behaviors for specific path patterns.
  ordered_cache_behavior {
    path_pattern     = "wp-content/*"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "alb"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
      headers = ["Host"]
    }

    min_ttl                = 3600
    default_ttl            = 86400
    max_ttl                = 2592000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "wp-includes/*"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "alb"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
      headers = ["Host"]
    }

    min_ttl                = 3600
    default_ttl            = 86400
    max_ttl                = 2592000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  # Define the price class and tags for the CloudFront Distribution.
  price_class = var.cf_price_class
  tags        = var.tags
  
  # Define geo restrictions for the CloudFront Distribution.
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Define the viewer certificate configuration for the CloudFront Distribution.
  viewer_certificate {
    acm_certificate_arn      = var.create_certificate ? aws_acm_certificate.domain_certificate[0].arn : var.existing_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  # Define custom error responses for the CloudFront Distribution.
  custom_error_response {
    error_code            = 400
    error_caching_min_ttl = var.error_ttl
  }

  custom_error_response {
    error_code            = 403
    error_caching_min_ttl = var.error_ttl
  }

  custom_error_response {
    error_code            = 404
    error_caching_min_ttl = var.error_ttl
  }

  custom_error_response {
    error_code            = 405
    error_caching_min_ttl = var.error_ttl
  }

  # Specify dependencies for the CloudFront Distribution.
  depends_on = [
    aws_ecs_service.this
  ]
}