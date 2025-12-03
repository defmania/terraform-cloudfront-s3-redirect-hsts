# terraform-cloudfront-s3-redirect-hsts
# Root to WWW Redirect Module

Terraform module for redirecting apex domains (e.g., `example.com`) to their www subdomain (e.g., `www.example.com`) using CloudFront, S3, and ACM.

## Features

- ✅ 301 redirects with path and query string preservation
- ✅ HTTPS enforcement via CloudFront
- ✅ HSTS with preload support
- ✅ IPv4 and IPv6 support
- ✅ Automatic ACM certificate provisioning and validation
- ✅ Zero-code S3 redirect configuration

## Architecture
```
example.com
    ↓
CloudFront (HTTPS + HSTS)
    ↓
S3 Bucket (redirect config)
    ↓
301 → www.example.com
```

## Requirements

- OpenTofu/Terraform >= 1.0
- AWS Provider >= 6.0
- Existing Route 53 hosted zone for your domain

## Usage

### Module Structure
```
.
├── terraform.tf
├── main.tf
└── modules/
    └── redirect/
        ├── acm.tf
        ├── cloudfront.tf
        ├── outputs.tf
        ├── route53.tf
        ├── s3.tf
        ├── variables.tf
        └── versions.tf
```

## Deployment

### 1. Deploy Infrastructure
```bash
tofu init
tofu plan
tofu apply
```

### 2. Test Before DNS Cutover
```bash
# Get CloudFront domain
CLOUDFRONT_DOMAIN=$(tofu output -raw cloudfront_info | jq -r '.domain_name')

# Test root redirect
curl -I https://$CLOUDFRONT_DOMAIN/ -H "Host: example.com"

# Test path preservation
curl -I https://$CLOUDFRONT_DOMAIN/about/contact?foo=bar \
  -H "Host: example.com"

# Verify HSTS header
curl -I https://$CLOUDFRONT_DOMAIN/ -H "Host: example.com" | grep -i strict
```

**Expected output:**
```
HTTP/2 301
location: https://www.example.com/
strict-transport-security: max-age=63072000; includeSubDomains; preload
```

### 3. Update DNS Records

Manually add these records in Route 53:

- **A Record (IPv4):**
  - Name: `example.com`
  - Type: `A - IPv4 address`
  - Alias: `Yes`
  - Target: CloudFront distribution domain

- **AAAA Record (IPv6):**
  - Name: `example.com`
  - Type: `AAAA - IPv6 address`
  - Alias: `Yes`
  - Target: Same CloudFront distribution domain

### 4. Verify Live
```bash
# Wait 1-2 minutes for DNS propagation
curl -I https://example.com/
```

## Module Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `domain_name` | Apex domain to redirect from | - | Yes |
| `target_domain` | Target domain to redirect to | - | Yes |
| `hsts_max_age` | HSTS max age in seconds | `63072000` (2 years) | No |
| `hsts_include_subdomains` | Include subdomains in HSTS | `true` | No |
| `hsts_preload` | Enable HSTS preload | `true` | No |
| `cloudfront_price_class` | CloudFront price class | `PriceClass_100` | No |
| `tags` | Tags to apply to resources | `{}` | No |

## Multiple Domains
```hcl
module "domain1_redirect" {
  source = "./modules/redirect"
  # ...
  domain_name   = "domain1.com"
  target_domain = "www.domain1.com"
}

module "domain2_redirect" {
  source = "./modules/redirect"
  # ...
  domain_name   = "domain2.com"
  target_domain = "www.domain2.com"
}
```

## HSTS Preload

To submit your domain to browser preload lists:

1. Deploy this module with `hsts_preload = true` (default)
2. Wait for DNS propagation
3. Submit at https://hstspreload.org/
4. Wait for acceptance (can take weeks/months)

**Warning:** `includeSubDomains` applies HSTS to ALL subdomains. Ensure all subdomains support HTTPS.

## Troubleshooting

**Certificate validation hanging?**
- Check Route 53 validation records were created
- Wait up to 30 minutes for DNS propagation

**403 Forbidden?**
- CloudFront distribution may still be deploying (15-20 minutes)
- Check S3 bucket website configuration is enabled

**HSTS not appearing?**
- Verify Response Headers Policy is attached to distribution
- Check you're testing via HTTPS

## License

MIT
