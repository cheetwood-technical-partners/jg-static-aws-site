# SSL Certificate
#resource "aws_acm_certificate" "ssl_certificate" {
#  provider                  = aws.acm_provider
#  domain_name               = var.domain_name
#  subject_alternative_names = ["*.${var.domain_name}"]
#  validation_method         = "DNS"
#  #validation_method = "DNS"
#
#  tags = var.common_tags
#
#  lifecycle {
#    create_before_destroy = true
#  }
#}

# Uncomment the validation_record_fqdns line if you do DNS validation instead of Email.
#resource "aws_acm_certificate_validation" "cert_validation" {
#  provider        = aws.acm_provider
#  certificate_arn = aws_acm_certificate.ssl_certificate.arn
#  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
#}

## ACM Cert, DNS Records, and Validation
resource "aws_acm_certificate" "ssl_certification" {
  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
  options {
    certificate_transparency_logging_preference = "ENABLED"
  }
}

data "aws_route53_zone" "domain_validation" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "domain_validation" {
  for_each = {
    for dvo in aws_acm_certificate.ssl_certification.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.domain_validation.id
}

resource "aws_acm_certificate_validation" "domain_validation" {
  certificate_arn         = aws_acm_certificate.ssl_certification.arn
  validation_record_fqdns = [for record in aws_route53_record.domain_validation : record.fqdn]
}
