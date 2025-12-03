variable "domain_name" {
  description = "Root domain name (e.g., example.com)"
  type        = string
}

variable "target_domain" {
  description = "Target domain to redirect to (e.g., www.example.com)"
  type        = string
}

variable "bucket_name" {
  description = "S3 bucket name for the redirect"
  type        = string
}

variable "hsts_max_age" {
  description = "HSTS max age in seconds"
  type        = number
  default     = 63072000 # 2 years
}

variable "hsts_include_subdomains" {
  description = "Include subdomains in HSTS policy"
  type        = bool
  default     = true
}

variable "hsts_preload" {
  description = "Enable HSTS preload"
  type        = bool
  default     = true
}

variable "cloudfront_price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_100"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
