# Look up the Route 53 hosted zone
data "aws_route53_zone" "domain" {
  name         = var.domain_name
  private_zone = false
}
