# Fix response headers policy name
locals {
  pretty_domain = replace(var.domain_name, ".", "-")
}


# CloudFront response headers policy
resource "aws_cloudfront_response_headers_policy" "hsts" {
  name = "${local.pretty_domain}-hsts-policy"

  security_headers_config {
    strict_transport_security {
      access_control_max_age_sec = var.hsts_max_age
      include_subdomains         = var.hsts_include_subdomains
      preload                    = var.hsts_preload
      override                   = true
    }
  }
}

# CloudFront distribution
resource "aws_cloudfront_distribution" "redirect" {
  enabled         = true
  is_ipv6_enabled = true
  aliases         = [var.domain_name]
  comment         = "Redirect ${var.domain_name} to ${var.target_domain}"
  price_class     = var.cloudfront_price_class
  tags            = var.tags

  origin {
    domain_name = aws_s3_bucket_website_configuration.redirect.website_endpoint
    origin_id   = "S3-redirect"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "S3-redirect"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    response_headers_policy_id = aws_cloudfront_response_headers_policy.hsts.id

    forwarded_values {
      query_string = true
      headers      = []

      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 86400
    max_ttl     = 31536000
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  depends_on = [aws_acm_certificate_validation.cert]
}
