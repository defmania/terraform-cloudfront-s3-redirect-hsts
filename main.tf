module "bogdandomain_redirect" {
  source = "./modules/redirect"

  providers = {
    aws.us-east-1 = aws.us-east-1
  }

  domain_name   = "testdomain.com"
  target_domain = "www.testdomain.com"
  bucket_name   = "testdomain.com-redirect"
  hsts_max_age  = 31536000

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    Project     = "enable hsts for root domains"
  }
}
